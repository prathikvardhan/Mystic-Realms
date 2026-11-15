extends Node

signal player_health_changed(current_hp: float, max_hp: float)
signal player_mana_changed(current_mp: float, max_mp: float)
signal player_died()
signal player_respawned()
signal power_unlocked(power_name: String)
signal crystals_changed(count: int)
signal checkpoint_reached(pos: Vector2)
signal boss_spawned(boss_name: String, max_hp: float)
signal boss_health_changed(current_hp: float, max_hp: float)
signal boss_defeated()
signal notification_posted(text: String)
signal tutorial_posted(text: String)
signal tutorial_cleared()

# Bounce Back Jam Signals
signal rebound_changed(current_val: float, max_val: float)
signal overdrive_started()
signal overdrive_ended()
signal floating_text_requested(text: String, pos: Vector2, color: Color)
signal death_count_changed(count: int)
signal respawn_count_changed(count: int)

var player_hp: float = 250.0
var player_max_hp: float = 250.0
var player_mp: float = 200.0
var player_max_mp: float = 200.0
var mana_regen_rate: float = 30.0

var crystals: int = 0
var current_level: int = 1
var max_level_unlocked: int = 1
var death_count: int = 0
var respawn_count: int = 0

# BOUNCE BACK: REBOUND & OVERDRIVE
var rebound_meter: float = 0.0
const MAX_REBOUND: float = 100.0
var is_overdrive: bool = false
var overdrive_timer: float = 0.0

# Permanent Buffs from Ruined Shrines
var speed_multiplier: float = 1.0
var damage_multiplier: float = 1.0
var rebound_gain_multiplier: float = 1.0

var unlocked_powers = {
	"fireball": true,
	"ice_blast": true,
	"lightning": false,
	"shield": false,
	"void_cannon": false,
	"shadow_step": false
}

const ABILITY_DATA = {
	"fireball": {
		"cost": 15.0,
		"cooldown": 0.30,
		"damage": 45.0,
		"key": "J",
		"name": "Fireball"
	},
	"ice_blast": {
		"cost": 25.0,
		"cooldown": 1.2,
		"damage": 30.0,
		"freeze_duration": 4.0,
		"key": "K",
		"name": "Ice Blast"
	},
	"lightning": {
		"cost": 40.0,
		"cooldown": 2.2,
		"damage": 95.0,
		"key": "L",
		"name": "Lightning Strike"
	},
	"shield": {
		"cost": 30.0,
		"cooldown": 4.0,
		"duration": 5.0,
		"key": "I",
		"name": "Magic Shield"
	},
	"void_cannon": {
		"cost": 40.0,
		"cooldown": 2.2,
		"damage": 650.0,
		"key": "E",
		"name": "Astral Void Cannon"
	},
	"shadow_step": {
		"cost": 15.0,
		"cooldown": 1.2,
		"key": "F",
		"name": "Chronos Shadow Step"
	}
}

var active_checkpoint_pos: Vector2 = Vector2.ZERO
var has_checkpoint: bool = false
var is_game_over: bool = false
var is_invulnerable: bool = false
var shield_active: bool = false

const SAVE_PATH = "user://mystic_realms_save.json"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_input_mappings()
	load_game()

func _process(delta: float) -> void:
	if not is_game_over and player_mp < player_max_mp:
		player_mp = minf(player_max_mp, player_mp + mana_regen_rate * delta)
		player_mana_changed.emit(player_mp, player_max_mp)
		
	# Overdrive timer
	if is_overdrive:
		overdrive_timer -= delta
		if overdrive_timer <= 0.0:
			end_overdrive()

func _ensure_input_mappings() -> void:
	var keys = {
		"move_left": [KEY_A, KEY_LEFT],
		"move_right": [KEY_D, KEY_RIGHT],
		"jump": [KEY_SPACE, KEY_W, KEY_UP],
		"fireball": [KEY_J],
		"ice_blast": [KEY_K],
		"lightning": [KEY_L],
		"shield": [KEY_I],
		"void_cannon": [KEY_E],
		"shadow_step": [KEY_F],
		"parry": [KEY_SHIFT, KEY_I],
		"rebound": [KEY_Q],
		"restart": [KEY_R],
		"pause": [KEY_ESCAPE, KEY_P]
	}
	for action in keys:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			for k in keys[action]:
				var ev = InputEventKey.new()
				ev.physical_keycode = k
				InputMap.action_add_event(action, ev)
				
	# Mouse button bindings for Attack and Parry
	if not InputMap.has_action("mouse_attack"):
		InputMap.add_action("mouse_attack")
		var mb = InputEventMouseButton.new()
		mb.button_index = MOUSE_BUTTON_LEFT
		InputMap.action_add_event("mouse_attack", mb)
		
	if not InputMap.has_action("mouse_parry"):
		InputMap.add_action("mouse_parry")
		var mb2 = InputEventMouseButton.new()
		mb2.button_index = MOUSE_BUTTON_RIGHT
		InputMap.action_add_event("mouse_parry", mb2)

func start_level(level_num: int) -> void:
	current_level = level_num
	has_checkpoint = false
	active_checkpoint_pos = Vector2.ZERO
	is_game_over = false
	shield_active = false
	is_invulnerable = false
	player_hp = player_max_hp
	player_mp = player_max_mp
	rebound_meter = 0.0
	is_overdrive = false
	
	# Only Fireball [J] and Freeze Power [K]
	unlocked_powers["fireball"] = true
	unlocked_powers["ice_blast"] = true
	unlocked_powers["lightning"] = false
	unlocked_powers["shield"] = false
	unlocked_powers["void_cannon"] = false
	unlocked_powers["shadow_step"] = false
	
	if level_num == 0:
		get_tree().change_scene_to_file("res://scenes/levels/level_tutorial.tscn")
		return

	get_tree().change_scene_to_file("res://scenes/levels/final_battle.tscn")

func add_rebound(amount: float) -> void:
	if is_overdrive:
		return
	rebound_meter = minf(MAX_REBOUND, rebound_meter + amount * rebound_gain_multiplier)
	rebound_changed.emit(rebound_meter, MAX_REBOUND)
	if rebound_meter >= MAX_REBOUND:
		post_notification("REBOUND READY! Press [Q] to activate Overdrive!")

func trigger_rebound_overdrive(player_pos: Vector2) -> void:
	if rebound_meter < MAX_REBOUND or is_overdrive:
		return
	rebound_meter = 0.0
	rebound_changed.emit(rebound_meter, MAX_REBOUND)
	is_overdrive = true
	overdrive_timer = 5.0
	overdrive_started.emit()
	
	SoundManager.play_sfx("victory")
	hit_stop(0.08)
	pop_floating_text("REBOUND OVERDRIVE!", player_pos + Vector2(0, -40), Color(1.0, 0.85, 0.2))
	post_notification("OVERDRIVE! Rapid Fire & 5x Mega Ricochet Activated!")
	
	# Radial Shockwave knocks back nearby enemies
	var enemies = get_tree().get_nodes_in_group("enemies")
	for e in enemies:
		if is_instance_valid(e) and not e.is_dead:
			var d = player_pos.distance_to(e.global_position)
			if d < 220.0:
				e.take_damage(60.0, "rebound")
				var knock_dir = (e.global_position - player_pos).normalized()
				if e is CharacterBody2D:
					e.velocity = knock_dir * 380.0

func end_overdrive() -> void:
	is_overdrive = false
	overdrive_ended.emit()
	post_notification("Overdrive ended.")

func hit_stop(duration: float = 0.06) -> void:
	Engine.time_scale = 0.05
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0

func apply_shrine_buff(stat_type: String, shrine_pos: Vector2) -> void:
	if stat_type == "hp":
		player_max_hp += 30.0
		player_hp = minf(player_max_hp, player_hp + 75.0)
		player_health_changed.emit(player_hp, player_max_hp)
		pop_floating_text("SHRINE RESTORED! +30 MAX HP & HEAL!", shrine_pos + Vector2(0, -30), Color(0.2, 1.0, 0.4))
	elif stat_type == "speed":
		speed_multiplier += 0.15
		pop_floating_text("SHRINE RESTORED! +15% MOVE SPEED!", shrine_pos + Vector2(0, -30), Color(0.2, 0.8, 1.0))
	elif stat_type == "rebound":
		rebound_gain_multiplier += 0.30
		pop_floating_text("SHRINE RESTORED! +30% REBOUND RATE!", shrine_pos + Vector2(0, -30), Color(1.0, 0.85, 0.2))
	SoundManager.play_sfx("checkpoint")

const SCENE_FLOATING_TEXT = preload("res://scenes/ui/floating_text.tscn")

func pop_floating_text(text: String, pos: Vector2, color: Color = Color.WHITE) -> void:
	floating_text_requested.emit(text, pos, color)
	var scene = get_tree().current_scene
	if scene:
		var ft = SCENE_FLOATING_TEXT.instantiate()
		scene.add_child(ft)
		ft.setup(text, pos, color)

func set_checkpoint(pos: Vector2) -> void:
	has_checkpoint = true
	active_checkpoint_pos = pos
	checkpoint_reached.emit(pos)
	SoundManager.play_sfx("checkpoint")
	post_notification("Checkpoint Activated!")

func take_damage(amount: float) -> bool:
	if is_game_over or is_invulnerable:
		return false
	if shield_active:
		SoundManager.play_sfx("shield_break")
		post_notification("Magic Shield Absorbed the Attack!")
		add_rebound(15.0)
		return false
		
	player_hp = maxf(0.0, player_hp - amount)
	player_health_changed.emit(player_hp, player_max_hp)
	SoundManager.play_sfx("hurt")
	
	# Taking damage fuels the Rebound meter!
	add_rebound(25.0)
	
	if player_hp <= 0.0:
		is_game_over = true
		death_count += 1
		death_count_changed.emit(death_count)
		save_game()
		player_died.emit()
		SoundManager.play_sfx("death")
	return true

func heal(amount: float) -> void:
	player_hp = minf(player_max_hp, player_hp + amount)
	player_health_changed.emit(player_hp, player_max_hp)

func consume_mana(amount: float) -> bool:
	if is_overdrive:
		return true # Free casting during Overdrive!
	if player_mp >= amount:
		player_mp -= amount
		player_mana_changed.emit(player_mp, player_max_mp)
		return true
	return false

func add_crystals(count: int = 1) -> void:
	crystals += count
	crystals_changed.emit(crystals)
	add_rebound(4.0)
	SoundManager.play_sfx("crystal")

func unlock_power(power_name: String) -> void:
	if unlocked_powers.has(power_name):
		unlocked_powers[power_name] = true
		power_unlocked.emit(power_name)
		var p_name = ABILITY_DATA[power_name]["name"]
		var key = ABILITY_DATA[power_name]["key"]
		post_notification("Unlocked %s! Press [%s]" % [p_name, key])
		SoundManager.play_sfx("victory")
		save_game()

func post_notification(text: String) -> void:
	notification_posted.emit(text)

func post_tutorial(text: String) -> void:
	tutorial_posted.emit(text)

func hide_tutorial() -> void:
	tutorial_cleared.emit()

func respawn_player() -> void:
	is_game_over = false
	shield_active = false
	is_overdrive = false
	respawn_count += 1
	respawn_count_changed.emit(respawn_count)
	save_game()
	player_hp = player_max_hp
	player_mp = player_max_mp
	rebound_meter = 0.0
	rebound_changed.emit(rebound_meter, MAX_REBOUND)
	player_health_changed.emit(player_hp, player_max_hp)
	player_mana_changed.emit(player_mp, player_max_mp)
	player_respawned.emit()
	SoundManager.play_sfx("respawn")

func complete_level() -> void:
	if current_level == 0:
		post_notification("Tutorial Grounds Conquered! Entering the Final Battle...")
		await get_tree().create_timer(1.6).timeout
		start_level(8)
	else:
		post_notification("👑 THE PRIMORDIAL VOID EMPEROR HAS FALLEN! SUPREME VICTORY! 👑")
		SoundManager.play_sfx("victory")
		save_game()
		await get_tree().create_timer(2.0).timeout
		get_tree().change_scene_to_file("res://scenes/ui/victory_menu.tscn")

func save_game() -> void:
	var data = {
		"crystals": crystals,
		"max_level_unlocked": max_level_unlocked,
		"unlocked_powers": unlocked_powers,
		"death_count": death_count,
		"respawn_count": respawn_count
	}
	var f = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data))
		f.close()

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var f = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f:
		var json = JSON.new()
		var res = json.parse(f.get_as_text())
		f.close()
		if res == OK and json.data is Dictionary:
			var d = json.data
			crystals = d.get("crystals", 0)
			max_level_unlocked = d.get("max_level_unlocked", 1)
			death_count = d.get("death_count", 0)
			respawn_count = d.get("respawn_count", 0)
			var p = d.get("unlocked_powers", {})
			for k in p:
				if unlocked_powers.has(k):
					unlocked_powers[k] = p[k]

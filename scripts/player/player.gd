extends CharacterBody2D
class_name Player

@export var speed: float = 190.0
@export var acceleration: float = 950.0
@export var friction: float = 1100.0
@export var jump_velocity: float = -370.0
@export var gravity: float = 980.0
@export var fall_multiplier: float = 1.35

var facing: float = 1.0
var is_dead: bool = false
var is_attacking: bool = false
var is_spawning: bool = false
var is_parrying: bool = false
var parry_timer: float = 0.0
var parry_cooldown: float = 0.0

var is_stunned: bool = false
var stun_timer: float = 0.0
var stun_indicator: Sprite2D = null

var coyote_timer: float = 0.0
var jump_buffer: float = 0.0
var attack_timer: float = 0.0

# Cooldown trackers
var cooldowns = {
	"fireball": 0.0,
	"ice_blast": 0.0,
	"lightning": 0.0,
	"shield": 0.0,
	"void_cannon": 0.0,
	"shadow_step": 0.0
}

# Preloaded ability scenes
const SCENE_FIREBALL = preload("res://scenes/abilities/fireball.tscn")
const SCENE_ICE_BLAST = preload("res://scenes/abilities/ice_blast.tscn")
const SCENE_LIGHTNING = preload("res://scenes/abilities/lightning_strike.tscn")
const SCENE_SHIELD = preload("res://scenes/abilities/magic_shield.tscn")
const SCENE_VOID_CANNON = preload("res://scenes/abilities/astral_void_cannon.tscn")

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var cast_point: Marker2D = $CastPoint
@onready var hurt_box: Area2D = $HurtBox

var initial_spawn_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	add_to_group("player")
	initial_spawn_pos = global_position
	if not GameManager.has_checkpoint:
		GameManager.active_checkpoint_pos = initial_spawn_pos
		
	GameManager.player_died.connect(_on_player_died)
	GameManager.player_respawned.connect(_on_player_respawned)
	
	_play_respawn()

func _physics_process(delta: float) -> void:
	_update_cooldowns(delta)
	_check_near_misses()
	
	if is_dead or is_spawning:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)
		if not is_on_floor():
			velocity.y += gravity * delta
		move_and_slide()
		return

	if is_stunned:
		stun_timer -= delta
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)
		if not is_on_floor():
			velocity.y += gravity * delta
		move_and_slide()
		anim.play("hurt")
		if stun_indicator:
			stun_indicator.rotation += delta * 6.0
		if stun_timer <= 0.0:
			clear_stun()
		return

	# Handle R key restart from checkpoint
	if Input.is_action_just_pressed("restart"):
		GameManager.respawn_player()
		return

	# Handle Parry/Deflect (Right-Click, Shift, or I key)
	if (Input.is_action_just_pressed("parry") or Input.is_action_just_pressed("mouse_parry")) and parry_cooldown <= 0.0:
		_perform_parry()

	# Ground & Coyote Time
	if is_on_floor():
		coyote_timer = 0.12
	else:
		coyote_timer -= delta
		var cur_grav = gravity * (fall_multiplier if velocity.y > 0 else 1.0)
		velocity.y += cur_grav * delta

	# Jump Buffer
	if Input.is_action_just_pressed("jump"):
		jump_buffer = 0.12
	else:
		jump_buffer -= delta

	# Perform Jump
	if jump_buffer > 0.0 and coyote_timer > 0.0:
		velocity.y = jump_velocity
		jump_buffer = 0.0
		coyote_timer = 0.0
		SoundManager.play_sfx("jump")

	# Variable Jump Cut
	if Input.is_action_just_released("jump") and velocity.y < jump_velocity * 0.4:
		velocity.y = jump_velocity * 0.4

	# Horizontal Movement (A / D) with shrine speed buff and Overdrive haste
	var eff_speed = speed * GameManager.speed_multiplier
	if GameManager.is_overdrive:
		eff_speed *= 1.25
		
	var dir = Input.get_axis("move_left", "move_right")
	if dir != 0.0:
		velocity.x = move_toward(velocity.x, dir * eff_speed, acceleration * delta)
		facing = signf(dir)
		anim.flip_h = (facing < 0)
		cast_point.position.x = 16.0 * facing
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)

	# Magical Abilities & Attacks
	_handle_spells()

	# Move
	move_and_slide()

	# Update Animation and Overdrive visuals
	_update_animation()

func _update_cooldowns(delta: float) -> void:
	for k in cooldowns:
		if cooldowns[k] > 0.0:
			cooldowns[k] -= delta
	if parry_cooldown > 0.0:
		parry_cooldown -= delta
	if parry_timer > 0.0:
		parry_timer -= delta
		if parry_timer <= 0.0:
			is_parrying = false

func _perform_parry() -> void:
	is_parrying = true
	parry_timer = 0.35
	parry_cooldown = 0.70
	SoundManager.play_sfx("shield")
	
	# Visual parry flash
	var tween = create_tween()
	anim.modulate = Color(1.5, 1.4, 0.6)
	tween.tween_property(anim, "modulate", Color.WHITE if not GameManager.is_overdrive else Color(1.2, 1.1, 0.5), 0.35)
	
	# Active deflection check: sweep nearby enemy projectiles
	var projs = get_tree().get_nodes_in_group("enemy_projectiles")
	var deflected_count = 0
	for p in projs:
		if is_instance_valid(p) and global_position.distance_to(p.global_position) <= 75.0:
			var d_dir = (p.global_position - global_position).normalized()
			if d_dir == Vector2.ZERO:
				d_dir = Vector2(facing, 0.0)
			if p.has_method("deflect"):
				p.deflect(d_dir)
				deflected_count += 1
				
	if deflected_count > 0:
		SoundManager.play_sfx_pitched("crystal", 1.8)
		SoundManager.play_sfx("victory")
		GameManager.hit_stop(0.08)
		GameManager.add_rebound(35.0 * deflected_count)
		GameManager.pop_floating_text("DEFLECTED %dx!" % (deflected_count * 3), global_position + Vector2(0, -35), Color(1.0, 0.9, 0.2))

func _check_near_misses() -> void:
	if is_dead:
		return
	var projs = get_tree().get_nodes_in_group("enemy_projectiles")
	for p in projs:
		if is_instance_valid(p) and not p.has_meta("near_miss_awarded"):
			var d = global_position.distance_to(p.global_position)
			if d <= 52.0 and d > 16.0:
				p.set_meta("near_miss_awarded", true)
				GameManager.add_rebound(12.0)
				GameManager.pop_floating_text("NEAR MISS! +12%", global_position + Vector2(0, -25), Color(0.2, 0.9, 1.0))
				SoundManager.play_sfx_pitched("crystal", 1.5)

func _handle_spells() -> void:
	# Fireball (J or Left-Click)
	if Input.is_action_just_pressed("fireball") or Input.is_action_just_pressed("mouse_attack"):
		_try_cast("fireball", _cast_fireball)
	# Freeze Power / Ice Blast (K)
	elif Input.is_action_just_pressed("ice_blast"):
		_try_cast("ice_blast", _cast_ice_blast)

func _get_aim_direction() -> Vector2:
	# If mouse was clicked or is far from player, aim towards mouse
	if Input.is_action_just_pressed("mouse_attack") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var mouse_dir = (get_global_mouse_position() - cast_point.global_position).normalized()
		if mouse_dir != Vector2.ZERO:
			facing = signf(mouse_dir.x) if abs(mouse_dir.x) > 0.1 else facing
			anim.flip_h = (facing < 0)
			cast_point.position.x = 16.0 * facing
			return mouse_dir

	# Keyboard aiming (holding Down / S or Up / W)
	var shoot_dir = Vector2(facing, 0.0)
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		shoot_dir.y += 1.2
	elif Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		shoot_dir.y -= 1.2
	return shoot_dir.normalized()

func _try_cast(ability: String, cast_func: Callable) -> void:
	if not GameManager.unlocked_powers.get(ability, false):
		GameManager.post_notification("%s is not yet unlocked!" % GameManager.ABILITY_DATA[ability]["name"])
		return
	if cooldowns[ability] > 0.0:
		return
	var cost = GameManager.ABILITY_DATA[ability]["cost"]
	if not GameManager.consume_mana(cost):
		GameManager.post_notification("Not enough Magic Energy!")
		return
		
	var base_cd = GameManager.ABILITY_DATA[ability]["cooldown"]
	if GameManager.is_overdrive and ability == "fireball":
		base_cd = 0.10 # Rapid fire machine-gun ricochets in Overdrive!
	cooldowns[ability] = base_cd
	_trigger_attack_anim()
	cast_func.call()

func _trigger_attack_anim() -> void:
	is_attacking = true
	attack_timer = 0.20 if GameManager.is_overdrive else 0.28

func _cast_fireball() -> void:
	SoundManager.play_sfx("fireball")
	var shoot_dir = _get_aim_direction()
	var fb = SCENE_FIREBALL.instantiate()
	fb.global_position = cast_point.global_position
	fb.direction = facing
	fb.velocity = shoot_dir * 460.0
	get_parent().add_child(fb)
	
	# Magical Recoil impulse
	_apply_magical_recoil(shoot_dir)

func _cast_ice_blast() -> void:
	SoundManager.play_sfx("ice_blast")
	var shoot_dir = _get_aim_direction()
	var ib = SCENE_ICE_BLAST.instantiate()
	ib.global_position = cast_point.global_position
	ib.direction = facing
	ib.velocity = shoot_dir * 400.0
	get_parent().add_child(ib)
	
	# Recoil impulse
	_apply_magical_recoil(shoot_dir * 0.75)

func _apply_magical_recoil(shoot_dir: Vector2) -> void:
	# Rocket Jump: Shooting downwards launches the player upwards
	if shoot_dir.y > 0.35:
		velocity.y = minf(velocity.y - 420.0, -420.0)
		velocity.x -= shoot_dir.x * 220.0
		GameManager.pop_floating_text("BOOST!", global_position + Vector2(0, 15), Color(0.3, 0.9, 1.0))
		SoundManager.play_sfx_pitched("jump", 1.25)
	else:
		# Recoil backwards
		velocity.x -= shoot_dir.x * 240.0
		if shoot_dir.y < -0.35 and not is_on_floor():
			velocity.y += 180.0

func _cast_lightning() -> void:
	var ls = SCENE_LIGHTNING.instantiate()
	ls.global_position = global_position + Vector2(facing * 75.0, 16.0)
	get_parent().add_child(ls)

func _cast_shield() -> void:
	for c in get_children():
		if c.name.begins_with("MagicShield"):
			c.queue_free()
	var s = SCENE_SHIELD.instantiate()
	add_child(s)

func _cast_void_cannon() -> void:
	SoundManager.play_sfx("lightning")
	SoundManager.play_sfx_pitched("fireball", 0.6)
	var shoot_dir = _get_aim_direction()
	var vc = SCENE_VOID_CANNON.instantiate()
	vc.global_position = cast_point.global_position
	vc.direction = facing
	vc.velocity = shoot_dir * 620.0
	get_parent().add_child(vc)
	
	# Massive Rocket Kickback
	_apply_magical_recoil(shoot_dir * 1.6)

func _cast_shadow_step() -> void:
	# Spawns shadow ghost at start
	BossGhostTrail.spawn_ghost(self, anim, Color(0.8, 0.3, 1.0, 0.9), 0.35)
	_spawn_teleport_effect(global_position)
	
	clear_stun()
	
	var dir = Input.get_axis("move_left", "move_right")
	if dir == 0.0:
		dir = facing
	var target_offset = Vector2(dir * 220.0, 0.0)
	
	# Check vertical aiming or holding up/down
	if Input.is_action_pressed("jump") or Input.is_key_pressed(KEY_W):
		target_offset.y -= 120.0
	elif Input.is_key_pressed(KEY_S):
		target_offset.y += 120.0
		
	# Raycast against World Geometry (Collision Layer 1) to prevent teleporting into solid blocks
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, global_position + target_offset, 1)
	query.exclude = [self]
	var hit = space_state.intersect_ray(query)
	var final_pos = global_position + target_offset
	if hit:
		final_pos = hit.position - target_offset.normalized() * 16.0
		
	global_position = final_pos
	velocity = Vector2(dir * 180.0, -100.0)
	
	# Brief i-frames
	GameManager.is_invulnerable = true
	var inv_tween = create_tween()
	inv_tween.tween_interval(0.30)
	inv_tween.tween_callback(func(): GameManager.is_invulnerable = false)
	
	BossGhostTrail.spawn_ghost(self, anim, Color(0.4, 0.8, 1.0, 0.8), 0.30)
	_spawn_teleport_effect(global_position)
	
	SoundManager.play_sfx("teleport")
	SoundManager.play_sfx_pitched("crystal", 1.4)
	GameManager.pop_floating_text("CHRONOS SHADOW STEP!", global_position + Vector2(0, -35), Color(0.6, 0.9, 1.0))
	GameManager.add_rebound(15.0)

func _spawn_teleport_effect(pos: Vector2) -> void:
	var effect = Sprite2D.new()
	var tex = load("res://assets/effects/projectiles/teleport_vortex.png")
	if tex:
		effect.texture = tex
	effect.global_position = pos
	effect.top_level = true
	effect.scale = Vector2(0.3, 0.3)
	effect.modulate = Color(0.6, 0.2, 1.0, 0.8)
	get_parent().add_child(effect)
	var tween = effect.create_tween()
	tween.tween_property(effect, "scale", Vector2(1.2, 1.2), 0.25)
	tween.parallel().tween_property(effect, "modulate:a", 0.0, 0.25)
	tween.tween_callback(effect.queue_free)

func _update_animation() -> void:
	# Overdrive golden brilliance
	if GameManager.is_overdrive and not is_spawning:
		anim.modulate = Color(1.25, 1.15, 0.5)
	elif not is_parrying and not GameManager.is_invulnerable:
		anim.modulate = Color.WHITE

	if attack_timer > 0.0:
		attack_timer -= get_process_delta_time()
		anim.play("attack")
		return
	else:
		is_attacking = false

	if not is_on_floor():
		if velocity.y < 0:
			anim.play("jump")
		else:
			anim.play("fall")
	else:
		if abs(velocity.x) > 10.0:
			anim.play("run")
		else:
			anim.play("idle")

func take_damage(amount: float, source_pos: Vector2 = Vector2.ZERO) -> void:
	if is_dead or is_spawning:
		return
		
	# Timed Parry Defense: If active, perfectly deflects incoming damage!
	if is_parrying:
		SoundManager.play_sfx_pitched("crystal", 1.8)
		SoundManager.play_sfx("victory")
		GameManager.hit_stop(0.08)
		GameManager.pop_floating_text("PARRY DEFLECT!", global_position + Vector2(0, -30), Color(1.0, 0.9, 0.2))
		GameManager.add_rebound(40.0)
		return

	if GameManager.take_damage(amount):
		if source_pos != Vector2.ZERO:
			var kb_dir = (global_position.x - source_pos.x)
			velocity.x = (1.0 if kb_dir >= 0 else -1.0) * 160.0
			velocity.y = -140.0
		_play_hurt_effect()

func stun(duration: float = 1.5) -> void:
	if is_dead or is_spawning:
		return
	if is_parrying:
		GameManager.pop_floating_text("STUN PUSHED BACK!", global_position + Vector2(0, -35), Color(1.0, 0.9, 0.2))
		SoundManager.play_sfx_pitched("crystal", 1.8)
		GameManager.add_rebound(30.0)
		return
	is_stunned = true
	stun_timer = maxf(stun_timer, duration)
	GameManager.pop_floating_text("STUNNED!", global_position + Vector2(0, -30), Color(1.0, 0.85, 0.1))
	SoundManager.play_sfx("lightning")
	_show_stun_visual()

func clear_stun() -> void:
	is_stunned = false
	stun_timer = 0.0
	if stun_indicator and is_instance_valid(stun_indicator):
		stun_indicator.queue_free()
		stun_indicator = null
	if not is_dead:
		anim.modulate = Color.WHITE

func _show_stun_visual() -> void:
	if not stun_indicator or not is_instance_valid(stun_indicator):
		stun_indicator = Sprite2D.new()
		var tex = load("res://assets/effects/projectiles/stun_spark.png")
		if tex:
			stun_indicator.texture = tex
		stun_indicator.position = Vector2(0, -28)
		add_child(stun_indicator)
	anim.modulate = Color(1.3, 1.2, 0.3)

func _play_hurt_effect() -> void:
	anim.play("hurt")
	GameManager.is_invulnerable = true
	var tween = create_tween().set_loops(4)
	tween.tween_property(anim, "modulate:a", 0.3, 0.12)
	tween.tween_property(anim, "modulate:a", 1.0, 0.12)
	await tween.finished
	GameManager.is_invulnerable = false

func _on_player_died() -> void:
	clear_stun()
	is_dead = true
	velocity = Vector2.ZERO
	anim.play("death")

func _on_player_respawned() -> void:
	_play_respawn()

func _play_respawn() -> void:
	clear_stun()
	is_dead = false
	is_spawning = true
	is_parrying = false
	velocity = Vector2.ZERO
	if GameManager.has_checkpoint:
		global_position = GameManager.active_checkpoint_pos
	else:
		global_position = initial_spawn_pos
		
	anim.play("respawn")
	GameManager.is_invulnerable = true
	
	await anim.animation_finished
	is_spawning = false
	
	var tween = create_tween().set_loops(6)
	tween.tween_property(anim, "modulate:a", 0.4, 0.15)
	tween.tween_property(anim, "modulate:a", 1.0, 0.15)
	await tween.finished
	GameManager.is_invulnerable = false
	anim.modulate.a = 1.0

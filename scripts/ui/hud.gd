extends CanvasLayer

@onready var hp_bar: TextureProgressBar = $HUDPanel/VBoxBars/HPBar
@onready var hp_label: Label = $HUDPanel/VBoxBars/HPBar/HPLabel
@onready var mp_bar: TextureProgressBar = $HUDPanel/VBoxBars/MPBar
@onready var mp_label: Label = $HUDPanel/VBoxBars/MPBar/MPLabel
@onready var crystal_label: Label = $HUDPanel/HBoxCrystals/CrystalLabel
@onready var death_label: Label = $HUDPanel/HBoxStats/DeathLabel if has_node("HUDPanel/HBoxStats/DeathLabel") else null
@onready var respawn_label: Label = $HUDPanel/HBoxStats/RespawnLabel if has_node("HUDPanel/HBoxStats/RespawnLabel") else null

# Abilities: Fireball [J] and Ice Blast [K]
@onready var cd_fireball: TextureProgressBar = $AbilitiesBar/SlotFireball/CDProgress
@onready var cd_ice: TextureProgressBar = $AbilitiesBar/SlotIce/CDProgress

# Boss bar
@onready var boss_container: VBoxContainer = $BossContainer
@onready var boss_name_label: Label = $BossContainer/BossNameLabel
@onready var boss_bar: TextureProgressBar = $BossContainer/BossBar

# Toast & Tutorial
@onready var toast_label: Label = $ToastLabel
@onready var tutorial_box: Control = $TutorialBox if has_node("TutorialBox") else null
@onready var tutorial_message: Label = $TutorialBox/VBox/Message if has_node("TutorialBox/VBox/Message") else null

var player_ref: Player = null

func _ready() -> void:
	GameManager.player_health_changed.connect(_on_hp_changed)
	GameManager.player_mana_changed.connect(_on_mp_changed)
	GameManager.crystals_changed.connect(_on_crystals_changed)
	GameManager.notification_posted.connect(_on_notification)
	GameManager.tutorial_posted.connect(_on_tutorial_posted)
	GameManager.tutorial_cleared.connect(_on_tutorial_cleared)
	GameManager.boss_spawned.connect(_on_boss_spawned)
	GameManager.boss_health_changed.connect(_on_boss_hp_changed)
	GameManager.boss_defeated.connect(_on_boss_defeated)
	GameManager.death_count_changed.connect(_on_death_count_changed)
	GameManager.respawn_count_changed.connect(_on_respawn_count_changed)

	boss_container.visible = false
	toast_label.visible = false
	if tutorial_box:
		tutorial_box.visible = false
	
	_on_hp_changed(GameManager.player_hp, GameManager.player_max_hp)
	_on_mp_changed(GameManager.player_mp, GameManager.player_max_mp)
	_on_crystals_changed(GameManager.crystals)
	_update_death_respawn_labels()

func _process(_delta: float) -> void:
	if not player_ref:
		player_ref = get_tree().get_first_node_in_group("player") as Player
	if player_ref:
		_update_cooldown_visuals()

func _update_cooldown_visuals() -> void:
	if not player_ref:
		return
	if player_ref.cooldowns.has("fireball"):
		var fb_cd = player_ref.cooldowns["fireball"]
		var fb_max = GameManager.ABILITY_DATA["fireball"]["cooldown"]
		cd_fireball.value = (fb_cd / fb_max) * 100.0 if fb_cd > 0 else 0.0

	if player_ref.cooldowns.has("ice_blast"):
		var ice_cd = player_ref.cooldowns["ice_blast"]
		var ice_max = GameManager.ABILITY_DATA["ice_blast"]["cooldown"]
		cd_ice.value = (ice_cd / ice_max) * 100.0 if ice_cd > 0 else 0.0

func _on_hp_changed(hp: float, max_hp: float) -> void:
	hp_bar.max_value = max_hp
	hp_bar.value = hp
	hp_label.text = "HP: %d / %d" % [int(hp), int(max_hp)]

func _on_mp_changed(mp: float, max_mp: float) -> void:
	mp_bar.max_value = max_mp
	mp_bar.value = mp
	mp_label.text = "MP: %d / %d" % [int(mp), int(max_mp)]

func _on_crystals_changed(count: int) -> void:
	crystal_label.text = "x %d" % count

func _on_death_count_changed(_count: int) -> void:
	_update_death_respawn_labels()

func _on_respawn_count_changed(_count: int) -> void:
	_update_death_respawn_labels()

func _update_death_respawn_labels() -> void:
	if death_label:
		death_label.text = "💀 Deaths: %d" % GameManager.death_count
	if respawn_label:
		respawn_label.text = "🔄 Respawns: %d" % GameManager.respawn_count

func _on_boss_spawned(b_name: String, max_hp: float) -> void:
	boss_container.visible = true
	boss_name_label.text = b_name
	boss_bar.max_value = max_hp
	boss_bar.value = max_hp

func _on_boss_hp_changed(cur_hp: float, max_hp: float) -> void:
	boss_bar.max_value = max_hp
	boss_bar.value = cur_hp

func _on_boss_defeated() -> void:
	boss_container.visible = false

func _on_notification(text: String) -> void:
	toast_label.text = text
	toast_label.visible = true
	toast_label.modulate.a = 1.0
	var tween = create_tween()
	tween.tween_interval(2.5)
	tween.tween_property(toast_label, "modulate:a", 0.0, 0.5)
	await tween.finished
	toast_label.visible = false

func _on_tutorial_posted(text: String) -> void:
	if tutorial_box and tutorial_message:
		tutorial_message.text = text
		tutorial_box.visible = true
		tutorial_box.modulate.a = 0.0
		var tween = create_tween()
		tween.tween_property(tutorial_box, "modulate:a", 1.0, 0.2)

func _on_tutorial_cleared() -> void:
	if tutorial_box and tutorial_box.visible:
		var tween = create_tween()
		tween.tween_property(tutorial_box, "modulate:a", 0.0, 0.2)
		await tween.finished
		if is_instance_valid(tutorial_box):
			tutorial_box.visible = false

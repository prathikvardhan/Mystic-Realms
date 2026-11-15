extends Area2D

class_name GodRelicShrine

@export var is_active: bool = false
@onready var sprite: Sprite2D = $Sprite2D
@onready var aura_particles: CPUParticles2D = $AuraParticles

func _ready() -> void:
	add_to_group("shrines")
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	if is_active:
		_set_activated_visuals()

func activate_shrine() -> void:
	if is_active:
		return
	is_active = true
	
	SoundManager.play_sfx("victory")
	SoundManager.play_sfx("checkpoint")
	GameManager.hit_stop(0.12)
	
	# Bestow Godly Stats to Player
	GameManager.player_max_hp = 1500.0
	GameManager.player_hp = 1500.0
	GameManager.player_max_mp = 500.0
	GameManager.player_mp = 500.0
	GameManager.mana_regen_rate = 60.0
	GameManager.speed_multiplier += 0.35
	GameManager.damage_multiplier += 0.60
	GameManager.rebound_gain_multiplier += 0.50
	
	GameManager.player_health_changed.emit(GameManager.player_hp, GameManager.player_max_hp)
	GameManager.player_mana_changed.emit(GameManager.player_mp, GameManager.player_max_mp)
	
	GameManager.pop_floating_text("✦ GOD RELIC AWAKENED! +1500 HP & GODLY SPELL POWER! ✦", global_position + Vector2(0, -50), Color(1.0, 0.9, 0.2))
	GameManager.post_notification("👑 SECRET ROOM DISCOVERED! ULTIMATE GOD STATS AWAKENED! 👑")
	
	_set_activated_visuals()

func _set_activated_visuals() -> void:
	sprite.modulate = Color(2.0, 1.6, 0.4)
	aura_particles.color = Color(1.0, 0.85, 0.2, 0.9)
	aura_particles.amount = 48
	var tween = create_tween().set_loops()
	tween.tween_property(sprite, "scale", Vector2(1.15, 1.15), 0.6)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.6)

func _on_body_entered(body: Node2D) -> void:
	if not is_active and body.is_in_group("player"):
		activate_shrine()

func _on_area_entered(area: Area2D) -> void:
	if not is_active and area.is_in_group("player_projectiles"):
		activate_shrine()

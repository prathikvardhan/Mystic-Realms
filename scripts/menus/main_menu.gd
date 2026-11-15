extends Control

@onready var stats_label: Label = $VBoxHeader/CareerStats if has_node("VBoxHeader/CareerStats") else null

func _ready() -> void:
	SoundManager.play_music("dark_dream")
	if stats_label:
		stats_label.text = "💀 Career Deaths: %d  |  🔄 Respawns: %d" % [GameManager.death_count, GameManager.respawn_count]

func _on_start_pressed() -> void:
	SoundManager.play_sfx("click")
	GameManager.start_level(8)

func _on_tutorial_pressed() -> void:
	SoundManager.play_sfx("click")
	GameManager.start_level(0)

func _on_intro_pressed() -> void:
	SoundManager.play_sfx("click")
	get_tree().change_scene_to_file("res://scenes/intro/intro_splash_3d.tscn")

func _on_quit_pressed() -> void:
	SoundManager.play_sfx("click")
	get_tree().quit()

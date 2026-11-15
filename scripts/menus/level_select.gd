extends Control

func _ready() -> void:
	SoundManager.play_music("dark_dream")

func _on_tutorial_pressed() -> void:
	SoundManager.play_sfx("click")
	GameManager.start_level(0)

func _on_final_battle_pressed() -> void:
	SoundManager.play_sfx("click")
	GameManager.start_level(8)

func _on_back_pressed() -> void:
	SoundManager.play_sfx("click")
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")

extends Control

@onready var main = $"../../"

func _on_resume_pressed() -> void:
	main.paused_menu()


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/main_menu.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()

extends Control

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/Pre-Alpha/pre_alpha.tscn")
	Engine.time_scale = 1
func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/options_menu.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()

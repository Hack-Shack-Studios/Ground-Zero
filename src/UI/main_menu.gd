class_name MainMenu
extends Control

## Main Menu
##
## Handles Play, Options, Credits, and Quit buttons. The buttons explain themselves.

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/Pre-Alpha/pre_alpha.tscn")
	Engine.time_scale = 1
	
	
func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/options.tscn")


func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/credits.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()

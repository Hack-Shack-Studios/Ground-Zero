class_name OptionsMenu
extends Control

## Handles the Options of the Menu 
##
## Handles the Volume, About Us Page, and Back button, they all explain themselves


func _on_volume_pressed() -> void:
	pass # Replace with function body.


func _on_about_us_pressed() -> void:
	pass # Replace with function body.


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/main_menu.tscn")

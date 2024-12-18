class_name Credits
extends Control

## Credits menu of the game
##
## Gives credit to all the hard workers on our team

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/main_menu.tscn")

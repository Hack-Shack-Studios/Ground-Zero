extends Control


func _on_resume_pressed() -> void:
	pass # Replace with function body.


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/main_menu.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()

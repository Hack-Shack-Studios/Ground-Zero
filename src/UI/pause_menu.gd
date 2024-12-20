class_name Pause_Menu
extends Control

## Pause Menu During Game
##
## Manages the pause menu that can occur during the game

@onready var main = $"../../"


func _on_resume_pressed() -> void:
    main.paused_menu()
    ButtonNoise.play()


func _on_main_menu_pressed() -> void:
    get_tree().change_scene_to_file("res://UI/main_menu.tscn")
    MainMenuMusic.play()
    ButtonNoise.play()


func _on_quit_pressed() -> void:
    ButtonNoise.play()
    get_tree().quit()


func _on_resume_mouse_entered() -> void:
    ButtonHover.play()


func _on_main_menu_mouse_entered() -> void:
    ButtonHover.play()


func _on_quit_mouse_entered() -> void:
    ButtonHover.play()

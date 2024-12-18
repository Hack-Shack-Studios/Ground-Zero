extends Control

## Main Menu
##
## Handles Play, Options, Credits, and Quit buttons. The buttons explain themselves.


func _ready() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/Pre-Alpha/pre_alpha.tscn")
	Engine.time_scale = 1
	MainMenuMusic.stop()
	ButtonNoise.play()
	
func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/options.tscn")
	ButtonNoise.play()

func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/credits.tscn")
	ButtonNoise.play()

func _on_quit_pressed() -> void:
	get_tree().quit()
	ButtonNoise.play()


func _on_start_mouse_entered() -> void:
	ButtonHover.play()


func _on_options_mouse_entered() -> void:
	ButtonHover.play()


func _on_credits_mouse_entered() -> void:
	ButtonHover.play()


func _on_quit_mouse_entered() -> void:
	ButtonHover.play()

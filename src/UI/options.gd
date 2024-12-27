class_name Options
extends Control

## Options menu for main menu
##
## Buttons speak for themselves

@onready var main_menu_music = "res://Music/main_menu_music.tscn"

func _on_back_pressed() -> void:
    ButtonNoise.play()
    get_tree().change_scene_to_file("res://UI/main_menu.tscn")

#func _on_volume_value_changed(value: float) -> void:
    #for sound in sounds:
        #sound.volume_db = value


func _on_resolutions_item_selected(index: int) -> void:
    match index:
        0:
            DisplayServer.window_set_size(Vector2i(1920,1080))
        1:
            DisplayServer.window_set_size(Vector2i(1600,900))
        2:
            DisplayServer.window_set_size(Vector2i(1280,720))
    ButtonNoise.play()


func _on_back_mouse_entered() -> void:
    ButtonHover.play()

func _on_check_button_toggled(toggled_on: bool) -> void:
    if toggled_on:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
    elif !toggled_on:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_master_mouse_entered() -> void:
    ButtonHover.play()



func _on_resolutions_mouse_entered() -> void:
    ButtonHover.play()



func _on_sensitivity_mouse_entered() -> void:
    ButtonHover.play()



func _on_music_mouse_entered() -> void:
    ButtonHover.play()



func _on_sfx_mouse_entered() -> void:
    ButtonHover.play()



func _on_check_button_mouse_entered() -> void:
    ButtonHover.play()

func _on_tree_entered() -> void:
    if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
       $"Full Screen/CheckButton".button_pressed = true
    else:
        $"Full Screen/CheckButton".button_pressed = false

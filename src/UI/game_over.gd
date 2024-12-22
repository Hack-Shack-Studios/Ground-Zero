extends Control


func _ready() -> void:
    if Global.win:
        on_win()
    Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED) #Allows the mouse to be used for some reason (not sure)

func _on_restart_button_pressed() -> void:
    Global.win = false #IMPORTANT: If this isnt changed then subsequent runs will be wins if this current run was a win
    get_tree().change_scene_to_file("res://Levels/Pre-Alpha/pre_alpha.tscn")
    ButtonNoise.play()
    Global.score = 0

func _on_menu_button_pressed() -> void:
    Global.win = false #IMPORTANT: If this isnt changed then subsequent runs will be wins if this current run was a win
    get_tree().change_scene_to_file("res://UI/main_menu.tscn")
    MainMenuMusic.play() #Ensures the menu music plays
    ButtonNoise.play()

##Changes the text to appropriate win text instead of game over
func on_win():
    $game_over_label.text = "YOU WIN"
    $game_over_label.add_theme_color_override("font_color", Color(0, 1, 0))
    print("You won")
    Global.score = 0

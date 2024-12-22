extends Control

@export var fade_in_time: float
@export var fade_out_time: float
@export var duration: float
@export var logo_texture: TextureRect
@export var next_scene_path: String = "res://UI/main_menu.tscn"

func _ready():
	MainMenuMusic.stop()
	logo_texture.modulate.a = 0.0 #Optional alpha value is set to 0 for transparency
	text_tween()

##FADE IN LOGO WITH ALPHA VALUES AND TIMERS
func logo_fade():
	$skip_button.visible = false
	var tween = self.create_tween() #.set_trans() optionally change transitions types
	tween.tween_property(logo_texture, "modulate:a", 1.0, fade_in_time)
	tween.tween_interval(duration)
	tween.tween_property(logo_texture, "modulate:a", 0.0, fade_out_time)
	await tween.finished
	MainMenuMusic.play()
	get_tree().change_scene_to_file(next_scene_path)
	
##LORE DUMP (POTENTIALLY)
func text_tween():
	$lore_dump.visible_characters = 0
	var tween = self.create_tween()
	tween.tween_property($lore_dump, "visible_characters", 159, 10.0)
	await tween.finished
	await get_tree().create_timer(1.0).timeout
	$lore_dump.text = "> Foreign Planatery Body detected approximately 5 lightyears away.
> ATMOSPHERE COMPOSITION: null.
> LIFEFORM PRESENCE: [color=9f3fe8]null[/color].
> Activating Autopilot Systems..." #there's probably a more efficient way to change one word in the text...
	await get_tree().create_timer(2.0).timeout
	tween.kill() #elimitate any potential tween conflicts
	$lore_dump.visible = false
	logo_fade()


func _on_skip_button_pressed() -> void:
	$lore_dump.visible = false
	$skip_button.visible = false
	logo_fade()

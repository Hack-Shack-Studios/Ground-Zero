extends AudioStreamPlayer

## Handles the main menu music
##
## In order to let the music play from multiple scenes,
## we must use a global scene

const LEVEL_MUSIC = preload("res://Music/Combat/NonBossFight.wav")


func _play_music(music: AudioStream, volume = 0.0):
    if stream == music:
        return
    else:
        stream = music
        volume_db = volume
        play()


func play_music_level():
    _play_music(LEVEL_MUSIC)


func _on_finished() -> void:
    play() # Replace with function body.

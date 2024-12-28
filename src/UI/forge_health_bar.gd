extends ProgressBar

var child_health_bar: ProgressBar
var decay: Timer
var stun: Timer
var prev_health = max_value
var curr_health = value

func _ready():
    child_health_bar = $ForgeSecondaryBar
    child_health_bar.value = prev_health
    decay = $decay_timer
    stun = $stun_timer

func _on_value_changed(new_value: float) -> void:
    curr_health = new_value
    stun.start()

func _on_decay_timer_timeout() -> void:
    var tween = self.create_tween()
    tween.tween_property(child_health_bar, "value", curr_health, 1.0)
    await tween.finished
    tween.kill()

func _on_stun_timer_timeout() -> void:
    if child_health_bar.value > curr_health:
        var difference = child_health_bar.value - curr_health
        if difference > 10:
            decay.wait_time = 0.1
        else:
            decay.wait_time = 0.4
        decay.start()

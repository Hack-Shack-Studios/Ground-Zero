extends Label


# TODO: Use signals
func _process(_delta: float) -> void:
    text = "SCORE: " + str(Global.score)

func _ready() -> void:
    text = "SCORE: " + str(Global.score)

func update_score():
    text = "SCORE: " + str(Global.score)

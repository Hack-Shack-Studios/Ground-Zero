extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text = "SCORE: " + str(Global.score)

func update_score():
	text = "SCORE: " + str(Global.score)

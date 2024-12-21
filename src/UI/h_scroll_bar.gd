extends HScrollBar

@onready var text_bar = $"../NumberSensitivity"
@onready var player: CharacterBody3D




func _ready() -> void:
    player = get_tree().get_first_node_in_group("player")
    text_bar.text = str("%.2f" % Global.sensitivity)
    value = Global.sensitivity

func _process(_delta: float) -> void:
    if Input.is_action_pressed("enter"):
        value = float(text_bar.text)

func _on_value_changed(new_value: float) -> void:
    text_bar.text = str(float("%.2f" % new_value))
    Global.sensitivity = new_value

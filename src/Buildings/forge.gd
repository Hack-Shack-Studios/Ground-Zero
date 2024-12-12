extends StaticBody3D

var health = 30
signal forge_hit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _get_health() -> int:
	return health

func hit() -> void:
	health -= 1
	emit_signal("forge_hit")
	if health <= 0:
		# Game Restarts
		get_tree().reload_current_scene() 

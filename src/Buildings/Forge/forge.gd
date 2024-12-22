class_name Forge
extends StaticBody3D

## Handles Forge components
##
## The Forge is a machine that must be protected by the players, and is targeted by
## the AI. The forge will handle a variety of things in this script, mainly the forge's
## health and upgrades

signal forge_hit

const MAX_HACKERS: int = 2

var minimum_health: int = 0
var damage_amount: int = 1
var health: int = 30
var robots_hacking: int


@onready var hacked_timer = $Hacked


## Gets the current health of the forge
func _get_health() -> int:
	return health


## Occurs whenever enemy attacks the forge, reducing the health by 1
## If the forge's health every reaches 0, the scene restarts
func hit() -> void:
	emit_signal("forge_hit")
	for hackers in robots_hacking:
		health -= damage_amount
		print("forge hacked")

	if health <= minimum_health:
		print(str(health) + " <= " +str(minimum_health))
		get_tree().change_scene_to_file("res://UI/game_over.tscn") #GO TO: Game Over sceen

	hacked_timer.start()


func _on_hacked_timeout() -> void:
	hit()

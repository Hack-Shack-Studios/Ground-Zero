class_name Forge
extends StaticBody3D

## Handles Forge components 
##
## The Forge is a machine that must be protected by the players, and is targeted by 
## the AI. The forge will handle a variety of things in this script, mainly the forge's
## health and upgrades

signal forge_hit

var minimum_health: int = 0
var damage_amount: int = 1
var health: int = 30

## Gets the current health of the forge
func _get_health() -> int:
	return health

## Occurs whenever enemy attacks the forge, reducing the health by 1
## If the forge's health every reaches 0, the scene restarts
func hit() -> void:
	emit_signal("forge_hit")
	health -= damage_amount
	
	if health <= minimum_health:
		get_tree().reload_current_scene() 

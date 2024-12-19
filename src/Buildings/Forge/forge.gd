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
var robots_hacking: int
var current_robots
## Gets the current health of the forge
func _get_health() -> int:
	return health

## Occurs whenever enemy attacks the forge, reducing the health by 1
## If the forge's health every reaches 0, the scene restarts
func hit() -> void:	
	if robots_hacking == 0:
		print("no hackers. returning")
		return
	if robots_hacking > 2:
		print("too many hackers, limiting to 2")
		robots_hacking = 2
		
	emit_signal("forge_hit")
	for hackers in robots_hacking:
		health -= damage_amount
		print("forge hacked")
		await (get_tree().create_timer(1.0).timeout)	
	
	if health <= minimum_health:
		get_tree().reload_current_scene() 
		print(str(health) + " <= " +str(minimum_health))
		return
	hit()

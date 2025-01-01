extends State
class_name ChasingForge

## Handles the state for chasing the forge
##
## Chasing the forge

const ATTACK_RANGE := 5.0

# TODO: Fix this terrible temp solution
@export var enemy: CharacterBody3D

@export var move_speed := 2.0
@export var player_path = "/root/World/Map/Player"
@export var forge_path := "/root/World/Map/Forge"
@export var animation: AnimationPlayer

var gravity = 9.8
var player: CharacterBody3D
var forge = null


func enter():
	player = get_node(player_path)
	forge = get_node(forge_path)

	#print("Chasing Forge")

func exit():
	pass

func update(_delta: float):
	pass


func physics_update(delta: float):
	enemy.move_and_slide()
	enemy.velocity = Vector3.ZERO

	animation.play("Walking")

	if forge:
		enemy.nav_agent.set_target_position(forge.global_transform.origin) # Goes toward the player
		var next_nav_point = enemy.nav_agent.get_next_path_position() # updates many of the agent's internal states and properties
		enemy.velocity = (next_nav_point - enemy.global_transform.origin).normalized() * move_speed # Sets velocity direction towards the target
		enemy.rotation.y = lerp_angle(enemy.rotation.y, atan2(-enemy.velocity.x, -enemy.velocity.z), delta * 10.0) # Turn to face the player

	var distance_to_forge = enemy.global_position.distance_to(forge.global_position)
	var distance_to_player = enemy.global_position.distance_to(player.global_position)

	if forge.robots_hacking > 1 and not player.dead:
		Transitioned.emit(self, "ChasingPlayer")
	elif distance_to_forge <= 4:
		Transitioned.emit(self, "Hacking")
	elif distance_to_player < distance_to_forge:
		Transitioned.emit(self, "ChasingPlayer")
	# else keep walking towards forge

# TODO: Add safe_velocity to have avoidance work better #2
func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	pass # Replace with function body.

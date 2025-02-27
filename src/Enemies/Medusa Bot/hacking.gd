extends State
class_name Hacking

## Handles the state for chasing the forge
##
## Chasing the forge


const SHOOT_RANGE := 5.0

@export var enemy: CharacterBody3D


@export var animation: AnimationPlayer
@export var forge_path := "/root/World/Map/Forge"


var gravity = 9.8
var forge: StaticBody3D
var hack_delay := 1.0
var hacking = false

func enter():
	forge = get_node(forge_path)
	forge.hit()
	forge.robots_hacking += 1
	enemy.is_hacking = true
	enemy.chasing_player = false
	enemy.look_at(Vector3(forge.global_position.x, enemy.global_position.y, forge.global_position.z), Vector3.UP)

	animation.play("StartHacking")

	if enemy:
		await get_tree().create_timer(1.4833).timeout

	print("Hacking")


func exit():
	pass

func update(_delta: float):
	pass


func physics_update(_delta: float):
	enemy.velocity = Vector3.ZERO

	animation.play("ConstantHacking")

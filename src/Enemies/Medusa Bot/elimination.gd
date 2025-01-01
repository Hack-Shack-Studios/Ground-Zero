extends State
class_name Elimination

## Handles the state for the medusa bot getting eliminated
##
## Bot getting eliminated

signal enemy_death

const EXPLODE_DURATION := 1.5

@export var animation: AnimationPlayer

@export var enemy: CharacterBody3D


@export var forge_path := "/root/World/Map/NavigationRegion3D/Forge"

var forge = StaticBody3D

@onready var laser_mesh = $"../../Laser/laserbeam"


func enter():
	enemy.enemy_dead = true
	laser_mesh.visible = false
	forge = get_node(forge_path)
	animation.play("Death")
	await get_tree().create_timer(EXPLODE_DURATION).timeout
	enemy.queue_free()
	emit_signal("enemy_death")

	print("Eliminated")

func exit():
	pass


func update(_delta: float):
	pass


func physics_update(_delta: float):
	pass

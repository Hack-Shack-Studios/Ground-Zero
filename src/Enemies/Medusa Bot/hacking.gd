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

func enter():
    forge = get_node(forge_path)
    forge.hit()
    forge.robots_hacking += 1
    enemy.is_hacking = true
    enemy.chasing_player = false

    animation.play("StartHacking")
    await get_tree().create_timer(1.4833).timeout

    print("Hacking")


func exit():
    pass

func update(_delta: float):
    pass


func physics_update(_delta: float):
    enemy.velocity = Vector3.ZERO

    if not enemy.is_on_floor():
        enemy.velocity.y -= gravity

    animation.play("ConstantHacking")

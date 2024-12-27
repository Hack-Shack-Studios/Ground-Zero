extends State
class_name Idle

## Handles the state for chasing the forge
##
## Chasing the forge

const ATTACK_RANGE := 5.0

@export var enemy: CharacterBody3D
@export var move_speed := 2.0
@export var player_path = "/root/World/Map/Player"
@export var forge_path := "/root/World/Map/NavigationRegion3D/Forge"
@export var animation: AnimationPlayer

var gravity = 9.8
var player: CharacterBody3D
var forge = null


func enter():
    player = get_node(player_path)
    forge = get_node(forge_path)
    enemy.velocity = Vector3.ZERO

    print("Idle")

func exit():
    pass

func update(_delta: float):
    pass


func physics_update(delta: float):

    if player:
        Transitioned.emit(self, "ChasingPlayer")
    elif forge:
        Transitioned.emit(self, "ChasingForge")


# TODO: Add safe_velocity to have avoidance work better #2
func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
    pass # Replace with function body.

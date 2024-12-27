extends State
class_name Elimination

## Handles the state for the medusa bot getting eliminated
##
## Bot getting eliminated

const EXPLODE_DURATION := 1.5

@export var animation: AnimationPlayer
@export var enemy: CharacterBody3D
@export var forge_path := "/root/World/Map/NavigationRegion3D/Forge"

var forge = StaticBody3D

@onready var laser_mesh = $"../../Laser/MeshInstance3D"


func enter():
    laser_mesh.visible = false
    forge = get_node(forge_path)

    animation.play("hurt")
    await get_tree().create_timer(EXPLODE_DURATION).timeout
    get_parent().get_parent().emit_signal("enemy_death")
    enemy.queue_free()

    print("Eliminated")

func exit():
    # When killed, has a low % drop rate of its laser head falling

    # get_tree().add_child(robot_head)
    pass


func update(_delta: float):
    pass


func physics_update(_delta: float):
    pass

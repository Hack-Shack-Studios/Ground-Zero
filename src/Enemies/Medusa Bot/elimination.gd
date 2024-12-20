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


func enter():
    forge = get_node(forge_path)

    animation.play("hurt")
    await get_tree().create_timer(EXPLODE_DURATION).timeout
    enemy.queue_free()

    print("eliminated")


func exit():
    pass


func update(_delta: float):
    pass


func physics_update(_delta: float):
    pass

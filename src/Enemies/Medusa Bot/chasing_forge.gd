extends State
class_name ChasingForge

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
    player = get_node_or_null(player_path)
    forge = get_node_or_null(forge_path)

    if not player:
        push_error("Player node not found at path: " + player_path)
    if not forge:
        push_error("Forge node not found at path: " + forge_path)

    print("Chasing Forge")

func exit():
    pass

func update(_delta: float):
    pass

func physics_update(delta: float):
    # Wait until the navigation map is ready
    if not enemy.nav_agent.is_navigation_finished():
        return

    enemy.move_and_slide()
    enemy.velocity = Vector3.ZERO

    animation.play("walk")

    if forge:
        # Set the target position to the forge's location
        enemy.nav_agent.set_target_position(forge.global_transform.origin)

        # Try to get the next path position
        var next_nav_point = enemy.nav_agent.get_next_path_position()
        if next_nav_point != Vector3.ZERO:  # Ensure it's a valid point
            enemy.velocity = (next_nav_point - enemy.global_transform.origin).normalized() * move_speed
            enemy.rotation.y = lerp_angle(
                enemy.rotation.y,
                atan2(-enemy.velocity.x, -enemy.velocity.z),
                delta * 10.0
            )  # Rotate to face the target

    # Handle state transitions
    if forge and player:
        var distance_to_forge = enemy.global_position.distance_to(forge.global_position)
        var distance_to_player = enemy.global_position.distance_to(player.global_position)

        if forge.robots_hacking > 1 and not player.dead:
            Transitioned.emit(self, "ChasingPlayer")
        elif distance_to_forge <= 4:
            Transitioned.emit(self, "Hacking")

# TODO: Add safe_velocity to have avoidance work better #2
func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
    pass  # Replace with function body.

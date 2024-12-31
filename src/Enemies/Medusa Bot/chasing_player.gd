extends State
class_name ChasingPlayer

## Handles the state for chasing the player
##
## The Medusa bot chases the player based on a few factors,
## it is handled here
##
## Chasing the player will be the "base state", as defeating
## the players is high priority, with hacking kept in mind

const ATTACK_RANGE := 5.0

@export var enemy: CharacterBody3D


@export var move_speed := 2.0
var player_path = "/root/World/Map/Player"
var forge_path := "/root/World/Map/NavigationRegion3D/Forge"
@export var animation: AnimationPlayer

var gravity = 9.8
var player: CharacterBody3D
var forge = StaticBody3D
var move_direction: float
var wanter_time: float
var is_wandering := false
var direction_offset := 3.0

# Track the navigation state
var nav_map_ready: bool = false

@onready var chasing_player_timer = $"../../ChasingPlayerTimer"

func enter():
    player = get_node(player_path)
    forge = get_node(forge_path)
    enemy.chasing_player = true
    chasing_player_timer.start()
    is_wandering = false

    #print("Chasing player")

func exit():
    chasing_player_timer.stop()
    is_wandering = false


func update(_delta: float):
    pass


func physics_update(delta: float):
    enemy.move_and_slide()

    animation.play("Walking")

    if is_wandering:

        # Whichever direction they are going, the will turn left and right of the other
        if abs(enemy.velocity.x) > abs(enemy.velocity.z):
            enemy.velocity.z = move_direction * delta
        else:
            enemy.velocity.x = move_direction * delta

        #print("Manuervering")
    else:
        enemy.nav_agent.set_target_position(player.global_transform.origin) # Goes toward the player
        var next_nav_point = enemy.nav_agent.get_next_path_position() # updates many of the agent's internal states and properties
        enemy.velocity = (next_nav_point - enemy.global_transform.origin).normalized() * move_speed # Sets velocity direction towards the target
        enemy.rotation.y = lerp_angle(enemy.rotation.y, atan2(-enemy.velocity.x, -enemy.velocity.z), delta * 10.0) # Turn to face the player

    var distance_to_forge = enemy.global_position.distance_to(forge.global_position)
    var distance_to_player = enemy.global_position.distance_to(player.global_position)

    # Medusa bot will go towards forge only if there are less than 2 robots
    # currently hacking it, and they are closer to the forge, than they are
    # of the player
    if distance_to_forge <= distance_to_player and forge.robots_hacking < forge.MAX_HACKERS or player.dead:
        Transitioned.emit(self, "ChasingForge")
    # If the medusa bot is within attack range, it will shoot at the player
    elif distance_to_player <= ATTACK_RANGE:
        Transitioned.emit(self, "Shooting")
    # Else keep walking towards player


func _on_chasing_player_timeout() -> void:
    random_velocities()
    is_wandering = !is_wandering


func random_velocities():
    # Random direction between 1 and 3 meters, and 50/50 for left or right(negative or positive)
    move_direction = randf_range(1, 3) * (1 if randf() > 0.5 else -1)

# TODO: Add safe_velocity to have avoidance work better
func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
    pass # Replace with function body.


func _on_map_changed():
    # Set the navigation map state as ready
    nav_map_ready = true

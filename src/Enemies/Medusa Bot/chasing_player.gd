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
@export var player_path = "/root/World/Map/Player"
@export var forge_path := "/root/World/Map/NavigationRegion3D/Forge"
@export var animation: AnimationPlayer

var gravity = 9.8
var player: CharacterBody3D
var forge = StaticBody3D

func enter():
    player = get_node(player_path)
    forge = get_node(forge_path)
    enemy.chasing_player = false

    print("Chasing Player")

func exit():
    pass


func update(_delta: float):
    pass


func physics_update(delta: float):
    enemy.move_and_slide()

    animation.play("walk")

    enemy.nav_agent.set_target_position(player.global_transform.origin) # Goes toward the player
    var next_nav_point = enemy.nav_agent.get_next_path_position() # updates many of the agent's internal states and properties
    enemy.velocity = (next_nav_point - enemy.global_transform.origin).normalized() * move_speed # Sets velocity direction towards the target
    enemy.rotation.y = lerp_angle(enemy.rotation.y, atan2(-enemy.velocity.x, -enemy.velocity.z), delta * 10.0) # Turn to face the player


    ## TODO: Currently the location the enemy is following is
    ## on top of the player model, so the enemy tries to float,
    ## I can't/too tired to find the solution, so i'm just forcing
    ## the bot back to the ground without delta so its instant
    ## Technically should not be a problem with the medusa bot since
    ## they are a ranged enemy, but can def seeing this being a
    ## problem later
    if not enemy.is_on_floor():
        enemy.velocity.y -= gravity

    var distance_to_forge = enemy.global_position.distance_to(forge.global_position)
    var distance_to_player = enemy.global_position.distance_to(player.global_position)

    # Medusa bot will go towards forge only if there are less than 2 robots
    # currently hacking it, and they are closer to the forge, than they are
    # of the player
    if distance_to_forge <= distance_to_player and forge.robots_hacking < 2 or not player.player_alive:
        Transitioned.emit(self, "ChasingForge")
    # If the medusa bot is within attack range, it will shoot at the player
    elif distance_to_player <= ATTACK_RANGE:
        Transitioned.emit(self, "Shooting")
    # Else keep walking towards player


"""
directions = [NE, N, NW, E, SE, S, SW, W]
on_chasing_player_time_out():
    random_direction = rand(directions)
    random_seconds = ran(1, 3)

    for random_seconds:
        maneuver_animation()
        move(random_direction)
        look_at(player)
    chasing_player.start_timer()
"""


func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
    pass # Replace with function body.

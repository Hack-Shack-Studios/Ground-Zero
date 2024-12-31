extends State
class_name Shooting

## Handles the state for chasing the forge
##
## Chasing the forge

const SHOOT_RANGE := 6.0

@export var player_path = "/root/World/Map/Player"
@export var forge_path := "/root/World/Map/Forge"
@export var animation: AnimationPlayer

var gravity = 9.8
var player: CharacterBody3D
var forge = StaticBody3D
var shoot_length := 2.5

# Laser
@onready var laser_ready_timer: Timer = %LaserReady
@onready var laser_finished_timer: Timer = %LaserFinished
@onready var laser_hit_timer: Timer = %LaserHit
@onready var laser: RayCast3D = $"../../Laser"
@onready var laser_mesh = $"../../Laser/MeshInstance3D"
var ready_to_shoot := true
var anchor_down_length := 2
var is_lasering := false
var laser_speed := 4.0

@onready var enemy = $"../.."

func enter():
    player = get_node(player_path)
    forge = get_node(forge_path)
    enemy.chasing_player = true
    enemy.look_at(Vector3(player.global_position.x, enemy.global_position.y, player.global_position.z), Vector3.UP)
    animation.play("shoot")

    print("Shooting")



func exit():
    pass


func update(_delta: float):
    pass


func physics_update(delta: float):
    var pos2d: Vector2 = Vector2(enemy.global_position.x, enemy.global_position.z)
    var player_pos2d: Vector2 = Vector2(player.global_position.x, player.global_position.z)
    var direction = pos2d - player_pos2d
    enemy.rotation.y = lerp_angle(enemy.rotation.y, atan2(direction.x, direction.y), delta / laser_speed)

    if ready_to_shoot:
        if laser_ready_timer.time_left == 0:
            laser_ready_timer.start()

        #animation.play("anchor_down")
        #await get_tree().create_timer(anchor_down_length).timeout
        laser_mesh.visible = true
        enemy.velocity = Vector3.ZERO # Stop moving
        await get_tree().create_timer(shoot_length).timeout # Allows shoot animation to finish

        ## If enemy is IN_RANGE, LOOK_AT(PLAYER), SHOOT LASER, SLOWLY CHASE
        ## Get current position of player
        ## Rotate to players position SLOWLY

        var target = laser.get_collider()
        if laser.is_colliding() and target is CharacterBody3D and target.is_in_group("Player") and laser_hit_timer.is_stopped():


            player.hit()
            laser_hit_timer.start()
            print("Laser collided with player, timer starting")
    else:
        laser_mesh.visible = false

    # Facing player at a constant pace, need to make it find it, and slowly go towards it, using velocity
    #enemy.look_at(Vector3(player.global_position.x, enemy.global_position.y, player.global_position.z), Vector3.UP)

    var distance_to_forge = enemy.global_position.distance_to(forge.global_position)
    var distance_to_player = enemy.global_position.distance_to(player.global_position)

    if distance_to_forge <= distance_to_player and forge.robots_hacking < forge.MAX_HACKERS or player.dead:
        Transitioned.emit(self, "ChasingForge")
    elif distance_to_player > SHOOT_RANGE:
        Transitioned.emit(self, "ChasingPlayer")


func _on_laser_finished_timeout() -> void:
    ready_to_shoot = true


func _on_laser_ready_timeout() -> void:
    ready_to_shoot = false
    laser_finished_timer.start()

    #animation.play("anchor_up")
    #await timer(anchor_down_anim_time).timeout()


func _on_laser_hit_timeout() -> void:
    print("Timer over, hitting player")
    player.hit()

func lerp_angle(from, to, weight):
    return from + short_angle_dist(from, to) * weight

func short_angle_dist(from, to):
    var max_angle = PI * 2
    var difference = fmod(to - from, max_angle)
    return fmod(2 * difference, max_angle) - difference

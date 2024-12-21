class_name MedusaBot
extends CharacterBody3D

## Handles most components reguarding the Medusa Bot
##
## While this is for the medusa bot, most of this code will most like by ported into
## its own Enemy class, since it handles movement towards the player/forge, combot
## range, death, animations, etc... The only things specially towards the Medusa bot
## will be the animaitions type, and the attack ranges

signal enemy_death

const MAX_HACKERS: int = 2 # Max amount of hackers bots can have
const SPEED := 2.0 # speed of bot 
const ATTACK_RANGE := 5.0 # range where needs to start attack
const SHOOT_RANGE := 5.0 # range bot needs to be when hit finishes
const FORGE_EXPLODE_RANGE := 4.0 # Hack Range
const EXPLODE_DELAY_SECS := 1.5 # Get rid of this after hacking is added
const DIE_ANIMATION = 1.5
const HITMARKER_DECAY = 1.0

var FORGE_POSITION # TODO: Make forge constant
var player_died

@export var player_path := "/root/World/Map/Player" # References player location for chasing
@export var forge_path := "/root/World/Map/NavigationRegion3D/Forge" # References forge location for chasing

var player = null # Player node
var forge = null # Forge node
var state_machine # Handles bots animations
var health: int = 6 # Max health of enemy
var is_hacking := false

@onready var nav_agent = $NavigationAgent3D # Handles navigation for the enemy
@onready var anim_tree = $AnimationTree # Handles animations for the bot


# Ran when enemy first spawns 
func _ready() -> void:
    player = get_node(player_path)
    forge = get_node(forge_path)
    state_machine = anim_tree.get("parameters/playback")
    FORGE_POSITION = forge.global_transform.origin
    #player.connect("player_death", _on_player_death)
    player_died = get_parent().get_parent().get_parent().player_died


# Called every frame
func _process(delta: float) -> void:
    ## Gets the current location of the player, forge, and itself
    velocity = Vector3.ZERO
    var forge_distance
    var player_distance
    player_died = get_parent().get_parent().get_parent().player_died #Super class variable that changes when player emits signal
    #player_died = get_parent().get_parent().player_died
    if not player_died:
        var enemy_position = global_transform.origin
        var player_position = player.global_transform.origin
        player_distance = enemy_position.distance_to(player_position)
        ## To avoid bugs, distance to forge minmum is always 0
        forge_distance = (enemy_position.distance_to(FORGE_POSITION))
    else:
        var enemy_position = global_transform.origin
        player_distance = 99999.0 #Effectively makes enemies ignore player when player is "dead"
        forge_distance = enemy_position.distance_to(FORGE_POSITION)
    if forge_distance < 0:
            forge_distance = 0
    # Handles the animation tree for the Medusa bot
    match state_machine.get_current_node():
        "walk":
            ## The enemy will focus either the player or the forge
            ## however, if equal distances, enemy will always prioritize the forge
            if forge_distance < player_distance: # Go towards forge
                nav_agent.set_target_position(FORGE_POSITION)
                var next_nav_point = nav_agent.get_next_path_position()

                velocity = (next_nav_point - global_transform.origin).normalized() * SPEED # Sets velocity direction towards the target
                rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10.0)
                move_and_slide()

            else: # Chase player
                nav_agent.set_target_position(player.global_transform.origin)
                var next_nav_point = nav_agent.get_next_path_position()

                velocity = ((next_nav_point - global_transform.origin).normalized() * SPEED)
                rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10.0)
                move_and_slide()

        "shoot": # When in range of player
            look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)

        "hurt": # When in range of the forge
            if health > 0:
                await get_tree().create_timer(EXPLODE_DELAY_SECS).timeout
                queue_free()
                forge.hit()
            else:
                await get_tree().create_timer(DIE_ANIMATION).timeout
                emit_signal("enemy_death")
                queue_free()


    ## Check if enemy is in range of the forge
    ## If so, destory itself
    if !_in_forge_range() and !_in_player_range():
        anim_tree.set("parameters/conditions/Shoot", false)
        anim_tree.set("parameters/conditions/Walk", true)
    elif _in_forge_range():
        anim_tree.set("parameters/conditions/Walk", false)
        velocity = Vector3.ZERO
        anim_tree.set("parameters/conditions/Hurt", true)
    else:
        if player_died == false:
            anim_tree.set("parameters/conditions/Shoot", true)
        else:
            anim_tree.set("parameters/conditions/Shoot", false)
            anim_tree.set("parameters/conditions/Walk", true)

    if is_inside_tree():
        move_and_slide()


func _in_forge_range() -> bool:
    if is_inside_tree():
        return global_position.distance_to(forge.global_position) <= FORGE_EXPLODE_RANGE
    else:
        return false


func _in_player_range() -> bool:
    #print("Player distance: ", global_position.distance_to(player.global_position))
    if is_inside_tree():
        return global_position.distance_to(player.global_position) <= ATTACK_RANGE
    else:
        return false


func _hit_finished() -> void:
	if global_position.distance_to(player.global_position) < SHOOT_RANGE:
		player.hit()


## If any body part is hit, it will take @damage ammount of damage.
## Currently, only the Head has damage of 2, all other body parts is 1 damage
func _on_area_3d_body_part_hit(damage: Variant) -> void:
    health -= damage
    if health <= 0:
        anim_tree.set("parameters/conditions/Hurt", true) #changed this logic for the sake of keeping track of kills


##KEEP TRACK OF AMOUNT OF KILLS FOR FUTURE REFERENCE:
func _on_enemy_death() -> void:
    get_parent().get_parent().get_parent().enemy_kills += 1
    print(get_parent().get_parent().get_parent().enemy_kills)

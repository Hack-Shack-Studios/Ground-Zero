class_name MedusaBot
extends CharacterBody3D

## Handles most components reguarding the Medusa Bot
##
## While this is for the medusa bot, most of this code will most like by ported into
## its own Enemy class, since it handles movement towards the player/forge, combot
## range, death, animations, etc... The only things specially towards the Medusa bot
## will be the animaitions type, and the attack ranges

signal enemy_death

const SPEED = 2.0
const ATTACK_RANGE = 4.0
const FORGE_EXPLODE_RANGE = 4.0
const EXPLODE_DELAY_SECS = 1.5
const DIE_ANIMATION = 1.5
const HITMARKER_DECAY = 1.0

@export var player_path := "/root/World/Map/Player"
@export var forge_path := "/root/World/Map/NavigationRegion3D/Forge"
@export var player_path = "/root/World/Map/Player"

var health: int = 6
var is_hacking := false
var forge: StaticBody3D
var enemy_alive := true
var chasing_player := false
var player: CharacterBody3D
var player_died

@onready var nav_agent = $NavigationAgent3D

func _ready() -> void:
	player = get_node(player_path)
	forge = get_node(forge_path)
	state_machine = anim_tree.get("parameters/playback")
	FORGE_POSITION = forge.global_transform.origin

# NEW FUNCTION
func _physics_process(_delta: float) -> void:
    move_and_slide()


# OLD FUNCTION FIX IN POST
func _process(delta: float) -> void:
	## Gets the current location of the player, forge, and itself
	velocity = Vector3.ZERO	
	var enemy_position = global_transform.origin
	var player_position = player.global_transform.origin	
	var player_distance = enemy_position.distance_to(player_position)
	
	## To avoid bugs, distance to forge minmum is always 0
	var forge_distance = (enemy_position.distance_to(FORGE_POSITION)) 
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
			await get_tree().create_timer(EXPLODE_DELAY_SECS).timeout
			queue_free()
			forge.hit()

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
		anim_tree.set("parameters/conditions/Shoot", true)
	
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
	if global_position.distance_to(player.global_position) < ATTACK_RANGE + 1.0:
		var dir = global_position.direction_to(player.global_position)
		player.hit(dir)

## If any body part is hit, it will take @damage ammount of damage.
## Currently, only the Head has damage of 2, all other body parts is 1 damage
func _on_area_3d_body_part_hit(damage: Variant) -> void:
	health -= damage
	
	if health <= 0 and enemy_alive:
        if is_hacking:
            forge.robots_hacking -= 1
        enemy_alive = false

        # anim_tree.set("parameters/conditions/Hurt", true) #changed this logic for the sake of keeping track of kills

	
func _hit_finished() -> void:
    if chasing_player:
        player.hit()

##KEEP TRACK OF AMOUNT OF KILLS FOR FUTURE REFERENCE:
func _on_enemy_death() -> void:
    get_parent().get_parent().get_parent().enemy_kills += 1
    print(get_parent().get_parent().get_parent().enemy_kills)
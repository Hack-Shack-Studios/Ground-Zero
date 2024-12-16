extends CharacterBody3D

# TODO: Make enemy count go down as enemies die
signal enemy_died

# references 
var player = null
var forge = null
var state_machine
var health = 6

# paths
@export var player_path := "/root/World/Map/Player"
@export var forge_path := "/root/World/Map/NavigationRegion3D/Forge"

# Constants
const SPEED = 2.0
const ATTACK_RANGE = 4.0
const FORGE_EXPLODE_RANGE = 4.0
const EXPLODE_DELAY_SECS = 1.5
const DIE_ANIMATION = 4.0
var FORGE_POSITION # To be fixed later... Make forge constant

# set on runtime
@onready var nav_agent = $NavigationAgent3D
@onready var anim_tree = $AnimationTree

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_node(player_path)
	forge = get_node(forge_path)
	state_machine = anim_tree.get("parameters/playback")
	FORGE_POSITION = forge.global_transform.origin  # To be fixed later... Make forge constant

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Sets the enemies velocity to zero every frame
	velocity = Vector3.ZERO
	
		# Getting the positions of the enemy, player, and forge
	var enemy_position = global_transform.origin
	var player_position = player.global_transform.origin
	
	# Getting the distance the enemy is from the player, and from the forge
	var player_distance = enemy_position.distance_to(player_position)
	var forge_distance = (enemy_position.distance_to(FORGE_POSITION)) 
	if forge_distance < 0:
		forge_distance = 0
	# print("Player Distance: ",player_distance)
	#print("Forge Distance: ",global_position.distance_to(FORGE_POSITION))
	
	match state_machine.get_current_node():
		"walk":
			# The enemy will focus either the player or the forge
			# however, if equal distances, enemy will always prioritize the forge
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
		"shoot":

			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
		"hurt":
			#print("I am in forge range, EXPLODE")
			await get_tree().create_timer(EXPLODE_DELAY_SECS).timeout
			queue_free()
			emit_signal("enemy_died")
			forge.hit()


	
	# Check if enemy is in range of the forge
	# If so, destory itself 
	if !_in_forge_range() and !_in_player_range():
		# print("Neither in range, walking towards what is closer")
		anim_tree.set("parameters/conditions/Shoot", false)
		anim_tree.set("parameters/conditions/Walk", true)
	elif _in_forge_range():
		# Check if enemy is in range of the player
		# If so, shoot player
		anim_tree.set("parameters/conditions/Walk", false)
		velocity = Vector3.ZERO
		anim_tree.set("parameters/conditions/Hurt", true)         
	else:
		# print("shooting...")
		anim_tree.set("parameters/conditions/Shoot", true)
		# If niether are true, make the robot walk  
	
	if is_inside_tree():   
		move_and_slide()
	else:
		pass

func _in_forge_range():
	#print("Forge distance: ", global_position.distance_to(forge.global_position))
	if is_inside_tree():
		return global_position.distance_to(forge.global_position) <= FORGE_EXPLODE_RANGE
	else:
		return false

func _in_player_range():
	#print("Player distance: ", global_position.distance_to(player.global_position))
	if is_inside_tree():
		return global_position.distance_to(player.global_position) <= ATTACK_RANGE
	else:
		return false

func _hit_finished():
	if global_position.distance_to(player.global_position) < ATTACK_RANGE + 1.0:
		var dir = global_position.direction_to(player.global_position)
		player.hit(dir)

func _on_area_3d_body_part_hit(dam: Variant) -> void:
	health -= dam
	if health <= 0:
		anim_tree.set("parameters/conditions/Hurt", true)
		await get_tree().create_timer(DIE_ANIMATION).timeout
		queue_free()
	

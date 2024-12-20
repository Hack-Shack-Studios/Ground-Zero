class_name MedusaBot
extends CharacterBody3D

## Handles most components reguarding the Medusa Bot
##
## While this is for the medusa bot, most of this code will most like by ported into
## its own Enemy class, since it handles movement towards the player/forge, combot
## range, death, animations, etc... The only things specially towards the Medusa bot
## will be the animaitions type, and the attack ranges

@export var forge_path := "/root/World/Map/NavigationRegion3D/Forge"
@export var player_path = "/root/World/Map/Player"

var health: int = 6
var is_hacking := false
var forge: StaticBody3D
var enemy_alive := true
var chasing_player := false
var player: CharacterBody3D

@onready var nav_agent = $NavigationAgent3D

func _ready() -> void:
    forge = get_node(forge_path)
    player = get_node(player_path)

func _physics_process(_delta: float) -> void:
    move_and_slide()

func _on_area_3d_body_part_hit(damage: Variant) -> void:
    health -= damage

    if health <= 0 and enemy_alive:
        if is_hacking:
            forge.robots_hacking -= 1
        enemy_alive = false

# func update_target_position(target_location):
#     enemy.nav_agent.set_target_position(target_location)

func _hit_finished() -> void:
    if chasing_player:
        player.hit()

# const MAX_HACKERS: int = 2 # Max amount of hackers bots can have
# const SPEED := 2.0 # speed of bot
# const ATTACK_RANGE := 5.0 # range where needs to start attack
# const SHOOT_RANGE := 5.0 # range bot needs to be when hit finishes
# const FORGE_EXPLODE_RANGE := 4.0 # Hack Range
# const EXPLODE_DELAY_SECS := 1.5 # Get rid of this after hacking is added
# const DIE_ANIMATION := 4.0 # Delay to allow animation to occur, then destory node
# var FORGE_POSITION # TODO: Make forge constant

# @export var player_path := "/root/World/Map/Player" # References player location for chasing
# @export var forge_path := "/root/World/Map/NavigationRegion3D/Forge" # References forge location for chasing

# var player = null # Player node
# var forge = null # Forge node
# var state_machine # Handles bots animations
# var health: int = 6 # Max health of enemy
# var is_hacking := false

# @onready var nav_agent = $NavigationAgent3D # Handles navigation for the enemy
# @onready var anim_tree = $AnimationTree # Handles animations for the bot
# @onready var anim = $AnimationPlayer

# # Ran when enemy first spawns
# func _ready() -> void:
# 	player = get_node(player_path) # Finds player node
# 	forge = get_node(forge_path) # Finds forge node
# 	state_machine = anim_tree.get("parameters/playback") # Gets the animation tree state machine
# 	FORGE_POSITION = forge.global_transform.origin # Gets the forge position since its constant


# # Called every frame
# func _process(delta: float) -> void:
# 	## Gets the current location of the player, forge, and itself
# 	velocity = Vector3.ZERO	# Sets velocity to 0 every frame to prevent bugs
# 	var enemy_position = global_transform.origin
# 	var player_position = player.global_transform.origin
# 	var player_distance = enemy_position.distance_to(player_position)

# 	## To avoid bugs, distance to forge minmum is always 0
# 	var forge_distance = (enemy_position.distance_to(FORGE_POSITION))
# 	if forge_distance < 0:
# 		forge_distance = 0

# 	## Handles the state machine for the Medusa bot
# 	match state_machine.get_current_node():
# 		"walk":
# 			## The enemy will focus either the player or the forge
# 			## however, if equal distances, enemy will always prioritize the forge IF robots_hacking < 2
# 			if forge_distance < player_distance and forge.robots_hacking < MAX_HACKERS: # Go towards forge
# 				## Timer: Chasing_player.stop()

# 				nav_agent.set_target_position(FORGE_POSITION) # Goes towards the forge
# 				var next_nav_point = nav_agent.get_next_path_position() # updates many of the agent's internal states and properties

# 				velocity = (next_nav_point - global_transform.origin).normalized() * SPEED # Sets velocity direction towards the target
# 				rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10.0) # Turn to face the forge
# 				move_and_slide() # updating many of the agent's internal states and properties

# 			else: # Chase player
# 				## Timer: Chasing_player.start(3 seconds)

# 				nav_agent.set_target_position(player.global_transform.origin) # Goes toward the player
# 				var next_nav_point = nav_agent.get_next_path_position() # updates many of the agent's internal states and properties

# 				velocity = (next_nav_point - global_transform.origin).normalized() * SPEED # Sets velocity direction towards the target
# 				rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10.0) # Turn to face the player
# 				move_and_slide() # updating many of the agent's internal states and properties

# 		"shoot":
# 			# Looks at the player
# 			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)

# 		"hurt":
# 			# Does the hurt animation, and pauses the code so the node does not
# 			# disappear too soon
# 			await get_tree().create_timer(EXPLODE_DELAY_SECS).timeout
# 			queue_free()

# ## On Chasing_player time_out():
# # check obsidan canvas

# 	## Check if enemy is in range of the forge
# 	## If so, destory itself
# 	if is_hacking:
# 		anim_tree.set("parameters/conditions/Shoot", true)
# 		velocity = Vector3.ZERO

# 	elif _in_forge_range() && forge.robots_hacking < MAX_HACKERS:
# 		print("I HAVE HACKED THE FORGE, no movement please")
# 		anim_tree.set("parameters/conditions/Walk", false)
# 		velocity = Vector3.ZERO
# 		forge.robots_hacking += 1
# 		is_hacking = true
# 		forge.hit() # hack

# 	elif _in_player_range():
# 		## Boolean is_shooting = true
# 		anim_tree.set("parameters/conditions/Walk", false)
# 		anim_tree.set("parameters/conditions/Shoot", true)

# 	else:
# 		anim_tree.set("parameters/conditions/Shoot", false)
# 		anim_tree.set("parameters/conditions/Walk", true)

# 	# Had to add this because we were getting bugs
# 	if is_inside_tree():
# 		move_and_slide()


# func _in_forge_range() -> bool:
# 	if is_inside_tree():
# 		return global_position.distance_to(forge.global_position) <= FORGE_EXPLODE_RANGE
# 	else:
# 		return false


# func _in_player_range() -> bool:
# 	if is_inside_tree():
# 		return global_position.distance_to(player.global_position) <= ATTACK_RANGE
# 	else:
# 		return false


# func _hit_finished() -> void:
# 	if global_position.distance_to(player.global_position) < SHOOT_RANGE:
# 		player.hit()


# ## If any body part is hit, it will take @damage ammount of damage.
# ## Currently, only the Head has damage of 2, all other body parts is 1 damage

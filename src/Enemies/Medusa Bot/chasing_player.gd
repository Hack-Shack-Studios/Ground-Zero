extends State
class_name ChasingPlayer

## Handles the state for chasing the player 
##
## The Medusa bot chases the player based on a few factors, 
## it is handled here
##
## Chasing the player will be the "base state", as defeating 
## the players is high priority, with hacking kept in mind

const ATTACK_RANGE := 5.0 # range where needs to start attack

@export var enemy: CharacterBody3D
@export var move_speed := 2.0
@export var player_path = "/root/World/Map/Player"
@export var forge_path := "/root/World/Map/NavigationRegion3D/Forge" # References forge location for chasing

var gravity = 9.8
var player: CharacterBody3D
var forge = null

@onready var nav_agent = $NavigationAgent3D
@onready var animation = $AnimationPlayer

func Enter():
	player = get_node(player_path)
	forge = get_node(forge_path)

func Exit():
	pass


func Update(_delta: float):
	pass


func Physics_Update(delta: float):
	enemy.move_and_slide()

	if enemy.velocity.length() > 0:
		animation.play("walk")

	var direction = player.global_transform.origin - enemy.global_transform.origin

	enemy.velocity = direction.normalized() * move_speed
	enemy.rotation.y = lerp_angle(enemy.rotation.y, atan2(-enemy.velocity.x, -enemy.velocity.z), delta * 10.0)

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
	if distance_to_forge <= distance_to_player and forge.robots_hacking < 2:
		pass
		if distance_to_forge <= 4:
			Transitioned.emit(self, "Hacking")
		else:
			Transitioned.emit(self, "ChasingForge")

	# If the medusa bot is within attack range, it will shoot at the player
	elif distance_to_player <= ATTACK_RANGE:
		Transitioned.emit(self, "Shooting")


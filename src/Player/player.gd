class_name Player
extends CharacterBody3D

## Handles the Playable Character
##
## This script handles all things reguarding the player, this includes health,
## shooting, movement, fov, and more. It will most like be tweaked once we
## begin to add other players into the game, but the main concept will stay the same

signal player_hit
signal player_death
signal player_respawn
signal next_wave

const MIN_HEALTH: int = 1
const WALK_SPEED = 7.0 # How fast the player moves
const SPRINT_SPEED = 12.0
const JUMP_VELOCITY = 4.5 # How fast the player jumps
const HIT_STAGGER = 8.0
const BOB_FREQ = 2.0 # How often the steps occur
const BOB_AMP = 0.08 # How high aWnd low the steps go
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5
const MOUSE_MODE_CAPTURED: int = 2

@export var health : float = 6

# static var SENSITIVITY: float = 0.01 # Mouse camera movement sense
var speed: float
var beenHit := false
var heal_value: float = 1
var max_health: float = 6
var t_bob := 0.0 # head bobbing
var bullet = preload("res://Weapons/Coil Pistol/coil_bullet.tscn")
var bullet_instance
const magazine_size = 20 #Total amount of bullets player may shoot
var current_bullets #How many bullets the player has left
var can_regen := false
var dead = false
var round_info: String
var lasers := 0

@onready var head = $Pivot
@onready var camera = $"Pivot/Main Camera"
#@onready var gun_anim = $Pivot/Camera3D/Pistol_3/AnimationPlayer
#@onready var gun_barrel = $Pivot/Camera3D/Pistol_3/gun_barrel
#@onready var aimcast = $Pivot/Camera3D/AimCast
@onready var respawn_timer = $RespawnTimer
@onready var health_bar = $HUD/PlayerHealthBar
@onready var hit_rect = $HUD/ColorRect
@onready var regen_timer = $HUD/Regen
@onready var weapon_info = $HUD/WeaponGUI/InformationLabel
@onready var respawn_label = $HUD/TimerLabel
@onready var collision = $CollisionShape3D
@onready var rounds_label = $HUD/RoundGUI/RoundsInformation
@onready var hit_marker = $HUD/CenterContainer/HitMarker
@onready var hit_marker_HEADSHOT = $HUD/CenterContainer/HitMarkerHEADSHOT
@onready var lazered_timer = $Laserd

@onready var between_wave_timer = $BetweenWaves
var getting_hit = false
var wave_complete = false


func _ready() -> void:
	health_bar.value = max_health
	round_info = str(get_parent().get_parent().waves_remaining - 1) + " ROUNDS LEFT"
	rounds_label.text = round_info

## Handles mouse camera movement
func _unhandled_input(event):
	## Condition is true whenever the mouse moves
	## The camera moves more or less based on how
	## quickly the mouse is moving, multiplied by the sense
	if (event is InputEventMouseMotion && Input.get_mouse_mode() == 2) and not dead:
		# Rotation is flipped, up and down is based on
		# the x-axis, and left and right is based on the
		# y axis, its kinda confusing but there are resources
		# that explain this well
		head.rotate_y(-event.relative.x * (Global.sensitivity / 1000))
		camera.rotate_x(-event.relative.y * (Global.sensitivity / 1000))

		# Max rotation allowed
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))


func _physics_process(delta: float) -> void:
	#print("Current Speed: ",int(velocity.length()))
	#print(get_parent().get_parent().waves_remaining)
	# When the game detects the player is not
	# touching the ground, it sets the velocity downwards
	if not is_on_floor():
		velocity += get_gravity() * delta

	# When the player presses "space", they jump and they go up
	if not dead:
		hit_rect.visible = false
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Handing running mechanic
		if Input.is_action_pressed("sprint"):
			speed = SPRINT_SPEED * (1.5 if Global.speed_boost else 1)
		else:
			speed = WALK_SPEED * (1.5 if Global.speed_boost else 1)

		# Gets the direction vector based on user input
		if !Global.ui_opened:
			var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
			var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

			# Adding inertia, preventing players from being able to stop movement mid-air
			if is_on_floor():
				# Whatever direction they are going, the velocity increases that way
				if direction:
					velocity.x = direction.x * speed
					velocity.z = direction.z * speed
				else:
					velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
					velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
			else:
				velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
				velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
		else:
			velocity = Vector3.ZERO

		# Head bob
		t_bob += delta * velocity.length() * float(is_on_floor())
		camera.transform.origin = _headbob(t_bob)

		# FOV
		var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
		var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
		camera.fov = lerp(camera.fov, target_fov, delta * 8.0)

		move_and_slide()
	else:
		var format = "Respawn in %.1f"
		respawn_label.text = format % respawn_timer.time_left
		hit_rect.visible = true

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos


func respawn():
	respawn_label.visible = true
	dead = true
	emit_signal("player_death")
	respawn_timer.start()
	await respawn_timer.timeout
	dead = false
	respawn_label.visible = false
	emit_signal("player_respawn")

	Global.double_health = false
	max_health = 6
	health = max_health
	health_bar.value = max_health
	health_bar.max_value = max_health

func update_bullets_display():
	var remaining_ammo_color: float = current_bullets / 20.0 #Aesthetics: checks the percentage of bullets left
	weapon_info.text = str(current_bullets) + "/" + str(magazine_size) #Updates weapon text in format Ammo remaining / Total Ammo
	if remaining_ammo_color <= 0.5 and remaining_ammo_color >= 0.2:
		weapon_info.add_theme_color_override("font_color", Color(1, 1, 0))
	elif remaining_ammo_color < 0.2:
		weapon_info.add_theme_color_override("font_color", Color(1, 0, 0))
	else:
		weapon_info.add_theme_color_override("font_color", Color(0, 1, 0))

## TODO: Add this to new weapon system
#func reload():
	#gun_anim.stop()
	#gun_anim.play("reloading")
	#current_bullets = magazine_size
	#weapon_info.text = "Reloading..." #async so that this displays for whole animation before updating
	#await get_tree().create_timer(1.5).timeout #reload animation takes 1.5 seconds
	#update_bullets_display()

func heal() -> void:
	health += .5
	update_health()


func update_health():
	health_bar.value = health


## Regens player health after delay.
func _on_regen_timeout() -> void:
	can_regen = true
	heal_player()

## Handles the healing of the player.
func heal_player() -> void:
	if (health < 6 and can_regen):
		heal()
		await (get_tree().create_timer(1.0).timeout)
		heal_player()

## If the player is hit by an enemy, their screen goes red.
func _on_player_hit() -> void:
	can_regen = false
	hit_rect.visible = true
	await get_tree().create_timer(0.2).timeout
	hit_rect.visible = false
	regen_timer.start()

func hit():

	if getting_hit and not dead:
		#for robots in lasers:
		health -= .5 if !Global.damage_reduction else .25
		update_health()
		await get_tree().create_timer(.2).timeout
		#print("Player HIT, new health: ",health)
		emit_signal("player_hit")
		if health <= 0:
			respawn()
			dead = true
		hit()

	#lazered_timer.start()


#func hit() -> void:
	#emit_signal("forge_hit")
	#for hackers in robots_hacking:
		#health -= damage_amount
		#print("forge hacked")
#
	#if health <= minimum_health:
		#print(str(health) + " <= " +str(minimum_health))
		#get_tree().change_scene_to_file("res://UI/game_over.tscn") #GO TO: Game Over sceen
#
	#hacked_timer.start()
#
#
#func _on_hacked_timeout() -> void:
	#hit()


func _on_forge_double_health() -> void:
	max_health = 12
	health = max_health
	health_bar.max_value = max_health
	health_bar.value = max_health


func _on_area_3d_area_entered(area: Area3D) -> void:
	if !getting_hit:
		getting_hit = true
		hit()



func _on_hit_box_area_exited(area: Area3D) -> void:
	getting_hit = false


func _on_world_wave_finished() -> void:
		round_info = str(get_parent().get_parent().waves_remaining) + " ROUNDS LEFT"

		if !wave_complete:
			wave_complete = true
			rounds_label.text = "Wave Complete" # str(len(enemies)) + "/" +
			print("Wave complete")
			await (get_tree().create_timer(5).timeout)
			between_wave_timer.start()
			between_waves()


func between_waves():
	if between_wave_timer.time_left > 0 and get_parent().get_parent().waves_remaining != 0:
		rounds_label.text = str(str(int(between_wave_timer.time_left))+" seconds until next wave") # str(len(enemies)) + "/" +
		print(str(str(int(between_wave_timer.time_left))+" seconds until next wave"))
		await get_tree().create_timer(.1).timeout
		between_waves()


func _on_between_waves_timeout() -> void:
	emit_signal("next_wave")
	print("Next wave starting")
	wave_complete = false

	if get_parent().get_parent().waves_remaining == 0:
		round_info = str(get_parent().get_parent().waves_remaining) + " ROUNDS LEFT"
		rounds_label.text = "FINAL ROUND"
	else:
		round_info = str(get_parent().get_parent().waves_remaining) + " ROUNDS LEFT"
		rounds_label.text = round_info

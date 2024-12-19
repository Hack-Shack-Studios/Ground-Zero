class_name Player
extends CharacterBody3D

## Handles the Playable Character 
##
## This script handles all things reguarding the player, this includes health, 
## shooting, movement, fov, and more. It will most like be tweaked once we 
## begin to add other players into the game, but the main concept will stay the same

signal player_hit

const MIN_HEALTH: int = 1
const WALK_SPEED = 5.0 # How fast the player moves
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 4.5 # How fast the player jumps
const SENSITIVITY = 0.01 # Mouse camera movement sense 
const HIT_STAGGER = 8.0
const BOB_FREQ = 2.0 # How often the steps occur
const BOB_AMP = 0.08 # How high and low the steps go
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

@export var health : int = 6

var speed: float
var beenHit := false
var heal_value: int = 1
var max_health: int = 6
var t_bob := 0.0 # head bobbing
var bullet = preload("res://Weapons/Coil Pistol/coil_bullet.tscn")
var bullet_instance
const magazine_size = 20 #Total amount of bullets player may shoot
var current_bullets #How many bullets the player has left
var can_regen := false

@onready var head = $Pivot
@onready var camera = $Pivot/Camera3D
@onready var gun_anim = $Pivot/Camera3D/Pistol_3/AnimationPlayer
@onready var gun_barrel = $Pivot/Camera3D/Pistol_3/gun_barrel
@onready var aimcast = $Pivot/Camera3D/AimCast
@onready var health_bar = $HUD/PlayerHealthBar
@onready var hit_rect = $HUD/ColorRect
@onready var regen_timer = $HUD/Regen
@onready var weapon_info = $HUD/WeaponGUI/InformationLabel


func _ready() -> void:
	health_bar.value = max_health
	current_bullets = magazine_size #Player should always start out with max ammo
	weapon_info.text = str(current_bullets) + "/" + str(magazine_size) #Initialize Weapon GUI
	
	
## Handles mouse camera movement
func _unhandled_input(event): 
	## Condition is true whenever the mouse moves 
	## The camera moves more or less based on how 
	## quickly the mouse is moving, multiplied by the sense
	if event is InputEventMouseMotion && Input.get_mouse_mode() == 2:
		# Rotation is flipped, up and down is based on 
		# the x-axis, and left and right is based on the 
		# y axis, its kinda confusing but there are resources 
		# that explain this well
		head.rotate_y(-event.relative.x * SENSITIVITY) 
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		
		# Max rotation allowed
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60)) 


func _physics_process(delta: float) -> void:
	# When the game detects the player is not 
	# touching the ground, it sets the velocity downwards
	if not is_on_floor():
		velocity += get_gravity() * delta

	# When the player presses "space", they jump and they go up
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Handing running mechanic
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED
	
	# Gets the direction vector based on user input 
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

	# Head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)

	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	# NOTE: MAKE SEPERATE FUNCTIONS FOR DIFFERNET GUNS
	
	#Handle Shooting and Reloading...
	if Input.is_action_just_pressed("shoot"):
		shoot()
	if Input.is_action_just_pressed("reload") or current_bullets <= 0:
		reload()
		

	# Handles smooth colisions 
	move_and_slide()


func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos


func hit(dir):
	emit_signal("player_hit")
	velocity += dir * HIT_STAGGER # Limit this somehow
	health -= heal_value
	update_health()
	if health <= 0:
		# Game Restarts
		get_tree().reload_current_scene() 


## TODO: Be able to manage multiple guns
func shoot():
	if current_bullets > 0: #if the magazine is not empty
		if !gun_anim.is_playing():
			gun_anim.play("shoot")
			#CoilPistolShootSound.play()
			if aimcast.is_colliding():
				var b = bullet.instantiate()
				gun_barrel.add_child(b)
				b.look_at(aimcast.get_collision_point(), Vector3.UP)
				current_bullets -= 1 #use one bullet once the bullet is visually "shot"
				update_bullets_display()
	else:
		reload()

func update_bullets_display():
	var remaining_ammo_color: float = current_bullets / 20.0 #Aesthetics: checks the percentage of bullets left
	weapon_info.text = str(current_bullets) + "/" + str(magazine_size) #Updates weapon text in format Ammo remaining / Total Ammo
	if remaining_ammo_color <= 0.5 and remaining_ammo_color >= 0.2:
		weapon_info.add_theme_color_override("font_color", Color(1, 1, 0))
	elif remaining_ammo_color < 0.2:
		weapon_info.add_theme_color_override("font_color", Color(1, 0, 0))
	else:
		weapon_info.add_theme_color_override("font_color", Color(0, 1, 0))


func reload():
	gun_anim.stop()
	gun_anim.play("reloading")
	current_bullets = magazine_size
	weapon_info.text = "Reloading..." #async so that this displays for whole animation before updating
	await get_tree().create_timer(1.5).timeout #reload animation takes 1.5 seconds
	update_bullets_display()

func heal() -> void:
	health += heal_value
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

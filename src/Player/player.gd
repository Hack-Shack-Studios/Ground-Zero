extends CharacterBody3D

var speed 
@export var health : int = 6
const MAX_HEALTH = 6
const MIN_HEALTH = 1
var beenHit = false
const HEAL_VALUE = 1

# constands
const WALK_SPEED = 5.0 # How fast the player moves
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 4.5 # How fast the player jumps
const SENSITIVITY = 0.01 # Mouse camera movement sense 
const HIT_STAGGER = 8.0

# head bob variables 
const BOB_FREQ = 2.0 # How often the steps occur
const BOB_AMP = 0.08 # How high and low the steps go
var t_bob = 0.0

# fov variables 
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

# Bullets
var bullet = load("res://Weapons/bullet.tscn")
var bullet_instance

# The @onready lets us easily control and edit these variables without 
# having to directly go into the code everytime
@onready var head = $Pivot
@onready var camera = $Pivot/Camera3D
@onready var gun_anim = $Pivot/Camera3D/Pistol_3/AnimationPlayer
@onready var gun_barrel = $Pivot/Camera3D/Pistol_3/RayCast3D
@onready var bullet_spawn = $Pivot/BulletSpawn
@onready var healthbar = $"../../UI/OldHealthBar"

# signals
@warning_ignore("unused_signal")
signal player_hit

# Disables mouse on game start 
func _ready():
	healthbar.text = "Health: 6/6"

# Handles mouse camera movement
func _unhandled_input(event): 
	# Condition is true whenever the mouse moves 
	# The camera moves more or less based on how 
	# quickly the mouse is moving, multiplied by the sense
	if event is InputEventMouseMotion && Input.get_mouse_mode() == 4:
		
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
	
	# Shooting 
	# NOTE: MAKE SEPERATE FUNCTIONS FOR DIFFERNET GUNS
	if Input.is_action_pressed("shoot"):
		shoot()

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
	health -= HEAL_VALUE
	healthbar.text = "Health: " + str(health) + "/6"
	if health <= 0:
		# Game Restarts
		get_tree().reload_current_scene() 

func shoot():
	if !gun_anim.is_playing():
			gun_anim.play("shoot")
			bullet_instance = bullet.instantiate()
			
			get_parent().add_child(bullet_instance)			
			bullet_instance.position = gun_barrel.global_position
			bullet_instance.transform.basis = gun_barrel.global_transform.basis

func _set_health(value):
	health = value
	healthbar.text = "Health: " + str(health) + "/6"

func heal():
	health += HEAL_VALUE
	healthbar.text = "Health: " + str(health) + "/" + str(MAX_HEALTH)
	
func _get_health() -> int:
	return health
	
	
	

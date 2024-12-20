class_name CoilBullet
extends Node3D

## Coil Pistol Bullet Manager
##
## Handles the logic for the bullet shot by the coil pistol
const SPEED = 40.0

@onready var mesh = $MeshInstance3D
@onready var ray = $RayCast3D
@onready var particles = $GPUParticles3D

func _ready() -> void:
	set_as_top_level(true) # delete this for laser weapon
	CoilPistolShootSound.play() ## TODO: Remove this global variable


func _process(delta: float) -> void:
	position += transform.basis * Vector3(0, 0, -SPEED) * delta
	if ray.is_colliding(): # If bullet hits something, emit particles and then delete itself
		mesh.visible = false
		particles.emitting = true
		if ray.get_collider() != null:
			if ray.get_collider().is_in_group("enemy"): # if the bullet hits an enemy
				ray.get_collider().hit()
				if ray.get_collider().is_in_group("head_enemy"): #Added new group just for head area3D node on enemy to register headshots
					#Headshot will show a special hit marker
					get_parent().get_parent().get_parent().get_parent().get_parent().hit_marker_HEADSHOT.visible = true
				else:
					get_parent().get_parent().get_parent().get_parent().get_parent().hit_marker.visible = true
		else:
			print("true")
		ray.enabled = false #This disables ALL COLLISIONS, meaning .get_collider() will guaranteed return null.
		await get_tree().create_timer(0.5).timeout
		#Disables both hit markers after the bullet disspates from scene
		get_parent().get_parent().get_parent().get_parent().get_parent().hit_marker.visible = false
		get_parent().get_parent().get_parent().get_parent().get_parent().hit_marker_HEADSHOT.visible = false
		queue_free()


## If bullet hits nothing, will delete itself after 10 seconds
func _on_timer_timeout() -> void: 
	queue_free()

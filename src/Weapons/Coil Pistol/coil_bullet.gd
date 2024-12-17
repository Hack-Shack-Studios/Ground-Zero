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


func _process(delta: float) -> void:
	position += transform.basis * Vector3(0, 0, -SPEED) * delta
	if ray.is_colliding(): # If bullet hits something, emit particles and then delete itself
		mesh.visible = false
		particles.emitting = true
		if ray.get_collider() != null:
			if ray.get_collider().is_in_group("enemy"): # if the bullet hits an enemy
				ray.get_collider().hit()
		else:
			print("true")
		ray.enabled = false #This disables ALL COLLISIONS, meaning .get_collider() will guaranteed return null.
		await get_tree().create_timer(1.0).timeout
		queue_free()


## If bullet hits nothing, will delete itself after 10 seconds
func _on_timer_timeout() -> void: 
	queue_free()

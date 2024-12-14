extends Node3D

const SPEED = 40.0
var test = 5
@onready var mesh = $MeshInstance3D
@onready var ray = $RayCast3D
@onready var particles = $GPUParticles3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_as_top_level(true) # delete this for laser weapon


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += transform.basis * Vector3(0, 0, -SPEED) * delta
	if ray.is_colliding(): # If bullet hits something, emit particles and then delete itself
		mesh.visible = false
		particles.emitting = true
		ray.enabled = false
		if ray.get_collider().is_in_sgroup("enemy"): # if the bullet hits an enemy
			ray.get_collider().hit()
		
		await get_tree().create_timer(1.0).timeout
		queue_free()

# If bullet hits nothing, will delete itself after 10 seconds
func _on_timer_timeout() -> void: 
	queue_free()

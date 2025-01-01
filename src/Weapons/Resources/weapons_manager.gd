extends Node3D

## Weapon Manager

signal weapon_changed
signal update_ammo
signal update_weapon_stack

@onready var anim_player = get_node("%AnimationPlayer")
@onready var bullet_point = get_node("%Bullet_Point")
@onready var audio_player = get_node("%AudioStreamPlayer")

# Hit marker
@onready var hit_marker = get_node("%HitMarker")

var dubug_bullet = preload("res://Weapons/Resources/bullet_debug.tscn")
var current_weapon = null
var weapon_stack = [] # An array of weapons currently held by the player
var weapon_indicator = 0
var next_weapon: String
var weapon_list = {}

@export var _weapon_resources: Array[WeaponResource]
@export var start_weapons: Array[String]

enum {
	NULL, # Weapon type not selected
	HITSCAN,
	PROJECTILE,
}


func _ready() -> void:
	initialize(start_weapons) # enter the state machine

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("weapon_up"):
		weapon_indicator = min(weapon_indicator + 1, weapon_stack.size() - 1)
		exit(weapon_stack[weapon_indicator])

	if event.is_action_pressed("weapon_down"):
		weapon_indicator = max(weapon_indicator - 1, 0)
		exit(weapon_stack[weapon_indicator])

	if event.is_action_pressed("shoot"):
		shoot()

	if event.is_action_pressed("reload"):
		reload()

	if event.is_action_pressed("melee"):
		melee()

func initialize(_start_weapons: Array):
	# Creates dictionary of all weapons
	for weapon in _weapon_resources:
		weapon_list[weapon.weapon_name] = weapon


	for i in _start_weapons:
		weapon_stack.push_back(i) # Add out start weapons

	current_weapon = weapon_list[weapon_stack[0]]
	emit_signal("update_weapon_stack", weapon_stack)
	enter()

func enter():
	anim_player.queue(current_weapon.activate_anim)
	emit_signal("weapon_changed", current_weapon.weapon_name)
	emit_signal("update_ammo", [current_weapon.current_ammo, current_weapon.reserve_ammo])

func exit(_next_weapon: String):
	# In order to change weapons must first call exit
	if _next_weapon != current_weapon.weapon_name:
		if anim_player.get_current_animation() != current_weapon.deactivate_anim:
			anim_player.play(current_weapon.deactivate_anim)
			next_weapon = _next_weapon

func change_weapon(weapon_name: String):
	current_weapon = weapon_list[weapon_name]
	next_weapon = ""
	enter()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == current_weapon.deactivate_anim:
		change_weapon(next_weapon)

	# Is a weapon has the "auto_fire" tag set to true, it will repeat
	if anim_name == current_weapon.shoot_anim and current_weapon.auto_fire:
		if Input.is_action_pressed("shoot"):
			shoot()

	if anim_name == current_weapon.reload_anim:
		calculate_reload()

func shoot():
	# Can't shoot when no ammo, and enforces firerate based on animation speed
	if current_weapon.current_ammo != 0 and !anim_player.is_playing() and !Global.ui_opened or Global.infinite_ammo:
		anim_player.play(current_weapon.shoot_anim)

		# Plays gun sound
		audio_player.stream = current_weapon.shoot_sound
		audio_player.play()

		if Global.infinite_ammo:
			current_weapon.current_ammo = current_weapon.magazine
			current_weapon.reserve_ammo = current_weapon.max_ammo
		else:
			current_weapon.current_ammo -= 1

		emit_signal("update_ammo", [current_weapon.current_ammo, current_weapon.reserve_ammo])
		var camera_collision = get_camera_collision(current_weapon.weapon_range)
		match current_weapon.Type:
			NULL:
				print("Weapon Type Not Chosen")
			HITSCAN:
				hit_scan_collision(camera_collision[1])
			PROJECTILE:
				#projectile_collision(camera_collision[1)
				print("projectile")

		if current_weapon.current_ammo == 0:
			reload()
	elif current_weapon.current_ammo == 0:
		reload()


func reload():
	if current_weapon.current_ammo == current_weapon.magazine:
		return
	elif current_weapon.reserve_ammo != 0:
		anim_player.play(current_weapon.reload_anim)

	else:
		anim_player.play(current_weapon.out_of_ammo_anim)

func calculate_reload() :
	var reload_amount = min(current_weapon.magazine - current_weapon.current_ammo, current_weapon.reserve_ammo)

	current_weapon.current_ammo = current_weapon.current_ammo + reload_amount
	current_weapon.reserve_ammo = current_weapon.reserve_ammo - reload_amount

	emit_signal("update_ammo", [current_weapon.current_ammo, current_weapon.reserve_ammo])

## If this dosen't feel good, can use Area3D, or cast more rays
func melee():
	if anim_player.get_current_animation() != current_weapon.melee_anim:
		anim_player.play(current_weapon.melee_anim)
		var camera_collision = get_camera_collision(current_weapon.melee_range)
		if camera_collision[0]:
			var direction = ((camera_collision[1] - owner.global_transform.origin)).normalized()
			hit_scan_damage(camera_collision[0], current_weapon.melee_dmg)

func get_camera_collision(_weapon_range) -> Array:
	var camera = get_viewport().get_camera_3d()
	var viewport =  get_viewport().get_size()

	var ray_origin = camera.project_ray_origin(viewport / 2)
	var ray_end = ray_origin + camera.project_ray_normal(viewport / 2) * _weapon_range

	var new_intersection = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	var intersection = get_world_3d().direct_space_state.intersect_ray(new_intersection)

	if !intersection.is_empty():
		var collision = [intersection.collider, intersection.position]


		return collision
	else:
		return [null, ray_end]

func hit_scan_collision(collision_point):
	var bullet_direction = (collision_point - bullet_point.get_global_transform().origin).normalized()
	var new_intersection = PhysicsRayQueryParameters3D.create(bullet_point.get_global_transform().origin, collision_point + bullet_direction * 2)

	var bullet_collision = get_world_3d().direct_space_state.intersect_ray(new_intersection)

	if bullet_collision:
		var hit_indicator = dubug_bullet.instantiate()
		var world = get_tree().get_root().get_child(0)
		world.add_child(hit_indicator)
		hit_indicator.global_translate(bullet_collision.position)

		hit_scan_damage(bullet_collision.collider, current_weapon.damage)

func hit_scan_damage(collider, damage):
	if collider.is_in_group("enemy") and collider.has_method("hit_successful") and !collider.enemy_dead:
		#print(str(collider))
		collider.hit_successful(damage)

		hit_marker.visible = true
		await get_tree().create_timer(.2).timeout
		hit_marker.visible = false



func _on_pick_up_detection_body_entered(body: Node3D) -> void:
	var weapon_in_stack = weapon_stack.find(body.weapon_name,0)

	if weapon_in_stack == -1: # pick up
		weapon_stack.insert(weapon_indicator, body.weapon_name)
		#weapon_indicator = 0

		# zero out ammo in the resource
		weapon_list[body.weapon_name].current_ammo = body.current_ammo
		weapon_list[body.weapon_name].reserve_ammo = body.reserve_ammo

		emit_signal("update_weapon_stack", weapon_stack)
		exit(body.weapon_name)
		body.queue_free()
	else: # Add ammo to weapon
		var remaining = add_ammo(body.weapon_name, body.current_ammo + body.reserve_ammo)
		if remaining == 0:
			body.queue_free()

		body.current_ammo = min(remaining, weapon_list[body.weapon_name].magazine)
		body.reserve_ammo = max(remaining - body.current_ammo, 0)

func add_ammo(_weapon: String, ammo: int) -> int:
	var weapon = weapon_list[_weapon]

	var required = weapon.max_ammo - weapon.reserve_ammo
	var remaining = max(ammo - required, 0)

	weapon.reserve_ammo += min(ammo, required)
	emit_signal("update_ammo", [current_weapon.current_ammo, current_weapon.reserve_ammo])
	return remaining

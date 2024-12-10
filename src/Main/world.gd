# FIXME: FIX FOLDER STRUCTURE

extends Node3D

@onready var hit_rect = $UI/ColorRect
@onready var spawns = $Map/Spawns
@onready var navigation_region = $Map/NavigationRegion3D
@onready var player = $Map/Player
@onready var regen = $UI/Regen
@onready var regen_rect = $UI/RegenRect
@onready var health_bar = $UI/HealthBar
@onready var healTimer = $UI/Heal
@onready var log = $UI/ConsoleLog


var enemy = load("res://Enemy/enemy.tscn")
var instance 
var beenHit = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_pressed("toggle_fullscreen"):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
	# Debug Menu
	
	if Input.is_action_pressed("debug_1"): # Restart Scene
		get_tree().reload_current_scene() 
	if Input.is_action_pressed("debug_2"): # Player Max Health
		player._set_health(player.MAX_HEALTH)
	if Input.is_action_pressed("debug_3"): # Player Min Health
		player._set_health(player.MIN_HEALTH)
	if Input.is_action_pressed("debug_4"): # Regen Health
		_on_regen_timeout()
		
	# Not working 
	#if Input.is_action_pressed("debug_5"): # Lose 1 HP
		#var health_minus_1 = player.health - 1
		#player._set_health(health_minus_1)


func _get_random_child(parent_node):
	var random_id = randi() % parent_node.get_child_count()
	return parent_node.get_child(random_id)


func _on_enemy_spawn_timer_timeout() -> void:
	var spawn_point = _get_random_child(spawns).global_position
	instance = enemy.instantiate()
	instance.position = spawn_point
	navigation_region.add_child(instance)


func _on_player_player_hit() -> void:
	beenHit = true
	regen.start()
	hit_rect.visible = true
	await get_tree().create_timer(0.2).timeout
	hit_rect.visible = false
	

# TODO: Figure out a solution to make more clear UI of player healing
func _on_regen_timeout() -> void:
	beenHit = false
	if (player.health < 6):
		regen_rect.visible = true
		await get_tree().create_timer(.2).timeout
		regen_rect.visible = false
		
		# TODO: Healing above 6??
		if player.health != 6 && !beenHit:
			healTimer.start()
		else:
			healTimer.stop()

func _on_heal_timeout() -> void:
	player.heal()
	log.text += "\nPlayer Healed, Current Health: " + str(player.health)

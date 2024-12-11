# FIXME: FIX FOLDER STRUCTURE
extends Node3D

@onready var hit_rect = $UI/ColorRect
@onready var spawns = $Map/Spawns
@onready var navigation_region = $Map/NavigationRegion3D
@export var player_path := "/root/World/Map/Player"
@onready var log_text = $UI/ConsoleLog

# Health/Regen
var player = null
var playerHealth : int 
var can_regen : bool = false
@onready var regen_timer = $UI/Regen
@onready var regen_rect = $UI/RegenRect
@onready var healthbar_text = $UI/HealthBar
@onready var wave_text = $UI/WaveInfo

# Waves
var enemy = load("res://Enemy/enemy.tscn")
var instance 
var MAX_WAVES : int = 5
var waves_remaining := MAX_WAVES
var wave_count : Array[int] = [25, 20, 15, 10, 5]
var total_enemies : int 
var spawn_delay : int = 2.5
@onready var wave_timer_text = $UI/WaveTimerText
@onready var spawn_timer = $EnemySpawnTimer
@export var enemies = []
@onready var result_text = $UI/win_lose_text

# Called when the node enters the scene tree for the first time.
# FIXME: You Win / You Lose text
func _ready() -> void:
	result_text.visible = false
	randomize()
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	player = get_node(player_path)
	playerHealth = player._get_health()
	_on_enemy_spawn_timer_timeout()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var time : int = spawn_timer.time_left
	wave_timer_text.text = str(time) + " seconds until next wave"
	
	if Input.is_action_pressed("toggle_fullscreen"):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
	# Debug Menu
	
	if Input.is_action_just_released("debug_1"): # Restart Scene
		get_tree().reload_current_scene() 
	if Input.is_action_just_released("debug_2"): # Player Max Health
		player._set_health(player.MAX_HEALTH)
	if Input.is_action_just_released("debug_3"): # Player Min Health
		player._set_health(player.MIN_HEALTH)
	if Input.is_action_just_released("debug_4"): # Regen Health
		_on_regen_timeout()
		
	# Not working 
	#if Input.is_action_pressed("debug_5"): # Lose 1 HP
		#var health_minus_1 = player.health - 1
		#player._set_health(health_minus_1)


func _get_random_child(parent_node):
	var random_id = randi() % parent_node.get_child_count()
	return parent_node.get_child(random_id)

# 5 waves of enemies, "Should" be that many enemies 
func _on_enemy_spawn_timer_timeout() -> void:
	# Array of 5 indecies, with number of enemies, and health 
	if (waves_remaining > 0):
		waves_remaining -= 1
		for n in wave_count[waves_remaining]:
			log_text.text += "\nLoop: "+str(n)
			total_enemies = wave_count[waves_remaining]
			var spawn_point = _get_random_child(spawns).global_position
			instance = enemy.instantiate()
			
			#enemies.append(instance)
			
			instance.position = spawn_point
			navigation_region.add_child(instance)
			wave_text.text = "Waves Remaining: "+str(waves_remaining) + "\nEnemies: " + str(total_enemies) # str(len(enemies)) + "/" + 
			await (get_tree().create_timer(spawn_delay).timeout)	
	else:
		
		get_tree().reload_current_scene() 	

# TODO: Move all player non-UI code into Player script
func _on_player_player_hit() -> void:
	can_regen = false
	hit_rect.visible = true
	await get_tree().create_timer(0.2).timeout
	hit_rect.visible = false
	regen_timer.start()

func _on_regen_timeout() -> void:
	can_regen = true
	_heal_player()

func _heal_player() -> void:
	playerHealth = player._get_health()
	if (playerHealth < 6 and can_regen):
		log_text.text += "\nPlayer Health: " + str(playerHealth) + "\ncan_regen = "+str(can_regen)
		player.heal()
		await (get_tree().create_timer(1.0).timeout)
		_heal_player()

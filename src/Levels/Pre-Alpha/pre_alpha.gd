# FIXME: FIX FOLDER STRUCTURE
extends Node3D

@onready var hit_rect = $UI/ColorRect
@onready var spawns = $Map/Spawns
@onready var navigation_region = $Map/NavigationRegion3D
@export var player_path := "/root/World/Map/Player"
@export var forge_path := "/root/World/Map/NavigationRegion3D/Forge"
@onready var log_text = $UI/CanvasLayer/LogControl/ConsoleLog

# forge 
var forge = null

# pause menu
@onready var pause_menu = $UI/PauseMenu
var paused = false

# Health/Regen
var player = null
var playerHealth : int 
var can_regen : bool = false
@onready var regen_timer = $UI/Regen
@onready var regen_rect = $UI/RegenRect
@onready var healthbar_text = $UI/OldHealthBar
@onready var wave_text = $UI/CanvasLayer/WaveCountControl/WaveInfo
@onready var healthBar = $UI/CanvasLayer/HealthBarControl/HealthBar
@onready var forge_health_bar = $UI/CanvasLayer/ForgeHealthBarControl/ForgeHealthBar

# Waves
var enemy = load("res://Enemies/Medusa Bot/medusa_bot.tscn")
var instance 
var MAX_WAVES : int = 5
var waves_remaining := MAX_WAVES
var wave_count : Array[int] = [25, 20, 15, 10, 5]
var total_enemies : int 
var spawn_delay : float = 3.5
@onready var wave_timer_text = $UI/CanvasLayer/WaveCountControl/WaveTimerText
@onready var spawn_timer = $EnemySpawnTimer
@export var enemies = []
@onready var result_text = $UI/win_lose_text

# Called when the node enters the scene tree for the first time.
# FIXME: You Win / You Lose text
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_viewport().size = DisplayServer.screen_get_size()
	result_text.visible = false
	randomize()
	#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	player = get_node(player_path)
	forge = get_node(forge_path)
	playerHealth = player._get_health()
	_set_health_bar()
	_set_forge_bar()
	_on_enemy_spawn_timer_timeout()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	_set_forge_bar()
	_set_health_bar() # For some reason healthbar does not see first hit, so this is needed
	var time : int = spawn_timer.time_left
	wave_timer_text.text = str(time) + " seconds until next wave"
	
	if Input.is_action_pressed("toggle_fullscreen"):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
	if Input.is_action_just_pressed("pause"):
		paused_menu()
	# Debug Menu
	
	if Input.is_action_just_released("debug_1"): # Restart Scene
		get_tree().reload_current_scene() 
	if Input.is_action_just_released("debug_2"): # Player Max Health
		player._set_health(player.MAX_HEALTH)
		_set_health_bar()
	if Input.is_action_just_released("debug_3"): # Player Min Health
		player._set_health(player.MIN_HEALTH)
		_set_health_bar()
	if Input.is_action_just_released("debug_4"): # Regen Health
		_on_regen_timeout()
	if Input.is_action_just_released("debug_5"): # Regen Health
		forge.hit()
		
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
	_set_health_bar()
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
		_set_health_bar()
		await (get_tree().create_timer(1.0).timeout)
		_heal_player()

func _set_health_bar() -> void:
	healthBar.value = player._get_health()


func _on_forge_forge_hit() -> void:
	_set_forge_bar()

func _set_forge_bar() -> void:
	forge_health_bar.value = forge._get_health()

func paused_menu() -> void:
	if paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		pause_menu.hide()
		Engine.time_scale = 1
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		pause_menu.show()
		Engine.time_scale = 0
	paused = !paused

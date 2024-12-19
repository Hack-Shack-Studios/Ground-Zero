class_name PreAlpha
extends Node3D

## Manages game loop for Pre-Alpha
##
## This script is the central hub for the Pre-Alpha. It manages the player, the
## forge, the enemies, etc... This will most likely be used as a template for all 
## future levels we make.

@export var player_path := "/root/World/Map/Player"
@export var forge_path := "/root/World/Map/NavigationRegion3D/Forge"


var forge = null
var paused = false
var enemies = []
var player = null
var playerHealth: int 
var can_regen: bool = false
var enemy = load("res://Enemies/Medusa Bot/medusa_bot.tscn")
var instance 
var MAX_WAVES: int = 1
var waves_remaining := MAX_WAVES
var wave_count: Array[int] = [1]# [25, 20, 15, 10, 5]
var total_enemies: int 
var spawn_delay: float = 3.5
var time: int 


@onready var regen_timer = $UI/Regen
@onready var regen_rect = $UI/RegenRect
@onready var wave_text = $UI/CanvasLayer/WaveCountControl/WaveInfo
@onready var forge_health_bar = $UI/CanvasLayer/ForgeHealthBarControl/ForgeHealthBar
@onready var wave_timer_text = $UI/CanvasLayer/WaveCountControl/WaveTimerText
@onready var spawn_timer = $EnemySpawnTimer
@onready var result_text = $UI/win_lose_text
@onready var pause_menu = $UI/PauseMenu
@onready var hit_rect = $UI/ColorRect
@onready var spawns = $Map/Spawns
@onready var navigation_region = $Map/NavigationRegion3D
@onready var log_text = $UI/CanvasLayer/LogControl/ConsoleLog


func _ready() -> void: ## TODO: You Win / You Lose text
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	result_text.visible = false
	randomize()
	player = get_node(player_path)
	forge = get_node(forge_path)
	_set_forge_bar()
	_on_enemy_spawn_timer_timeout()
	

func _process(_delta: float) -> void:
	time = spawn_timer.time_left
	_set_forge_bar()
	wave_timer_text.text = str(time) + " seconds until next wave"

	if Input.is_action_just_pressed("pause"):
		paused_menu()
	
	## Debug Menu
	#if Input.is_action_just_released("debug_1"): # Restart Scene
		#get_tree().reload_current_scene() 
	#if Input.is_action_just_released("debug_2"): # Player Max Health
		#player._set_health(player.MAX_HEALTH)
		#_set_health_bar()
	#if Input.is_action_just_released("debug_3"): # Player Min Health
		#player._set_health(player.MIN_HEALTH)
		#_set_health_bar()
	#if Input.is_action_just_released("debug_4"): # Regen Health
		#_on_regen_timeout()
	#if Input.is_action_just_released("debug_5"): # Regen Health
		#forge.hit()


## Spawns an enemy at one of the random spawnpoints 
func _get_random_child(parent_node):
	var random_id = randi() % parent_node.get_child_count()
	return parent_node.get_child(random_id)


## Timer used to limit spawning too many enemies at once
func _on_enemy_spawn_timer_timeout() -> void:
	if (waves_remaining > 0):
		waves_remaining -= 1
		for n in wave_count[waves_remaining]:
			log_text.text += "\nLoop: "+str(n)
			total_enemies = wave_count[waves_remaining]
			var spawn_point = _get_random_child(spawns).global_position
			instance = enemy.instantiate()
			instance.position = spawn_point
			navigation_region.add_child(instance)
			wave_text.text = "Waves Remaining: "+str(waves_remaining) + "\nEnemies: " + str(total_enemies) # str(len(enemies)) + "/" + 
			await (get_tree().create_timer(spawn_delay).timeout)	
			
	else:
		pass
		#get_tree().reload_current_scene() 	


## Updates the forge's health bar on hit
func _on_forge_forge_hit() -> void:
	print("Current Forge Health: ",forge.health)
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

class_name PreAlpha
extends Node3D

## Manages game loop for Pre-Alpha
##
## This script is the central hub for the Pre-Alpha. It manages the player, the
## forge, the enemies, etc... This will most likely be used as a template for all
## future levels we make.

signal win_condition

@export var player_path := "/root/World/Map/Player"
@export var forge_path := "/root/World/Map/Forge"


var forge = null
var paused = false
var enemies = []
var player = null
var playerHealth: int
var can_regen: bool = false
var enemy = load("res://Enemies/New Medusa Bot/new_medusa_bot.tscn")
var instance
var MAX_WAVES: int = 5
@export var waves_remaining: int = 5
@export var wave_count: Array[int] = [25, 20, 15, 10, 5]
var total_enemies: int
var spawn_delay: float = 3.5
var time: int
var player_died = false


@onready var regen_timer = $UI/Regen
@onready var regen_rect = $UI/RegenRect
@onready var wave_text = $UI/CanvasLayer/WaveCountControl/WaveInfo
@onready var forge_health_bar = $UI/CanvasLayer/ForgeHealthBarControl/ForgeHealthBar
@onready var wave_timer_text = $UI/CanvasLayer/WaveCountControl/WaveTimerText
@onready var spawn_timer = $EnemySpawnTimer
@onready var result_text = $UI/win_lose_text
@onready var pause_menu = $UI/PauseMenu
@onready var hit_rect = $UI/ColorRect
@onready var spawns = $Spawns
@onready var navigation_region = $Map/NavigationRegion3D
@onready var log_text = $UI/CanvasLayer/LogControl/ConsoleLog
@onready var scoreboard_container = $UI/scoreboard
@onready var score_label = $UI/scoreboard/total_score

var enemy_kills = 0:
	set(new_val):
		Global.score += 15 if !Global.double_points else 30
		score_label.update_score()
		enemy_kills = new_val

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_viewport().size = DisplayServer.screen_get_size()
	result_text.visible = false
	randomize()
	player = get_node(player_path)
	forge = get_node(forge_path)
	_set_forge_bar()
	_on_enemy_spawn_timer_timeout()

	paused = true
	paused_menu()


func _process(_delta: float) -> void:
	time = spawn_timer.time_left
	_set_forge_bar()
	score_label.update_score()
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
	#if Input.is_action_just_pressed("debug_5"):
		#emit_signal("win_condition")
		#get_tree().change_scene_to_file("res://UI/game_over.tscn")

	if Input.is_action_just_pressed("scoreboard_toggle"): #Stylistic choice: Hold TAB to view score rather than toggle.
		scoreboard_container.visible = !scoreboard_container.visible

## Spawns an enemy at one of the random spawnpoints
func _get_random_child(parent_node):
	var random_id = randi() % parent_node.get_child_count()
	return parent_node.get_child(random_id)


## Timer used to limit spawning too many enemies at once
func _on_enemy_spawn_timer_timeout() -> void:
	if (waves_remaining > 0):
		waves_remaining -= 1
		for n in wave_count[waves_remaining]:
			total_enemies = wave_count[waves_remaining]
			var spawn_point = _get_random_child(spawns).global_position
			instance = enemy.instantiate()
			instance.position = spawn_point
			navigation_region.add_child(instance)
			wave_text.text = "Waves Remaining: "+str(waves_remaining) + "\nEnemies: " + str(total_enemies) # str(len(enemies)) + "/" +
			await (get_tree().create_timer(spawn_delay).timeout)
	else: #if you win
		emit_signal("win_condition") #Emit win condition signal (not neccessary, other ways to go about this)
		get_tree().change_scene_to_file("res://UI/game_over.tscn")



## Updates the forge's health bar on hit
func _on_forge_forge_hit() -> void:
	print("Current Forge Health: ",forge.health)
	_set_forge_bar()


func _set_forge_bar() -> void:
	if forge:
		forge_health_bar.value = forge.health


func paused_menu() -> void:
	if paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		pause_menu.hide()
		Engine.time_scale = 1
		NonCombatMusic.stream_paused = false
		Global.ui_opened = false

		paused = !paused

	elif !Global.ui_opened:
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		pause_menu.show()
		Engine.time_scale = 0
		NonCombatMusic.stream_paused = true
		Global.ui_opened = true

		paused = !paused


##Changes variable so that all instances of enemies on the map will effectively ignore the player
func _on_player_player_death() -> void:
	player_died = true #enemies will access this property through get_parent() to determine movement logic
	Global.score -= 30
	score_label.update_score()


func _on_player_player_respawn() -> void:
	print("RESPAWNED!")
	player_died = false

##This function is imperative for determining the text on the game end scene (game over versus win)
func _on_win_condition() -> void:
	Global.win = true #Singleton script that autoloads named "GlobalScript", this is one global variable
	#print(win)

func _on_headshot():
	Global.score += 50
	score_label.update_score()

func get_paused() -> bool:
	return paused

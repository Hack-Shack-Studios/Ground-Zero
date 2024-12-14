extends Node3D

@onready var hit_rect = $UI/ColorRect
@onready var UI = $UI
@onready var spawns = $Map/Spawns
@onready var navigation_region = $Map/NavigationRegion3D

var enemy = load("res://Enemy/enemy.tscn")
var instance 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	hit_rect.size = get_viewport().size
	randomize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _get_random_child(parent_node):
	var random_id = randi() % parent_node.get_child_count()
	return parent_node.get_child(random_id)


func _on_enemy_spawn_timer_timeout() -> void:
	var spawn_point = _get_random_child(spawns).global_position
	instance = enemy.instantiate()
	instance.position = spawn_point
	navigation_region.add_child(instance)


func _on_player_player_hit() -> void:
	hit_rect.visible = true
	await get_tree().create_timer(0.2).timeout
	hit_rect.visible = false

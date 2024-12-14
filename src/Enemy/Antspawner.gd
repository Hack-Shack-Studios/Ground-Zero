extends Node3D


#GET resources from scene...
@onready var enemyObj = preload("res://Enemy/enemy.tscn") #replace path to fit actual project


func _on_spawn_timer_timeout() -> void:
	#Create the enemy in the scene tree
	var enemy = enemyObj.instantiate()
	
	#Set the position of the enemy to the position of the spawner
	enemy.position = position
	
	#Add a node3d derived from WorldNode3D and pass all enemy instances into it.
	get_parent().get_node("EnemyGroups").add_child(enemy)
	print(get_parent().get_node("EnemyGroups").get_path())
	

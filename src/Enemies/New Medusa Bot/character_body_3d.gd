extends CharacterBody3D

@export var main_enemy: Node3D

func hit_successful(damage):
    main_enemy.hit_successful(damage)

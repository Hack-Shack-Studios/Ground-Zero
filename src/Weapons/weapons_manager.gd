extends Node3D

@onready var anim_player = get_node("%AnimationPlayer")

var current_weapon = null

var weapon_stack = [] # An array of weapons currently held by the player

var weapon_indicator = 0

var next_weapon: String

var weapon_list = {}

@export var _weapon_resources: Array[WeaponResource]

@export var start_weapons: Array[String]

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

func initialize(_start_weapons: Array):
    # Creates dictionary of all weapons
    for weapon in _weapon_resources:
        weapon_list[weapon.weapon_name] = weapon


    for i in _start_weapons:
        weapon_stack.push_back(i) # Add out start weapons

    current_weapon = weapon_list[weapon_stack[0]]
    enter()

func enter():
    anim_player.queue(current_weapon.activate_anim)

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

func shoot():
    pass

func reload():
    pass

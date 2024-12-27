class_name Forge
extends StaticBody3D

## Handles Forge components
##
## The Forge is a machine that must be protected by the players, and is targeted by
## the AI. The forge will handle a variety of things in this script, mainly the forge's
## health and upgrades


signal forge_hit

@export var player_path = "/root/World/Map/Player"

const MAX_HACKERS: int = 2

var minimum_health: int = 0
var damage_amount: int = 1
var health: int = 30
var robots_hacking: int
var player = null
var shop_interact_distance = 4.5
var shop_ui_open := false

@onready var shop_visible = $VisibleOnScreenNotifier3D
@onready var hacked_timer = %Hacked
@onready var shop_interact_label = $ShopInteract/Viewport/Label
@onready var shop_ui = $ShopUI
@onready var scoreboard_container = $"../../../UI/scoreboard"

func _ready() -> void:
    player = get_node(player_path)

## Gets the current health of the forge
func _get_health() -> int:
    return health


## Occurs whenever enemy attacks the forge, reducing the health by 1
## If the forge's health every reaches 0, the scene restarts
func hit() -> void:
    emit_signal("forge_hit")
    for hackers in robots_hacking:
        health -= damage_amount
        print("forge hacked")

    if health <= minimum_health:
        print(str(health) + " <= " +str(minimum_health))
        get_tree().change_scene_to_file("res://UI/game_over.tscn") #GO TO: Game Over sceen

    hacked_timer.start()


func _on_hacked_timeout() -> void:
    hit()

func _process(_delta: float) -> void:
    var distance_to_player = global_position.distance_to(player.global_position)

    if distance_to_player <= shop_interact_distance:
        shop_interact_label.visible = true

        if Input.is_action_just_pressed("open_shop") and shop_visible.is_on_screen():
            forge_shop()


    else:
        shop_interact_label.visible = false
        shop_ui.visible = false


func forge_shop():
    if shop_ui_open:
        Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
        shop_ui.hide()
        Global.ui_opened = false
        shop_ui_open = !shop_ui_open
        scoreboard_container.visible = false

    elif !Global.ui_opened:
        Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
        shop_ui.show()
        Global.ui_opened = true
        shop_ui_open = !shop_ui_open
        scoreboard_container.visible = true



func _on_visible_on_screen_notifier_3d_screen_entered() -> void:
    shop_interact_label.visible = true


func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
    shop_interact_label.visible = false
    shop_ui_open = true
    forge_shop()

## Shop UI
# Prices
const SPEED_PRICE: int = 30
const DAMAGE_REDUCTION_PRICE: int = 100
const INFINITE_AMMO_PRICE: int = 120
const DOUBLE_POINTS_PRICE: int = 200
const DOUBLE_HEALTH_PRICE: int = 350

## Timers
@onready var speed_timer = $Timers/SpeedBoost
@onready var damage_reduction_timer = $Timers/DamageReduction
@onready var infinite_ammo_timer = $Timers/InfiniteAmmo
@onready var double_points_timer = $Timers/DoublePoints

## Buttons
@onready var speed_button = get_node("$Menu/Buffs/Speed")
@onready var damage_reduction_button = get_node("$ShopUI/Menu/Buffs/DamageReduction")
@onready var infinite_ammo_button = get_node("$ShopUI/Menu/Buffs/InfiniteAmmo")
@onready var double_points_button = get_node("$ShopUI/Menu/Buffs/DoublePoints")
@onready var double_health_button = get_node("$ShopUI/Menu/Buffs/DoubleHealth")

## Colors
var green := Color("DARK_GREEN")
var red := Color("DARK_RED")

func _on_speed_pressed() -> void:
    # speed_boost.emit()
    print("Speed pressed, money: ", Global.score)
    if Global.score > SPEED_PRICE:
        Global.score -= SPEED_PRICE
        Global.speed_boost = true
        speed_timer.start()
        # speed_boost.emit()


func _on_damage_reduction_pressed() -> void:
    print("Damage Reduction pressed, money: ", Global.score)
    if Global.score > DAMAGE_REDUCTION_PRICE:
        Global.score -= DAMAGE_REDUCTION_PRICE
        Global.damage_reduction = true
        damage_reduction_timer.start()


func _on_infinite_ammo_pressed() -> void:
    print("Infinite Ammo pressed, money: ", Global.score)
    if Global.score > INFINITE_AMMO_PRICE:
        Global.score -= INFINITE_AMMO_PRICE
        Global.infinite_ammo = true
        infinite_ammo_timer.start()


func _on_double_points_pressed() -> void:
    print("Double Points pressed, money: ", Global.score)
    if Global.score > DOUBLE_POINTS_PRICE:
        Global.score -= DOUBLE_POINTS_PRICE
        Global.double_points = true
        double_points_timer.start()


func _on_double_health_pressed() -> void:
    print("Double Health pressed, money: ", Global.score)
    if Global.score > DOUBLE_HEALTH_PRICE:
        Global.score -= DOUBLE_HEALTH_PRICE
        Global.double_health = true


## Timer functions

func _on_speed_boost_timeout() -> void:
    Global.speed_boost = false


func _on_damage_reduction_timeout() -> void:
    Global.damage_reduction = false


func _on_infinite_ammo_timeout() -> void:
    Global.infinite_ammo = false


func _on_double_points_timeout() -> void:
    Global.double_points = false

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
@onready var hacked_timer = $Hacked
@onready var shop_interact_label = $ShopInteract/Viewport/Label
@onready var shop_ui = $ShopUI

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

    elif !Global.ui_opened:
        Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
        shop_ui.show()
        Global.ui_opened = true
        shop_ui_open = !shop_ui_open


func _on_visible_on_screen_notifier_3d_screen_entered() -> void:
    shop_interact_label.visible = true


func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
    shop_interact_label.visible = false
    shop_ui_open = true
    forge_shop()

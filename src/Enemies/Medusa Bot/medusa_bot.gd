extends CharacterBody3D

## Handles most components reguarding the Medusa Bot
##
## While this is for the medusa bot, most of this code will most like by ported into
## its own Enemy class, since it handles movement towards the player/forge, combot
## range, death, animations, etc... The only things specially towards the Medusa bot
## will be the animaitions type, and the attack ranges

signal enemy_death

const SPEED = 2.0
const ATTACK_RANGE = 4.0
const FORGE_EXPLODE_RANGE = 4.0
const EXPLODE_DELAY_SECS = 1.5
const DIE_ANIMATION = 1.5
const HITMARKER_DECAY = 1.0

@export var player_path := "/root/World/Map/Player"
@export var forge_path := "/root/World/Map/NavigationRegion3D/Forge"

var health: int = 6
var is_hacking := false
var forge: StaticBody3D
var enemy_alive := true
var chasing_player := false
var player: CharacterBody3D
var player_died
var medusa_head = preload("res://Weapons/Spawnables/medusa_head.tscn")
var enemy_dead := false

@onready var weapon_spawner = get_node("/root/World/Spawnables")
@onready var nav_agent = $NavigationAgent3D
@export var enemy_body: CharacterBody3D

func _ready() -> void:
    player = get_node(player_path)
    forge = get_node(forge_path)


# NEW FUNCTION
func _physics_process(_delta: float) -> void:
    move_and_slide()


## TODO: Combine both methods below
## If any body part is hit, it will take @damage ammount of damage.
## Currently, only the Head has damage of 2, all other body parts is 1 damage
#func _on_area_3d_body_part_hit(damage: Variant) -> void:
    #health -= damage
#
    #if health <= 0 and enemy_alive:
        #if is_hacking:
            #forge.robots_hacking -= 1
        #enemy_alive = false
func hit_successful(damage):
    health -= damage
    print("Target Health: ",health)
    if health <= 0 and enemy_alive:
        if is_hacking:
            forge.robots_hacking -= 1
        enemy_alive = false
        enemy_dead = true


func _hit_finished() -> void:
    # if chasing_player:
    #     player.hit()
    pass

## KEEP TRACK OF AMOUNT OF KILLS FOR FUTURE REFERENCE:
func _on_enemy_death() -> void:
    var weapon_drops = false

    weapon_drops = true if randf() < .2 else false

    if weapon_drops:
        var medusa_head = medusa_head.instantiate()
        medusa_head.position = position
        medusa_head.position.y += .5

        weapon_spawner.add_child(medusa_head)

    get_parent().get_parent().get_parent().enemy_kills += 1
    print(get_parent().get_parent().get_parent().enemy_kills)

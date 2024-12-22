extends State
class_name Shooting

## Handles the state for chasing the forge
##
## Chasing the forge

const SHOOT_RANGE := 20.0

@export var enemy: CharacterBody3D
@export var player_path = "/root/World/Map/Player"
@export var forge_path := "/root/World/Map/NavigationRegion3D/Forge"
@export var animation: AnimationPlayer

var gravity = 9.8
var player: CharacterBody3D
var forge = StaticBody3D
var animation_name = "shoot"
var animation_length := 2.5

func enter():
    player = get_node(player_path)
    forge = get_node(forge_path)
    enemy.chasing_player = true

    #print("Shooting")

    # Anchor Down animation



func exit():
    # Anchor up animation, await time()

    pass


func update(_delta: float):
    pass


func physics_update(_delta: float):
    animation.play(animation_name)

    enemy.velocity = Vector3.ZERO
    enemy.look_at(Vector3(player.global_position.x, enemy.global_position.y, player.global_position.z), Vector3.UP)
    await (get_tree().create_timer(animation_length).timeout)

    var distance_to_forge = enemy.global_position.distance_to(forge.global_position)
    var distance_to_player = enemy.global_position.distance_to(player.global_position)

    if distance_to_forge < distance_to_player and forge.robots_hacking < forge.MAX_HACKERS or player.dead:
        Transitioned.emit(self, "ChasingForge")
    elif distance_to_player > SHOOT_RANGE:
        if distance_to_player > distance_to_forge:
            Transitioned.emit(self, "ChasingPlayer")
        else:
            Transitioned.emit(self, "ChasingForge")

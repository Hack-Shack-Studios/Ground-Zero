# FIXME: Implement this for medusa bot

class_name Enemy

@export var damage: int
@export var health: int
@export var name: String

func _init(damage: int, health: int, name: String) -> void:
    self.damage = damage
    self.health = health
    self.name = name

func hit_successful(damage_taken) -> void:
    health -= damage_taken
    print("Enemy: "+ name+",Damage: ",damage_taken)

# TODO: Figure out how to get queue working from enemy class
    if health <= 0:
        # queue_free
        pass

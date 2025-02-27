extends Resource

class_name WeaponResource

@export var weapon_name: String
@export var activate_anim: String
@export var shoot_anim: String
@export var reload_anim: String
@export var deactivate_anim: String
@export var out_of_ammo_anim: String
@export var melee_anim: String

@export var current_ammo: int
@export var reserve_ammo: int
@export var magazine: int
@export var max_ammo: int

@export var auto_fire: bool
@export_flags("hitscan","projectile") var Type
@export var weapon_range: int
@export var damage: int
@export var melee_dmg: int = 1
@export var melee_range: float = 1.5

@export var shoot_sound: AudioStream

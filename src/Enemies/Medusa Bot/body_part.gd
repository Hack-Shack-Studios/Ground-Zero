class_name BodyPart
extends Area3D

## Handles Collision with Medusa Bot's Body Parts
##
## Every body part of the Medusa bot contains this script. The only difference in the 
## code is for the Head BoneAttachment3D, making damage 2, instead of 1

## If the current body part is hit, the enemy will take @damage amount of damage
signal body_part_hit(damage)

## The amount of damage this body part takes
@export var damage: int = 1


## If this body part is hit, it emits a signal telling the entire enemy to take 
## @damage amount of damage
func hit():
	emit_signal("body_part_hit", damage)

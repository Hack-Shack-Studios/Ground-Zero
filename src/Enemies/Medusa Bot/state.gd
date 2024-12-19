class_name State
extends Node

## Blank state for the multiple states 
##
## Will be handling a single state, and placed in the state machine node

signal Transitioned


func Enter():
	pass


func Exit():
	pass


func Update(_delta: float):
	pass


func Physics_Update(_delta: float):
	pass
	

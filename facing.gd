extends Node
class_name PLA_Facing

@onready var body = owner as CharacterBody2D
@onready var graphics = %graphics as ActorGraphics2D

var facing_right : bool = true:
	set(value):
		if value: graphics.scale.x = 1
		else: graphics.scale.x = -1
		facing_right = value
	get:
		return facing_right

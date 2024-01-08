@icon("phys.svg")
extends Node
class_name SharedPhysics

@export var base_drag := 0.1
@export var base_gravity := 3.0
@onready var body = owner as CharacterBody2D

@export var constants : PLT_PhysData

const SANITY_MULTIPLIER := 30.0

@export var current_gravity_multiplier := 1.0
@export var current_drag_multiplier := 1.0
@export var current_acceleration_multiplier := 1.0

static var scale := 24.0
static func _static_init():
	var bb = load("res://blackboard.tres")
	if not bb or not "physics_scale" in bb: return
	scale = bb.physics_scale

var floor_movement_normal := Vector2.RIGHT
var velocity_cache = Vector2.ZERO

signal hit_ground

func move_owner(delta: float, acceleration: Vector2 = Vector2.ZERO,\
		drag_multiplier: float = 1, gravity_multiplier: float = 1, airborn = false):
	
	acceleration.y += base_gravity * current_gravity_multiplier * gravity_multiplier * delta * SANITY_MULTIPLIER
	acceleration *= current_acceleration_multiplier * scale
	acceleration -= velocity_cache * base_drag * drag_multiplier * current_drag_multiplier * delta * SANITY_MULTIPLIER
	velocity_cache += acceleration / 2
	# -- From Godot 3 --. Manage airbornness in some other way.
	#var snapvec = Vector2.DOWN
	#if airborn: snapvec = Vector2.ZERO
	body.velocity = velocity_cache
	body.move_and_slide()
	#velocity_cache = body.get_real_velocity()
	velocity_cache = body.velocity
	velocity_cache += acceleration / 2
	if body.is_on_floor():
		floor_movement_normal = body.get_floor_normal().rotated(1.5708)
		if not grounded:
			grounded = true
			hit_ground.emit()
	else: 
		floor_movement_normal = Vector2.RIGHT
	


func burst_accelerate(acceleration: Vector2):
	velocity_cache += acceleration * scale
	
var grounded := false
var iframe := false

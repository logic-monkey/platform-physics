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

@onready var facing = %facing as PLA_Facing

static var scale := 24.0
static func _static_init():
	var bb = load("res://blackboard.tres")
	if not bb or not "physics_scale" in bb: return
	scale = bb.physics_scale

var floor_movement_normal := Vector2.RIGHT
var velocity_cache = Vector2.ZERO
var floor_rotation = 0
var floor_normal :=Vector2.UP
var move_speed_cache : float = 0
var prior_accel_cache : Vector2 = Vector2.ZERO
signal hit_ground

func move_owner(delta: float, acceleration: Vector2 = Vector2.ZERO,\
		drag_multiplier: float = 1, gravity_multiplier: float = 1, airborn = false):
	prior_accel_cache = acceleration
	acceleration.y += base_gravity * current_gravity_multiplier * gravity_multiplier * delta * SANITY_MULTIPLIER
	acceleration *= current_acceleration_multiplier * scale
	acceleration -= velocity_cache * base_drag * drag_multiplier * current_drag_multiplier * delta * SANITY_MULTIPLIER
	velocity_cache += acceleration / 2
	body.velocity = velocity_cache
	body.move_and_slide()
	velocity_cache = body.velocity
	velocity_cache += acceleration / 2
	if body.is_on_floor():
		var norm = body.get_floor_normal()
		floor_movement_normal = norm.rotated(1.5708)
		floor_normal = norm
		floor_rotation = norm.rotated(1.5708).angle()
		if not grounded:
			grounded = true
			hit_ground.emit()
	else: 
		var blend = pow(0.5, delta * 10)
		floor_rotation = lerp_angle(0, floor_rotation, blend)
		floor_movement_normal = Vector2.RIGHT
		floor_normal = Vector2.UP.slerp(floor_normal, blend)
	move_speed_cache = velocity_cache.length()/scale
	
func update_spring_time(delta:float):
	if time_to_spring_forget > 0:
		time_to_spring_forget -= delta
		if time_to_spring_forget <= 0:
			last_spring = null

func _process(delta):
	update_spring_time(delta)

func burst_accelerate(acceleration: Vector2, cancel_gravity: bool = false, flip: bool = false):

	var g = owner.get_node("%graphics") as ActorGraphics2D
	var x = velocity_cache.x
	if g: x = velocity_cache.rotated(-floor_rotation).x
	if cancel_gravity:
		if velocity_cache.y > 0: velocity_cache.y = 0
	velocity_cache += acceleration * scale
	if flip:
		if not g: return
		var new_x = velocity_cache.rotated(-floor_rotation).x
		if new_x > 0: facing.facing_right = true
		if new_x < 0: facing.facing_right = false
			
			
@export var spring_run_states : Array[String]
func spring_hit(spring:PLA_Spring, time_to_forget := 0.1):
	last_spring = spring
	time_to_spring_forget = time_to_forget
	var g = owner.get_node("%graphics") as ActorGraphics2D
	if not g: return
	var am = owner.get_node("action_machine") as StateMachine
	if not am: return
	if velocity_cache.rotated(-floor_rotation).y < 0:
		am.transition("airborn",{"spring":true})
	elif am.current.name in spring_run_states:
		am.transition("run")

var last_spring: PLA_Spring
var time_to_spring_forget:float=0

var grounded := false
var iframe := false
signal iframes_done

func _on_i_frames_timeout():
	iframe = false
	iframes_done.emit()

func _ready():
	if %i_frames: %i_frames.timeout.connect(_on_i_frames_timeout)

@tool
extends Node2D
class_name GroundSensor

@export var edge_depth := 4.0 :
	get: return edge_depth
	set(value):
		edge_depth = value
		queue_redraw()
@export var center_depth := 10.0:
	get: return center_depth
	set(value):
		center_depth = value
		queue_redraw()
@export var edge_distance := 8.0:
	get: return edge_distance
	set(value):
		edge_distance = value
		queue_redraw()
		
@export_flags_2d_physics var mask = 0b0001

var left : RayCast2D
var right : RayCast2D
var center : RayCast2D

func _ready():
	if Engine.is_editor_hint(): return
	left = RayCast2D.new()
	add_child(left)
	left.position = Vector2(-edge_distance, 0)
	left.add_exception(owner)
	left.collision_mask = mask
	left.target_position = Vector2(0, edge_depth)
	right = RayCast2D.new()
	add_child(right)
	right.position = Vector2(edge_distance, 0)
	right.add_exception(owner)
	right.collision_mask = mask
	right.target_position = Vector2(0, edge_depth)
	center = RayCast2D.new()
	add_child(center)
	center.position = Vector2(0,0)
	center.add_exception(owner)
	center.collision_mask = mask
	center.target_position = Vector2(0, center_depth)
	
func is_colliding()->bool:
	return left.is_colliding() or right.is_colliding() or center.is_colliding()

func _draw():
	#if not Engine.is_editor_hint(): return
	var lc = Color.MAGENTA
	var rc = Color.MAGENTA
	var cc = Color.MAGENTA
	if not Engine.is_editor_hint():
		if left and left.is_colliding(): lc = Color.YELLOW_GREEN
		if right and right.is_colliding(): rc = Color.YELLOW_GREEN
		if center and center.is_colliding(): cc = Color.YELLOW_GREEN
	
	draw_line(Vector2.ZERO,Vector2(0, center_depth), cc,1)
	draw_line(Vector2(-edge_distance,0), Vector2(-edge_distance,edge_depth),lc,1)
	draw_line(Vector2(edge_distance,0), Vector2(edge_distance,edge_depth),rc,1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	queue_redraw()

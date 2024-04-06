@tool
extends Polygon2D
class_name Collideagon2D

@export var outline_color : Color = Color.MAGENTA
@export var outline_width : float = 8
@export_flags_2d_physics var collision_layer = 1
@export_flags_2d_physics var collision_mask = 1

var body = null
var shape = null
var line = null

func _ready():
	texture = load("res://addons/platform-physics/tiles/greybox.png")
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	#property_list_changed.connect(_on_property_list_changed)
	if Engine.is_editor_hint(): return
	recalculate()
	
func recalculate():
	if line != null:
		line.queue_free()
		body.queue_free()
	line = Line2D.new()
	line.antialiased = antialiased
	line.width = outline_width
	line.points = polygon
	line.closed = true
	line.default_color = outline_color
	add_child(line)
	body = StaticBody2D.new()
	shape = CollisionPolygon2D.new()
	body.collision_layer = collision_layer
	body.collision_mask = collision_mask
	shape.set_polygon(polygon)
	body.add_child(shape)
	add_child(body)
	

func _draw():
	if not Engine.is_editor_hint(): return
	draw_polyline(polygon, outline_color, outline_width, antialiased)
	draw_line(polygon[0],polygon[-1],outline_color,outline_width,antialiased)


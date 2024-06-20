extends State
class_name ST_PH_RMX_WallSlide

@onready var graphics = %graphics as ActorGraphics2D
@onready var gamepad = %VirtualGamePad as VirtualGamepad
@onready var physics = %SharedPhysics as SharedPhysics
@onready var ground = %GroundSensor as GroundSensor
@onready var colliders = %collider_wrangler as PLT_ColliderWrangler
@onready var wall = %WallSensor as GroundSensor

func enter(previous_state = "", _msg: Dictionary = {}):
	graphics.play("wall_slide")
	colliders.play("stand")
	pass

func proc(_delta):
	pass
	
func phys(_delta):
	var drag = physics.constants.wall_drag
	var grav = physics.constants.wall_gravity
	var press_force = physics.constants.wall_press_force * graphics.scale.x
	physics.move_owner(_delta, Vector2(press_force, 0),drag, grav, false)
	if physics.grounded:
		transition("idle")
		return
	if not wall.is_colliding() or gamepad.stick.y > physics.constants.stick_crouch_threshold:
		transition("airborn")
		return
		


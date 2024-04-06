extends State
class_name ST_PH_SMW_idle

@onready var graphics = %graphics as ActorGraphics2D
@onready var gamepad = %VirtualGamePad as VirtualGamepad
@onready var physics = %SharedPhysics as SharedPhysics
@onready var ground = %GroundSensor as GroundSensor
#@onready var cwrangler = %PLT_ColliderWrangler as PLT_ColliderWrangler

func enter(previous_state = "", _msg: Dictionary = {}):
	graphics.play("idle")

func proc(_delta):
	# We are moving the jump logic TO the Jump State. Same with attack logic.
	#if gamepad.check_button("jump"):
		#transition("airborn", {"jump":true})
		#return
	if abs(gamepad.stick.x) > physics.constants.stick_walk_threshold:
		#cwrangler.play("stand")
		transition("walk")
		return
	if gamepad.stick.y <= -physics.constants.stick_crouch_threshold:
		graphics.play("lookup")
	elif gamepad.stick.y >= physics.constants.stick_crouch_threshold:
		graphics.play("crouch")
	else:
		graphics.play("idle")
		
	
func phys(_delta):
	var gravity_multiplier = physics.constants.idle_gravity
	var drag_multiplier = physics.constants.idle_drag
	
	physics.move_owner(_delta, Vector2.ZERO, drag_multiplier,gravity_multiplier)
	if not ground.is_colliding():
		physics.grounded = false
		transition("airborn")

func exit():
	pass



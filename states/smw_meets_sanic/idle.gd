extends State

@onready var graphics = %graphics as ActorGraphics2D
@onready var gamepad = %VirtualGamepad as VirtualGamepad
@onready var physics = %SharedPhysics as SharedPhysics
@onready var cwrangler = %PLT_ColliderWrangler as PLT_ColliderWrangler

func enter(previous_state = "", _msg: Dictionary = {}):
	graphics.play("idle")

func proc(_delta):
	# We are moving the jump logic TO the Jump State. Same with attack logic.
	#if gamepad.check_button("jump"):
		#transition("airborn", {"jump":true})
		#return
	if abs(gamepad.stick.x) > physics.constants.stick_walk_threshold:
		cwrangler.play("stand")
		transition("walk")
		return
	if gamepad.stick.y <= -physics.constants.stick_crouch_threshold:
		graphics.play("lookup")
		cwrangler.play("stand")
		
	
func phys(_delta):
	pass

func exit():
	pass



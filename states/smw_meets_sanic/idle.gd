extends State
class_name ST_PH_SMW_idle

@onready var graphics = %graphics as ActorGraphics2D
@onready var gamepad = %VirtualGamePad as VirtualGamepad
@onready var physics = %SharedPhysics as SharedPhysics
@onready var ground = %GroundSensor as GroundSensor
@onready var cwrangler = %collider_wrangler as PLT_ColliderWrangler

@export var time_to_look_up_or_down : float = 0.5
@onready var lookupTimer = Timer.new()

func _ready():
	lookupTimer.one_shot = true
	lookupTimer.wait_time = time_to_look_up_or_down
	add_child(lookupTimer)
	lookupTimer.timeout.connect(_lookupdown)

func enter(previous_state = "", _msg: Dictionary = {}):
	if not "crouch" in _msg:
		cwrangler.play("stand")
		graphics.play("idle")
	else:
		if _msg.crouch:
			graphics.play("crouch")
			cwrangler.play("duck")
		else:
			cwrangler.play("stand")
			graphics.play("lookup")
	var goal = owner.get_node("CameraGoal2D") as CameraGoal2D
	if goal:
		goal.lookat("idle")

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
		cwrangler.play("stand")
		if lookupTimer.is_stopped(): lookupTimer.start()
	elif gamepad.stick.y >= physics.constants.stick_crouch_threshold:
		graphics.play("crouch")
		cwrangler.play("duck", true)
		if lookupTimer.is_stopped(): lookupTimer.start()
	else:
		graphics.play("idle")
		cwrangler.play("stand")
		if not lookupTimer.is_stopped(): lookupTimer.stop()
		if lookingupdown:
			var goal = owner.get_node("CameraGoal2D") as CameraGoal2D
			if goal:
				goal.lookat("idle")
			lookingupdown = false

func phys(_delta):
	var gravity_multiplier = physics.constants.idle_gravity
	var drag_multiplier = physics.constants.idle_drag
	
	physics.move_owner(_delta, Vector2.ZERO, drag_multiplier,gravity_multiplier)
	if not ground.is_colliding() and not physics.body.is_on_floor():
		physics.grounded = false
		transition("airborn")


var lookingupdown:bool=false
func _lookupdown():
	if not active: return
	var goal = owner.get_node("CameraGoal2D") as CameraGoal2D
	if not goal: return
	if gamepad.stick.y <= -physics.constants.stick_crouch_threshold:
		goal.lookat("lookup")
		lookingupdown = true
	else:
		goal.lookat("lookdown")
		lookingupdown = true

func exit(_next_state:String=""):
	lookupTimer.stop()

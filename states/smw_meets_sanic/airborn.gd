extends State
class_name ST_PH_SMW_Airborn

@onready var graphics = %graphics as ActorGraphics2D
@onready var gamepad = %VirtualGamePad as VirtualGamepad
@onready var physics = %SharedPhysics as SharedPhysics

var jumping = false
@onready var coyote_timer = Timer.new()

func _ready():
	add_child(coyote_timer)
	coyote_timer.one_shot = true
	if "coyote_time" in _INIT.data:
		coyote_timer.wait_time = _INIT.data.coyote_time
	else:
		coyote_timer.wait_time = 0.1
		_INIT.data["coyote_time"] = 0.1
		_INIT.Save()
	if "jump" in gamepad.buttons:
		gamepad.buttons["jump"].just_pressed.connect(jump)

@export var coyote_whitelist : Array[String]
var record_of_previous_state = ""
func enter(previous_state = "", _msg: Dictionary = {}):
	record_of_previous_state = previous_state
	if jumping:
		physics.velocity_cache.y = 0
		physics.burst_accelerate(Vector2(0, -physics.constants.jump_strength))
		graphics.play("jump")
		coyote_timer.stop()
	else:
		
		if previous_state in coyote_whitelist:
			coyote_timer.start()
		graphics.play("fall")

func proc(_delta):
	pass
	
func phys(_delta):
	var rising_grav = physics.constants.airborn_rising_gravity
	var falling_grav = physics.constants.airborn_falling_gravity
	var drag = physics.constants.airborn_drag
	
	if jumping and not gamepad.is_button_down("jump"):
		jumping = false
		if physics.velocity_cache.y < 0:
			physics.velocity_cache.y = physics.velocity_cache.y *0.5
		
	if physics.velocity_cache.y > 0:
		if jumping: jumping = false
		graphics.play("fall")
	else:
		graphics.play("rise")
	var grav = rising_grav
	if not jumping: 
		grav = falling_grav
	var xAccel = gamepad.stick.x * physics.constants.airborn_acceleration
	if (xAccel > 0 and graphics.scale.x < 0) or \
			(xAccel < 0 and graphics.scale.x > 0):
		graphics.scale.x *= -1
		graphics.play("turn")
	var accel = Vector2(xAccel, 0)
	physics.move_owner(_delta, accel ,drag, grav, true)
	if physics.body.is_on_floor():
		jumping = false
		transition("idle")
	if physics.body.is_on_ceiling():
		graphics.play("bonk")
	
@export var valid_states: Array[State]
func jump():
	#print_rich("[wave]Jump![/wave]")
	if active:
		if not coyote_timer.is_stopped():
			jumping = true
			transition("airborn")
			return
		await physics.hit_ground
		if not gamepad.check_button("jump"):
			return
	if not state_machine.current in valid_states: return
	jumping = true
	transition("airborn")
	
func exit():
	jumping = false



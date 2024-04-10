extends State
class_name ST_PH_SMW_Run

@onready var graphics = %graphics as ActorGraphics2D
@onready var gamepad = %VirtualGamePad as VirtualGamepad
@onready var physics = %SharedPhysics as SharedPhysics
@onready var ground = %GroundSensor as GroundSensor
@onready var run_timer = Timer.new()
@export var run_release_grace : float = 0.5
@onready var colliders = %collider_wrangler as PLT_ColliderWrangler

func _ready():
	add_child(run_timer)
	run_timer.wait_time = run_release_grace
	run_timer.one_shot = true
	#if gamepad.has_node("run"):
		#gamepad.get_node("run").just_pressed.connect(_on_run_pressed)

func enter(previous_state = "", _msg: Dictionary = {}):
	graphics.play("shmoove")
	colliders.play("run")
	physics.body.floor_snap_length = SharedPhysics.scale
	var goal = owner.get_node("CameraGoal2D") as CameraGoal2D
	if goal:
		goal.lookat("run")

func proc(_delta):
	if (not running or is_zero_approx(gamepad.stick.x)) and\
			physics.velocity_cache.length_squared() < \
			physics.constants.run_lower_bound * SharedPhysics.scale * \
			SharedPhysics.SANITY_MULTIPLIER: # and \
			#abs(gamepad.stick.x) < physics.constants.stick_walk_threshold:
		transition("walk")
		return
	if physics.move_speed_cache < physics.constants.run_lower_bound/2:
		transition("walk")
		return
	if running and run_timer.is_stopped() and not gamepad.is_button_down("run"):
		run_timer.start()
		
var running : bool = true
var was_skidding :bool = false
func phys(_delta):
	var run_acceleration = physics.constants.run_acceleration
	var run_drag_multiplier = physics.constants.run_drag
	var run_gravity_multiplier = physics.constants.run_gravity
	if not gamepad.is_button_down("run") and run_timer.is_stopped():
		run_acceleration = physics.constants.walk_acceleration
		#run_drag_multiplier = physics.constants.walk_drag
		#run_gravity_multiplier = physics.constants.walk_gravity
		running = false
	else: running = true
	var xAccel = gamepad.stick.x
	# some running logic
	var skidding := false
	if xAccel > 0:
		if physics.velocity_cache.x < 0:
			skidding = true
			xAccel *= physics.constants.skid_acceleration
	elif xAccel < 0:
		if physics.velocity_cache.x > 0:
			skidding = true
			xAccel *= physics.constants.skid_acceleration
	if skidding and not was_skidding:
		graphics.play("skid")
		was_skidding = true
	elif not skidding and was_skidding:
		graphics.play("shmoove")
		was_skidding = false

	#else:
		#const SLOWDOWN = 0.25
		#if physics.velocity_cache.x > 0:
			#xAccel = -SLOWDOWN
		#if physics.velocity_cache.x < 0:
			#xAccel = SLOWDOWN
		#while abs(xAccel * run_acceleration * SharedPhysics.scale) > abs(physics.velocity_cache.x):
			#xAccel *= 0.5
			
	xAccel *= run_acceleration
			
	var drag = run_drag_multiplier
	var grav = run_gravity_multiplier
	var accel = xAccel * physics.floor_movement_normal;
	accel += -physics.body.up_direction * physics.constants.run_centrifuge_force
	
	physics.move_owner(_delta,accel, drag, grav)
	
	var blend = pow(0.5, _delta * 10)
	graphics.rotation = lerp_angle(physics.floor_rotation, graphics.rotation, blend)
	physics.body.up_direction = physics.floor_normal.slerp(physics.body.up_direction, blend)
	if not ground.is_colliding():
		transition("airborn")
		physics.grounded = false
		
func _on_run_pressed():
	#TODO: This logic is meant to apply to dodging, with running as a consequence thereof.
	if active: return
	if state_machine.current.name =="airborn":
		await physics.hit_ground
		if not gamepad.check_button("run"):
			return
	if is_zero_approx( gamepad.stick.x): return
	state_machine.transition("run")
	physics.burst_accelerate(physics.floor_movement_normal * gamepad.stick.x * physics.constants.run_velocity_burst)

func exit():
	physics.body.floor_snap_length = SharedPhysics.scale/7
	physics.body.up_direction = Vector2.UP
	var tween = create_tween()
	tween.tween_property(graphics,"rotation", 0, 0.3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)


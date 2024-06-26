extends State
class_name ST_PH_SMW_Walk

@onready var graphics = %graphics as ActorGraphics2D
@onready var gamepad = %VirtualGamePad as VirtualGamepad
@onready var physics = %SharedPhysics as SharedPhysics
@onready var ground = %GroundSensor as GroundSensor
@onready var colliders = %collider_wrangler as PLT_ColliderWrangler
@onready var facing = %facing as PLA_Facing

func enter(previous_state = "", _msg: Dictionary = {}):
	if physics.velocity_cache.length_squared() < \
			physics.constants.walk_lower_bound * SharedPhysics.scale * \
			SharedPhysics.SANITY_MULTIPLIER and \
			abs(gamepad.stick.x) < physics.constants.stick_walk_threshold:
		transition("idle")
	graphics.play("walk")
	#colliders.play("stand")
	var goal = owner.get_node("CameraGoal2D") as CameraGoal2D
	if (gamepad.stick.x > 0 and not facing.facing_right) or\
			(gamepad.stick.x < 0 and facing.facing_right):
		facing.facing_right = not facing.facing_right
		graphics.play("turn")
	if goal:
		goal.lookat("walk")
	

func proc(_delta):
	#print ("Speed of %s VS Lower Bound of %s" % \
			#[physics.velocity_cache.length_squared(), \
			#physics.constants.walk_lower_bound * SharedPhysics.scale])
	if physics.velocity_cache.length_squared() < \
			physics.constants.walk_lower_bound * SharedPhysics.scale * \
			SharedPhysics.SANITY_MULTIPLIER and \
			abs(gamepad.stick.x) < physics.constants.stick_walk_threshold:
		transition("idle")
		return
	if not is_zero_approx(gamepad.stick.x) and gamepad.has_node("run") and gamepad.is_button_down("run") and\
			abs(physics.velocity_cache.x/SharedPhysics.scale) > physics.constants.walk_upper_bound:
		transition("run")
		
func phys(_delta):
	if graphics.has_method("check_run"):
		if graphics.check_run():
			colliders.play("run")
		else:
			colliders.play("stand")

	var walk_acceleration = physics.constants.walk_acceleration
	var walk_drag_multiplier = physics.constants.walk_drag
	var walk_gravity_multiplier = physics.constants.walk_gravity
	
	var xAccel = gamepad.stick.x
	# some running logic
	if xAccel > 0:
		if physics.velocity_cache.x < 0:
			xAccel *= physics.constants.walk_turn_acceleration
		if not facing.facing_right:
			facing.facing_right = true
			graphics.play("turn")
			var goal = owner.get_node("CameraGoal2D") as CameraGoal2D
			if goal:
				goal.lookat("walk")
	elif xAccel < 0:
		if physics.velocity_cache.x > 0:
			xAccel *= physics.constants.walk_turn_acceleration
		if facing.facing_right:
			facing.facing_right = false
			graphics.play("turn")
			var goal = owner.get_node("CameraGoal2D") as CameraGoal2D
			if goal:
				goal.lookat("walk", false)
	else:
		const SLOWDOWN = 0.25
		if physics.velocity_cache.x > 0:
			xAccel = -SLOWDOWN
		if physics.velocity_cache.x < 0:
			xAccel = SLOWDOWN
		while abs(xAccel * walk_acceleration * SharedPhysics.scale) > abs(physics.velocity_cache.x):
			xAccel *= 0.5
			
	xAccel *= walk_acceleration
			
	var drag = walk_drag_multiplier
	var grav = walk_gravity_multiplier
	
	physics.move_owner(_delta,physics.floor_movement_normal * xAccel, drag, grav)
	graphics.rotation = lerp_angle(physics.floor_rotation, 0, 0.5)
	if not ground.is_colliding() and not physics.body.is_on_floor():
		transition("airborn")
		physics.grounded = false

func exit(_next_state:String=""):
	graphics.rotation = 0



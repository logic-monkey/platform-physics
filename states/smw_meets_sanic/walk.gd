extends State
class_name ST_PH_Walk

@onready var graphics = %graphics as ActorGraphics2D
@onready var gamepad = %VirtualGamePad as VirtualGamepad
@onready var physics = %SharedPhysics as SharedPhysics
@onready var ground = %GroundSensor as GroundSensor

func enter(previous_state = "", _msg: Dictionary = {}):
	graphics.play("walk")

func proc(_delta):
	#print ("Speed of %s VS Lower Bound of %s" % \
			#[physics.velocity_cache.length_squared(), \
			#physics.constants.walk_lower_bound * SharedPhysics.scale])
	if physics.velocity_cache.length_squared() < \
			physics.constants.walk_lower_bound * SharedPhysics.scale * \
			SharedPhysics.SANITY_MULTIPLIER and \
			abs(gamepad.stick.x) < physics.constants.stick_walk_threshold:
		transition("idle")
		
func phys(_delta):
	var walk_acceleration = physics.constants.walk_acceleration
	var walk_drag_multiplier = physics.constants.walk_drag
	var walk_gravity_multiplier = physics.constants.walk_gravity
	
	var xAccel = gamepad.stick.x
	# some running logic
	if xAccel > 0:
		if physics.velocity_cache.x < 0:
			xAccel *= physics.constants.walk_turn_acceleration
		if graphics.scale.x < 0:
			graphics.scale.x = 1
			graphics.play("turn")
	elif xAccel < 0:
		if physics.velocity_cache.x > 0:
			xAccel *= physics.constants.walk_turn_acceleration
		if graphics.scale.x > 0:
			graphics.scale.x = -1
			graphics.play("turn")
		
	xAccel *= walk_acceleration
			
	var drag = walk_drag_multiplier
	var grav = walk_gravity_multiplier
	
	physics.move_owner(_delta,physics.floor_movement_normal * xAccel, drag, grav)
	if not ground.is_colliding():
		transition("airborn")
		physics.grounded = false




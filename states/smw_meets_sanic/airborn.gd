extends State
class_name ST_PH_SMW_Airborn

@onready var graphics = %graphics as ActorGraphics2D
@onready var gamepad = %VirtualGamePad as VirtualGamepad
@onready var physics = %SharedPhysics as SharedPhysics
@onready var colliders = %collider_wrangler as PLT_ColliderWrangler
@onready var wall = %WallSensor as GroundSensor
@onready var facing = %facing as PLA_Facing

var jumping = false
var springing = false
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
var just_wall_kicked = false
var launch_rotation = 0
func enter(previous_state = "", _msg: Dictionary = {}):
	record_of_previous_state = previous_state
	colliders.play("stand")
	if "spring" in _msg: springing = true
	if jumping:
		jump_ground_test = 0.25
		var jump_normal = physics.body.up_direction
		launch_rotation = graphics.rotation
		#jump_normal = jump_normal.slerp(physics.floor_normal, 0.5)
		#jump_normal = jump_normal.normalized()
		var accel = jump_normal * physics.constants.jump_strength
		if previous_state == "run":
					var ramp : float = physics.move_speed_cache
					ramp = clampf(ramp, physics.constants.run_jump_mul_low_speed,physics.constants.run_jump_mul_high_speed)
					ramp -= physics.constants.run_jump_mul_low_speed
					ramp /= physics.constants.run_jump_mul_high_speed - physics.constants.run_jump_mul_low_speed
					accel *= 1 + ((physics.constants.run_jump_multiplier-1)*ramp)
		if previous_state == "wall_slide":
			#wall_kick = false
			graphics.play("wall_kick")
			accel = physics.constants.wall_kick_force * graphics.scale
			just_wall_kicked = true
		else:
			graphics.play("jump")
			
		physics.burst_accelerate(accel,true)

		coyote_timer.stop()
		#await get_tree().physics_frame
		#await get_tree().physics_frame
		#print("And our speed is... %s" % physics.move_speed_cache)
	else:
		
		if previous_state in coyote_whitelist:
			coyote_timer.start()
		graphics.play("fall")

func proc(_delta):
	if not wall: return
	# physics.body.is_on_wall() and
	if (physics.body.is_on_wall() and wall.is_colliding()) and\
			((facing.facing_right and gamepad.stick.x > 0) or\
			(not facing.facing_right and gamepad.stick.x < 0)):
		if just_wall_kicked:
			var t = get_tree()
			await  t.physics_frame
			#await  t.physics_frame
			just_wall_kicked = false
			return
		if state_machine.has_state("wall_slide"): transition("wall_slide")

var was_jumping : bool = false
func phys(_delta):
	#if was_jumping and not jumping:
		#var t = create_tween()
		#graphics.modulate = Color(2.0,2.0,1.0)
		#t.tween_property(graphics,"modulate",Color.WHITE,0.3)
	was_jumping = jumping
	
	var rising_grav = physics.constants.airborn_rising_gravity
	var falling_grav = physics.constants.airborn_falling_gravity
	var drag = physics.constants.airborn_drag
	var rising := true
	if jumping and not gamepad.is_button_down("jump"):
		#print("Jump released...")
		jumping = false
		if physics.velocity_cache.rotated(-launch_rotation).y < 0:
			physics.velocity_cache.y = physics.velocity_cache.y *0.5
	#var j_vector = physics.velocity_cache.rotated(-physics.floor_rotation)
	if physics.velocity_cache.rotated(-launch_rotation).y > 0:

		if jumping: 
			jumping = false

		if springing: springing = false
		graphics.play("fall")
		rising = false
		var goal = owner.get_node("CameraGoal2D") as CameraGoal2D
		if goal:
			goal.lookat("fall")
	else:
		graphics.play("rise")
		var goal = owner.get_node("CameraGoal2D") as CameraGoal2D
		if goal:
			goal.lookat("rise")
	var grav = rising_grav
	if not jumping or springing: 
		grav = falling_grav
		rising = false
	var xAccel = gamepad.stick.x * physics.constants.airborn_acceleration
	if (xAccel > 0 and graphics.scale.x < 0) or \
			(xAccel < 0 and graphics.scale.x > 0):
		facing.facing_right = not facing.facing_right
		graphics.play("turn")
		var goal = owner.get_node("CameraGoal2D") as CameraGoal2D
		if goal:
			if rising: goal.lookat("rise", false)
			else: goal.lookat("fall", false)
	var accel = Vector2(xAccel, 0)
	physics.move_owner(_delta, accel ,drag, grav, true)
	if jump_ground_test > 0: jump_ground_test -= _delta
	elif physics.body.is_on_floor():
		#test_flash()
		if abs(physics.velocity_cache.x/SharedPhysics.scale) > physics.constants.run_lower_bound:
			transition("run")
		elif abs(physics.velocity_cache.x/SharedPhysics.scale) > physics.constants.walk_lower_bound:
			transition("walk")
		else :
			transition("idle")
	if physics.body.is_on_ceiling():
		graphics.play("bonk")
	
@export var valid_states: Array[State]
func jump():
	var goal = owner.get_node("CameraGoal2D") as CameraGoal2D
	if goal:
		goal.lookat("rise")
	if active:
		#if (wall and wall.is_colliding() and not physics.grounded) or physics.body.is_on_wall():
			#wall_kick = true
			#jumping = true
			#transition("airborn")
			#return
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
var wall_kick = false
	
var jump_ground_test :float= 0.0
func exit(_next_state:String=""):
	jumping = false
	jump_ground_test = 0.0
func test_flash():
	var t = create_tween()
	graphics.modulate = Color(5.0,5.0,1.0)
	t.tween_property(graphics,"modulate",Color.WHITE,0.3)


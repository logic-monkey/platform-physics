extends State
class_name ST_PH_HK_Melee

@onready var graphics = %graphics as ActorGraphics2D
@onready var gamepad = %VirtualGamePad as VirtualGamepad
@onready var physics = %SharedPhysics as SharedPhysics

@export var attack_name := "attack"

@onready var cooldown_timer = Timer.new()
@export var cooldown_time := 0.23

@export_group("Hurtboxes", "hurtbox_")
@export var hurtbox_main : HurtBox
@export var hurtbox_up : HurtBox
@export var hurtbox_crouch : HurtBox
@export var hurtbox_air_up : HurtBox
@export var hurtbox_air_down : HurtBox
@export var hurtbox_air : HurtBox
@export var hurtbox_wall : HurtBox
@export var hurtbox_wall_up : HurtBox
var hurtboxen: Array[HurtBox]

func _ready():
	if cooldown_time > 0:
		add_child(cooldown_timer)
		cooldown_timer.wait_time = cooldown_time
		cooldown_timer.one_shot = true
	if attack_name in gamepad.buttons:
		gamepad.buttons[attack_name].just_pressed.connect(attack)
	if hurtbox_main:
		append_box(hurtbox_main)
		append_box(hurtbox_up)
		append_box(hurtbox_crouch)
		append_box(hurtbox_air_up)
		append_box(hurtbox_air_down)
		append_box(hurtbox_air)
		append_box(hurtbox_wall)
		append_box(hurtbox_wall_up)
		for box in hurtboxen:
			box.contact.connect(_on_attack_contact)
	
func append_box(box:HurtBox):
	if not box: return
	if not box in hurtboxen: hurtboxen.append(box)

var record_of_prior_state = ""
func enter(previous_state = "", _msg: Dictionary = {}):
	record_of_prior_state = previous_state
	var direction = null
	if gamepad.stick.y > physics.constants.stick_attack_threshold:
		if previous_state=="airborn": direction = 1
		elif previous_state=="idle":
			previous_state = "crouch"
	if gamepad.stick.y < -physics.constants.stick_attack_threshold: direction = -1
	if hurtbox_main:
		match direction:
			-1:
				match previous_state:
					"airborn":
						hurtbox_air_up.activate()
					"wall_slide":
						hurtbox_wall_up.activate()
					_:
						hurtbox_up.activate()
			1:
				match previous_state:
					"airborn":
						hurtbox_air_down.activate()
					"crouch":
						hurtbox_crouch.activate()
			_:
				match previous_state:
					"airborn":
						hurtbox_air.activate()
					"wall_slide":
						hurtbox_wall.activate()
					"crouch":
						hurtbox_crouch.activate()
					_:
						hurtbox_main.activate()
	var animation_name := attack_name
	match previous_state:
		"airborn":
			animation_name = "air_%s" % attack_name
		"wall_slide":
			animation_name = "wall_%s" % attack_name
		"crouch":
			animation_name = "crouch_%s" % attack_name
	graphics.play(animation_name,direction)
	await graphics.animation_done
	if cooldown_time > 0:
		cooldown_timer.start()
	for box in hurtboxen:
		box.deactivate()
	if previous_state == "crouch":
		transition(record_of_prior_state, {"crouch":true})
		return
	if previous_state == "idle" and direction == -1:
		transition(record_of_prior_state, {"crouch":false})
		return
	transition(record_of_prior_state)
	
	
func phys(_delta):
	physics.move_owner(_delta,Vector2.ZERO,1,1,true)


@export var valid_states: Array[State]
func attack():
	if active:
		await graphics.animation_done
		await get_tree().process_frame
		if not gamepad.check_button(attack_name): return
	if not state_machine.current in valid_states: return
	if not cooldown_timer.is_stopped(): return
	transition(name)

func _on_attack_contact(vector):
	var strength = physics.constants.attack_pushback_strength
	physics.burst_accelerate(vector * strength,true)

func exit(_next_state:String=""):
	for box in hurtboxen:
		box.deactivate()

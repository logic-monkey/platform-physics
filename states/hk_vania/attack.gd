extends State
class_name ST_PH_HK_Melee

@onready var graphics = %graphics as ActorGraphics2D
@onready var gamepad = %VirtualGamePad as VirtualGamepad
@onready var physics = %SharedPhysics as SharedPhysics

@export var attack_name := "attack"

@onready var cooldown_timer = Timer.new()
@export var cooldown_time := 0.23

@export_group("Hurtboxes", "hurtbox_")
@export var hurtbox_forward : HurtBox
@export var hurtbox_up : HurtBox
@export var hurtbox_down : HurtBox

func _ready():
	if cooldown_time > 0:
		add_child(cooldown_timer)
		cooldown_timer.wait_time = cooldown_time
		cooldown_timer.one_shot = true
	if attack_name in gamepad.buttons:
		gamepad.buttons[attack_name].just_pressed.connect(attack)
	hurtbox_down.contact.connect(_on_attack_contact)
	hurtbox_up.contact.connect(_on_attack_contact)
	hurtbox_forward.contact.connect(_on_attack_contact)
	
var record_of_prior_state = ""
func enter(previous_state = "", _msg: Dictionary = {}):
	record_of_prior_state = previous_state
	var direction = null
	if gamepad.stick.y > physics.constants.stick_attack_threshold and\
			previous_state=="airborn": 
		direction = 1
	if gamepad.stick.y < -physics.constants.stick_attack_threshold: direction = -1
	match direction:
		-1:
			hurtbox_up.activate()
		1:
			hurtbox_down.activate()
		_:
			hurtbox_forward.activate()
	graphics.play(attack_name,direction)
	await graphics.animation_done
	if cooldown_time > 0:
		cooldown_timer.start()
	hurtbox_up.deactivate()
	hurtbox_down.deactivate()
	hurtbox_forward.deactivate()
	transition(previous_state)
	
	
func phys(_delta):
	physics.move_owner(_delta,Vector2.ZERO,1,1,true)

func exit():
	pass

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
	physics.burst_accelerate(vector * strength)


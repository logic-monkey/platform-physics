extends State
class_name ST_PH_HK_Hit

@onready var graphics = %graphics as ActorGraphics2D
@onready var gamepad = %VirtualGamePad as VirtualGamepad
@onready var physics = %SharedPhysics as SharedPhysics
@onready var ground = %GroundSensor as GroundSensor
@onready var cwrangler = %collider_wrangler as PLT_ColliderWrangler

@export var death_body : PackedScene
@export var death_vector : Vector2

func poke(vector: Vector2):
	if active or not %i_frames.is_stopped(): return
	%i_frames.start()
	var damage_vector : Vector2 = physics.constants.damage_knockback_vector * physics.constants.damage_knockback_force
	if graphics.scale.x < 0: damage_vector.x *= -1
	damage_vector= damage_vector.rotated(graphics.rotation)
	damage_vector += vector * physics.constants.damage_hit_force_multiplier
	physics.burst_accelerate(damage_vector, true)
	physics.grounded = false
	transition("take_damage")
	
func _ready():
	physics.iframes_done.connect(_on_iframes_timeout)

func enter(previous_state:String="", _msg: Dictionary = {}):
	if HeroCam2D.MAIN: HeroCam2D.MAIN.shake()
	graphics.play("hit")
	if %hp.left > 0: _PS.register_penalty(%damage_number_source,2)
	else: 
		_PS.register_penalty(%damage_number_source,7)
		#if death_body:
			#var db = death_body.instantiate()
			#owner.get_parent().add_child(db)
			#db.global_position = graphics.global_position
			#db.scale = graphics.scale
			#db.velocity = owner.velocity
			#var p = db.get_node("physics") as SharedPhysics
			#p.burst_accelerate(death_vector * db.scale, true)
		#owner.queue_free()
		#return
	await  graphics.animation_done
	if %hp.left <= 0:
		if death_body:
			var db = death_body.instantiate()
			owner.get_parent().add_child(db)
			db.global_position = graphics.global_position
			db.scale = graphics.scale
			db.velocity = owner.velocity
			var p = db.get_node("physics") as SharedPhysics
			p.burst_accelerate(death_vector * db.scale, true)
		owner.queue_free()
		return
	graphics.modulate = Color(Color.WHITE,0.75)
	if physics.grounded: transition("idle")
	else: transition("airborn")
	
func proc(_delta: float):
	pass

func phys(_delta: float):
	physics.move_owner(_delta,Vector2.ZERO,1,1,true)

func exit(_next_state:String=""):
	pass

func _on_iframes_timeout():
	graphics.modulate = Color.WHITE

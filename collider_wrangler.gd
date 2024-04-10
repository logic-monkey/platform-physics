extends Node
class_name PLT_ColliderWrangler

@onready var shared_physics = %SharedPhysics as SharedPhysics

@export 
var collider_sets = \
		{
			"stand": [],
			"duck": []
		}
		
@export 
var hurtbox_sets = \
		{
			"stand": [],
			"duck": []
		}
		
@export var current_state = "stand"
		
func disable_set(cset, disabled : bool = true):
	for c in cset:
		var n = get_node(c)
		if not n or not n is CollisionShape2D: continue
		n.set_deferred("disabled", disabled)
		
func enable_set(cset):
	disable_set(cset, false)

func play(state: String):
	if current_state == state: return
	if not state in collider_sets and not state in hurtbox_sets: return
	current_state = state
	if state in collider_sets:
		for s in collider_sets:
			if s == state: continue
			disable_set(collider_sets[s])
		enable_set(collider_sets[state])
		
	if not state in hurtbox_sets: return
	if shared_physics.iframe: await shared_physics.iframes_done
	for s in hurtbox_sets:
		if s == state: continue
		disable_set(hurtbox_sets[s])
	enable_set(hurtbox_sets[state])

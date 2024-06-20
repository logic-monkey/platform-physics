extends Node2D
class_name GP_PLA_Room

@export var unique_title: String
@export var hero_start_position: Node2D

@export var neighbors: Array[GP_PLA_Neighbor]


func activate():
	GP_PLA.GAMEPLAY.make_me_main(self)
	if not has_node("%activator"): return
	var activator = get_node("%activator")
	if not activator.has_method("activate"): return
	activator.activate()

func _ready():
	if has_node("VisibleOnScreenEnabler2D"):
		$VisibleOnScreenEnabler2D.set_deferred("visible", true)
	pass
	

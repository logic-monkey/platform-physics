@icon("phys.svg")
extends Resource
class_name PLT_PhysData

## Movement categories sorted by relative speed.
enum {\
		IDLE = 			0,
		SKIDDING = 		1,
		WALKING = 		2,
		WALKING_FAST = 	3,
		RUNNING = 		4,
		RUNNING_FAST = 	5,
		BLITZ = 		6,
		AIRBORN = 		7,
	}
	
@export_category("Physics and Input Constants")
@export_group("Stick Thresholds", "stick_")
@export_range(0.0,1.0) var stick_walk_threshold : float = 0.2
@export_range(0.0,1.0) var stick_crouch_threshold : float = 0.8
@export_range(0.0,1.0) var stick_attack_threshold : float = 0.8

@export_group("Idle", "idle_")
@export var idle_gravity : float = 				  0.5
@export var idle_drag : float = 				 5

@export_group("Walking", "walk_")
@export var walk_gravity : float = 				  3
@export var walk_drag : float = 				  1.75
@export var walk_acceleration : float = 		  1
@export var walk_turn_acceleration : float = 	  2
@export var walk_lower_bound : float = 			  5
@export var walk_upper_bound : float = 			 10

@export_group("Running")
@export_subgroup("Running", "run_")
@export var run_gravity : float = 				  5
@export var run_drag : float = 					  0.5
@export var run_acceleration : float = 			  1.5
@export var run_velocity_burst : float = 		  3
@export var run_lower_bound : float = 			 20
@export var run_jump_multiplier : float = 		 1.25
@export var run_jump_mul_low_speed : float =	8.0
@export var run_jump_mul_high_speed : float =	12.0
@export var run_centrifuge_force : float = 2.0	
@export_subgroup("Skidding", "skid_")
@export var skid_acceleration : float = 		  1.5
@export var skid_lower_bound : float = 			 15

@export_group("Airborn")
@export var jump_strength : float = 			 15
@export_subgroup("Airborn", "airborn_")
@export var airborn_acceleration : float =		  0.5 
@export var airborn_rising_gravity : float = 	  1
@export var airborn_falling_gravity : float =	  5
@export var airborn_drag : float = 				  0.4
@export_subgroup("Flapping", "flap_")
@export var flap_acceleration : float = 		  1.5
@export var flap_decay : float = 				  0.75
@export_subgroup("Wall", "wall_")
@export var wall_gravity : float =				0.5
@export var wall_drag : float = 				3.0
@export var wall_press_force : float = 			4.0
@export var wall_kick_force : Vector2 = Vector2(-10,-10)

@export_group("Attack", "attack_")
@export var attack_pushback_strength : float = 	 10

@export_group("Damage", "damage_")
@export var damage_knockback_force: float = 	  1.5
@export var damage_knockback_vector: Vector2 = Vector2(-1, -0.5)
@export var damage_hit_force_multiplier: float =  7

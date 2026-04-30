extends State
class_name GroundedState

@export var kP:float = 150
@export var kD:float = 20

@onready var running_base = find_children("*","RunningBaseState")[0]

func physics_update(_dt:float):
	var curr = player.linear_velocity
	var diff = player.ground_dist
	
	var apply = -kP * (diff-2.48) - kD * curr.y + player.get_gravity().y * player.mass
	
	player.apply_central_force(Vector3(0,apply,0))

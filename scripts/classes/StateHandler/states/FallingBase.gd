extends State
class_name FallingBaseState

var last_walk_dir:Vector3
# // Values that zytwqxs  gave me
const MaxForce = 741.6
const Gain = 150

var t_kP:float = 50
var t_kD:float = 75

@onready var freefall_state = find_children("*","FreefallState")[0]

func physics_update(_dt:float):
	# Walking actually
	var curr = player.linear_velocity
	var target = humanoid.walk_direction*humanoid.walkspeed
	var correctionVector = target - Vector3(curr.x, 0, curr.z)
	correctionVector = correctionVector.normalized() * min(MaxForce,Gain*correctionVector.length())
	var correctionForce = correctionVector*player.mass 
	
	player.apply_central_force(correctionForce)
	
	if humanoid.walk_direction.length() > 0:
		last_walk_dir = humanoid.walk_direction
		
	if last_walk_dir.length() > 0 and !player.rotation_locked:
		var current_forward = player.global_basis.z
	
		var turn_axis = current_forward.cross(target)
		var turn_angle = current_forward.angle_to(target)
		
		var turn_torque = (turn_axis * turn_angle * t_kP) - player.angular_velocity * Vector3(0, t_kD, 0)  # tune this
	
		player.apply_torque(Vector3(0, turn_torque.y, 0))
	
	if !player.grounded:
		humanoid._internal_change_state(self,freefall_state)

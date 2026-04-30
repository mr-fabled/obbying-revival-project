extends State
class_name RunningBaseState

var last_walk_dir:Vector3
# // Values that zytwqxs  gave me
const MaxForce = 741.6
const Gain = 150

var t_kP:float = 50
var t_kD:float = 75

@onready var idle_state:IdleState = find_children("*","IdleState")[0]
@onready var running_state:RunningState = find_children("*","RunningState")[0]
@onready var jumping_state:JumpingState = find_children("*","JumpingState")[0]
@onready var landed_state:LandedState = find_children("*","LandedState")[0]

func _ready():
	if !idle_state or !running_state or !jumping_state:
		push_warning("incorrect setup!")

func _on_enter():
	print("landed")
	humanoid._internal_change_state(self,landed_state)

func physics_update(_dt:float):
	print(humanoid._can_jump)
	if Input.is_action_pressed("ui_accept") and player.grounded and humanoid._can_jump:
		humanoid._can_jump = false
		humanoid._internal_change_state(self,jumping_state)
	
	# Grounded stuff
	var curr = player.linear_velocity
	if player.ground_pos != null and !humanoid._just_jumped:
		var diff = player.ground_dist
		var apply = -14400*(diff - 2.28) - 800 * curr.y + player.get_gravity().y * player.mass
		apply = max(apply, player.get_gravity().y * player.mass)
		player.apply_central_force(Vector3(0, apply, 0))
	
	# Walking actually
	var target = humanoid.walk_direction*humanoid.walkspeed
	var correctionVector = target - Vector3(curr.x, 0, curr.z)
	correctionVector = correctionVector.normalized() * min(MaxForce,Gain*correctionVector.length())
	var correctionForce = correctionVector*player.mass 
	
	player.apply_central_force(correctionForce)
	
	if humanoid.walk_direction.length() > 0:
		last_walk_dir = humanoid.walk_direction
		humanoid._internal_change_state(self,running_state)
	else:
		humanoid._internal_change_state(self,idle_state)
		
	if last_walk_dir.length() > 0 and !player.rotation_locked:
		var current_forward = player.global_basis.z
	
		var turn_axis = current_forward.cross(target)
		var turn_angle = current_forward.angle_to(target)
		
		var turn_torque = (turn_axis * turn_angle * t_kP) - player.angular_velocity * Vector3(0, t_kD, 0)  # tune this
	
		player.apply_torque(Vector3(0, turn_torque.y, 0))

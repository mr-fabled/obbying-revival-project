extends State
class_name BalancingState

@export var kP:float = 2250.0
@export var kD:float = 50.0

var grounded_state:GroundedState
var in_air_state:InAirState

var warning_pushed = false

func _ready():
	grounded_state = find_children("*","GroundedState")[0]
	in_air_state = find_children("*","InAirState")[0]
	
func physics_update(_dt:float):
	if !grounded_state or !in_air_state: 
		if !warning_pushed: push_warning("Setup is incorrect, no grounded/inair state added")
		return
	
	var playerUp:Vector3 = player.global_basis.y
	var diff_global:Vector3 = Vector3.UP.cross(playerUp)
	var ang_vel:Vector3 = player.angular_velocity
	
	var root_basis:Basis = player.global_basis
	
	var diff_local:Vector3 = diff_global * root_basis
	var angVelLocal = ang_vel*root_basis
	
	var inertia = player.inertia
	var torqueLocal = -kP * (inertia * diff_local) - kD * (inertia * angVelLocal)
	
	var applied_torque:Vector3 = root_basis*torqueLocal
	applied_torque.y = 0
	
	player.apply_torque(applied_torque)
	
	if player.grounded and !state_machine.is_state_active(grounded_state):
		state_machine.ChangeState.emit(grounded_state)
	elif !player.grounded and !state_machine.is_state_active(in_air_state):
		state_machine.ChangeState.emit(in_air_state)

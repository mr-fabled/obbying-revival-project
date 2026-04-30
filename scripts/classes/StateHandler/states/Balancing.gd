extends State
class_name BalancingState

@export var kP:float = 7000
@export var kD:float = 100.0

var running_base_state:RunningBaseState
var falling_base_state:FallingBaseState

var warning_pushed = false

func _ready():
	running_base_state = find_children("*","RunningBaseState")[0]
	falling_base_state = find_children("*","FallingBaseState")[0]
	
func physics_update(_dt:float):
	if !running_base_state or !falling_base_state: 
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
	
	if player.rotation_locked:
		var target_angle = player.cam.rotation.y + PI
		var current_angle = player.global_basis.get_euler(EULER_ORDER_YXZ).y
		var angle_diff = wrapf(target_angle - current_angle, -PI, PI)

		# PD controller — tune these to feel like Roblox
		# High kP_yaw = snappy (Roblox is very snappy), kD_yaw damps oscillation
		var kP_yaw = 28000.0
		var kD_yaw = 400.0
		var y_torque = kP_yaw * angle_diff * player.inertia.y - kD_yaw * player.angular_velocity.y * player.inertia.y
		player.apply_torque(Vector3(0, y_torque, 0))
	
	if player.grounded:
		humanoid._internal_change_state(self,running_base_state)
	else:
		humanoid._internal_change_state(self,falling_base_state)

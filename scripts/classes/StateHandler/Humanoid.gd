extends Node
class_name Humanoid

signal ChangeState(new:State)

@export var state:State
@export var input_vector:Vector2
@export var walk_direction:Vector3
@export var walkspeed:float = 16
@export var jumpheight:float = 7.6
@onready var plr:PlayerClass = get_parent()

var _can_jump = true
var _just_jumped = false

var _current_update_index = 0

var to_update:Array[State] = []

func is_state_active(node:State):
	return node in to_update

func _internal_change_state(from:State,new:State):
	if !self.is_state_active(new) and from.is_ancestor_of(new):
		self.ChangeState.emit(new)

func _inject_values(node:Node):
	for x in node.get_children():
		if x is State:
			x.humanoid = self
			x.player = plr
			_inject_values(x)

func _scan_state(node:State):
	var x = node.get_parent()
	if not node in to_update:
		to_update.append(node)
	if x is State and not x in to_update:
		to_update.append(x)
		_scan_state(x)

func _on_state_changed(new: State):
	state._on_exit()
	state = new
	new._on_enter()
	to_update = []
	_scan_state(new)
	to_update.reverse()
	_current_update_index = 0  
	
	if OS.has_feature("editor"):
		var readable = []
		for x in to_update: 
			readable.append(x.name)
		print("state changed ", ">".join(readable))

func _ready():
	_inject_values(self)
	ChangeState.connect(_on_state_changed)
	_on_state_changed(self.get_node("Balancing"))

func _physics_process(delta: float) -> void:
	_current_update_index = 0
	while _current_update_index < to_update.size():
		to_update[_current_update_index].physics_update(delta)
		_current_update_index += 1

func _process(delta: float) -> void:
	for x in to_update:
		x.update(delta)
	input_vector = Input.get_vector("ui_left","ui_right","ui_down","ui_up")
	walk_direction = (plr.cam.global_transform.basis * Vector3(input_vector.x,0,input_vector.y))
	walk_direction.y = 0; walk_direction = walk_direction.normalized()

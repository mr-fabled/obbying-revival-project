extends Node
class_name State

@export var humanoid:Humanoid
@export var player: PlayerClass

# When the hum enters the state
func _on_enter():
	pass

func _on_exit():
	pass

# Every frame
func update(_dt:float):
	pass

# Every physics update
func physics_update(_dt:float):
	pass 

extends State
class_name IdleState

func _on_enter():
	player.anim_tree.travel("Idle")

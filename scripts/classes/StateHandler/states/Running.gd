extends State
class_name RunningState

func _on_enter():
	player.anim_tree.travel("Running")

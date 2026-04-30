extends State
class_name FreefallState

func _on_enter():
	player.anim_tree.travel("Falling")

extends State
class_name JumpingState

func _on_enter():
	player.anim_tree.travel("Jump")
	player.apply_central_impulse(Vector3.UP*humanoid.jumpheight*player.mass+player.get_gravity())
	humanoid._just_jumped = true
	
	get_tree().create_timer(.125,false,true).timeout.connect(func():
		humanoid._just_jumped = false)

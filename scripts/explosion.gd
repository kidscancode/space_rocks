extends AnimatedSprite

func _on_explosion_finished():
	queue_free()

func _on_explosion_enter_tree():
	add_to_group("explosions")
	set_animation("regular")
	set_frame(0)
	play()

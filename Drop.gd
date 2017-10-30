extends RigidBody2D

export var speed = 75
var type = null

func _ready():
	type = 'star'
	linear_velocity = Vector2(speed, 0).rotated(rand_range(0, 2*PI))

func _on_Lifetime_timeout():
	queue_free()
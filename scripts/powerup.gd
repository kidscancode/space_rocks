extends Area2D

onready var timer = get_node("lifetime")

const SPEED = 80
var types = ['bolt', 'shield', 'pill', 'pill']

var vel = Vector2()
var pos = Vector2()
var type

func _ready():
	vel = Vector2(SPEED, 0).rotated(rand_range(0, 2*PI))
	type = types[randi() % types.size()]
	get_node("images").set_animation(type)
	add_to_group("powerups")
	set_process(true)

func _process(delta):
	pos += vel * delta
	set_pos(pos)

func pickup():
	queue_free()

func _on_lifetime_timeout():
	queue_free()

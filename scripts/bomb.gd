extends Area2D

var pos = Vector2()
var vel = Vector2()
const ROT_SPEED = 50
const SPEED = 50
onready var sprite_node = get_node("AnimatedSprite")

func _ready():
	set_process(true)
	#vel = Vector2(50, 0).rotated(rand_range(0, 2*PI))

func _process(delta):
	set_pos(get_pos() + vel * delta)

	set_rotd(get_rotd() + ROT_SPEED * delta)

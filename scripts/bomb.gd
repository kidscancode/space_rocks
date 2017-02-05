extends Area2D

var pos = Vector2(300, 200)
var vel = Vector2()
const ROT_SPEED = 50
onready var sprite_node = get_node("AnimatedSprite")

func _ready():
	set_process(true)
	vel = Vector2(100, 0)

func _process(delta):
	pos += vel * delta

	set_rotd(get_rotd() + ROT_SPEED * delta)
	set_pos(pos)

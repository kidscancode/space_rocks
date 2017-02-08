extends Area2D

var vel = Vector2()
const ROT_SPEED = 50
const SPEED = 75
var lifetime
onready var sprite_node = get_node("AnimatedSprite")
onready var main_scene = get_node("/root/main")


func _ready():
	lifetime = get_node("lifetime")
	lifetime.connect("timeout", self, "die")
	set_process(true)

func _process(delta):
	set_pos(get_pos() + vel * delta)
	set_rotd(get_rotd() + ROT_SPEED * delta)

func die():
	main_scene.play_explosion(get_global_pos(), "sonic")
	queue_free()

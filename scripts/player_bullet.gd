extends Area2D

var screen_size
var dir
var pos
var lifetime
var speed = 1000

func _ready():
	add_to_group("bullets")
	screen_size = get_viewport_rect().size
	lifetime = get_node("lifetime")
	lifetime.connect("timeout", self, "die")
	dir = get_node("../../player").get_rot()
	set_rot(dir)
	speed = Vector2(speed, 0).rotated(dir + deg2rad(90))
	set_process(true)

func die():
	queue_free()

func _process(delta):
	set_pos(get_pos() + speed * delta)

func _on_player_bullet_area_enter( area ):
	if area.get_parent().get_groups().has("meteors"):
		area.get_parent().get_parent().explode()
		queue_free()

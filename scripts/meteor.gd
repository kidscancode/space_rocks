extends Node2D

var sprites = {
	'big': ['big1', 'big2', 'big3', 'big4'],
	'med': ['med1', 'med2'],
	'sm': ['sm1', 'sm2'],
	'tiny': ['tiny1', 'tiny2']
}

var points = {'big': 5, 'med': 10, 'sm': 25, 'tiny': 50}
var damage = {'big': 45, 'med': 20, 'sm': 15, 'tiny': 5}

export var SPEED_MIN = 50
export var SPEED_MAX = 200
export var ROT_MAX = 120

var vel
var pos
var rot
var rot_speed
var screen_size
var mysprite
var size

func _ready():
	screen_size = get_viewport_rect().size
	#choose_sprite(size)
	vel = Vector2(rand_range(SPEED_MIN, SPEED_MAX), 0).rotated(rand_range(0, 360))
	pos = Vector2(rand_range(0, screen_size.width), 0)
	#pos = screen_size / 2
	rot = rand_range(0, 360)
	set_rot(deg2rad(rot))
	rot_speed = rand_range(-ROT_MAX, ROT_MAX)
	set_pos(pos)
	set_process(true)

func choose_sprite(target='big'):
	randomize()
	size = target
	var path = "res://meteors/%s.tscn"
	path = path % sprites[size][randi() % sprites[size].size()]
	var meteor_class = load(path)
	mysprite = meteor_class.instance()
	add_child(mysprite)
	mysprite.add_to_group("meteors")

func _process(delta):
	rot += deg2rad(rot_speed) * delta
	pos += vel * delta
	# wrap screen - better way?
	var rect = mysprite.get_texture().get_size()
	if pos.x > screen_size.width + rect.width / 2:
		pos.x = -rect.width / 2
	if pos.x < -rect.width / 2:
		pos.x = screen_size.width + rect.width / 2
	if pos.y < -rect.height / 2:
		pos.y = screen_size.height + rect.height / 2
	if pos.y > screen_size.height + rect.height / 2:
		pos.y = -rect.height / 2

	set_rot(rot)
	set_pos(pos)

func explode():
	if size != 'tiny':
		var newsize = 'med'
		if size == 'med':
			newsize = 'sm'
		elif size == 'sm':
			newsize = 'tiny'
		get_node("/root/main").spawn_meteors(2, newsize, pos, false, vel)
	queue_free()
	get_node("/root/main").score += points[size]
	get_node("/root/main").play_explosion(pos)
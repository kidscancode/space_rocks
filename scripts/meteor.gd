extends Node2D

onready var main_scene = get_node("/root/main")
var powerup = preload("res://powerup.tscn")

var sprites = {
	'big': ['big1', 'big2', 'big3', 'big4'],
	'med': ['med1', 'med2'],
	'sm': ['sm1', 'sm2'],
	'tiny': ['tiny1', 'tiny2']
}

var points = {'big': 5, 'med': 10, 'sm': 25, 'tiny': 50}
var damage = {'big': 40, 'med': 20, 'sm': 15, 'tiny': 10}

export var SPEED_MIN = 50
export var SPEED_MAX = 200
export var ROT_MAX = 120
export var POW_CHANCE = 5  # from 100

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
	vel = Vector2(rand_range(SPEED_MIN, SPEED_MAX), 0).rotated(rand_range(0, 2*PI))
	pos = Vector2(rand_range(0, screen_size.width), 0)
	#pos = screen_size / 2
	rot = rand_range(0, 360)
	set_rotd(rot)
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
	rot += rot_speed * delta
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

	set_rotd(rot)
	set_pos(pos)

func explode():
	if size != 'tiny':
		var newsize = 'med'
		if size == 'med':
			newsize = 'sm'
		elif size == 'sm':
			newsize = 'tiny'
		main_scene.spawn_meteors(2, newsize, pos, false, vel)
	spawn_powerup()
	queue_free()
	main_scene.score += points[size]
	main_scene.play_explosion(pos)

func spawn_powerup():
	if randi() % 100 < POW_CHANCE:
		var pow_instance = powerup.instance()
		main_scene.add_child(pow_instance)
		pow_instance.pos = pos
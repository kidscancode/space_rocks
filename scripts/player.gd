extends Area2D

var bullet = preload("res://player_bullet.tscn")
onready var bullet_container = get_node("../bullet_container")

var ROT_SPEED = deg2rad(180)  # degrees per sec
var THRUST = 900
var MAX_VEL = 500
var FRICTION = 0.65

var screen_size
var can_shoot = true
var shoot_timer
var pos
var rot = 0
var vel = Vector2(0, 0)
var acc = Vector2(0, 0)
var shield = 100

func _ready():
	screen_size = get_viewport_rect().size
	shoot_timer = get_node("shoot_timer")
	shoot_timer.connect("timeout", self, "enable_shoot")
	pos = screen_size / 2
	set_pos(pos)
	set_rot(rot)
	set_process(true)

func _process(delta):
	if Input.is_action_pressed("shoot_main") and can_shoot:
		shoot()
		#shoot_double()
		can_shoot = false
		shoot_timer.start()
	if Input.is_action_pressed("rotate_left"):
		rot += ROT_SPEED * delta
	if Input.is_action_pressed("rotate_right"):
		rot -= ROT_SPEED * delta
	if Input.is_action_pressed("thrust"):
		acc = Vector2(THRUST, 0).rotated(rot)
		get_node("exhaust").show()
	else:
		acc = Vector2(0, 0)
		get_node("exhaust").hide()
	acc += vel * -FRICTION
	vel += acc * delta
	if vel.length() > MAX_VEL:
		vel = vel.normalized() * MAX_VEL
	pos += vel * delta
	# wrap screen - better way?
	#var ship_size = get_node("ship").get_texture().get_size()
	var ship_size = Rect2(0, 0, 50, 50).size
	if pos.x > screen_size.width + ship_size.width / 2:
    	pos.x = -ship_size.width / 2
	if pos.x < -ship_size.width / 2:
		pos.x = screen_size.width + ship_size.width / 2
	if pos.y < -ship_size.height / 2:
		pos.y = screen_size.height + ship_size.height / 2
	if pos.y > screen_size.height + ship_size.height / 2:
		pos.y = -ship_size.height / 2
	set_rot(rot - deg2rad(90))
	set_pos(pos)

func shoot():
	var new_bullet = bullet.instance()
	bullet_container.add_child(new_bullet)
	new_bullet.set_pos(get_node("muzzle(nose)").get_global_pos())
	get_node("shoot_sound").play("sfx_wpn_laser7")

func shoot_double():
	for n in ["muzzle(lwing)", "muzzle(rwing)"]:
		var new_bullet = bullet.instance()
		bullet_container.add_child(new_bullet)
		new_bullet.set_pos(get_node(n).get_global_pos())

func enable_shoot():
	can_shoot = true

func _on_player_area_enter( area ):
	if area.get_parent().get_groups().has("meteors"):
		var dmg = area.get_parent().get_parent().damage[area.get_parent().get_parent().size]
		shield -= dmg
		print(shield)
		area.get_parent().get_parent().explode()

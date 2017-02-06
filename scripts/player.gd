extends Area2D

var bullet = preload("res://player_bullet.tscn")
onready var bullet_container = get_node("../bullet_container")

var ROT_SPEED = 180  # degrees per sec
var THRUST = 900
var MAX_VEL = 500
var FRICTION = 0.65

var screen_size
var can_shoot = true
onready var shoot_timer = get_node("shoot_timer")
var pos
var rot = 0
var vel = Vector2(0, 0)
var acc = Vector2(0, 0)
export var shield_level = 100
export var shield_on = true
var gun_count = 2
var gun_locations = {
	1: ["muzzle(nose)"],
	2: ["muzzle(lwing)", "muzzle(rwing)"]
}

func _ready():
	screen_size = get_viewport_rect().size
	shoot_timer.connect("timeout", self, "enable_shoot")
	pos = screen_size / 2
	set_pos(pos)
	set_rotd(rot)
	set_process(true)

func _process(delta):
	if Input.is_action_pressed("shoot_main") and can_shoot:
		shoot(gun_count)
		can_shoot = false
		shoot_timer.start()
	if Input.is_action_pressed("rotate_left"):
		rot += ROT_SPEED * delta
	if Input.is_action_pressed("rotate_right"):
		rot -= ROT_SPEED * delta
	if Input.is_action_pressed("thrust"):
		acc = Vector2(THRUST, 0).rotated(deg2rad(rot))
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
	set_rotd(rot - 90)
	set_pos(pos)
	if shield_level < 0:
		shield_level = 0
	if shield_level == 0 and shield_on:
		shield_on = false
		get_node("shield").hide()
		get_node("shield_sounds").play("sfx_sound_shutdown1")

func shoot(count):
	for n in gun_locations[count]:
		var new_bullet = bullet.instance()
		bullet_container.add_child(new_bullet)
		new_bullet.set_pos(get_node(n).get_global_pos())
		get_node("shoot_sound").play("sfx_wpn_laser7")

func enable_shoot():
	can_shoot = true

func _on_player_area_enter( area ):
	if area.get_parent().get_groups().has("meteors"):
		var meteor = area.get_parent().get_parent()
		var dmg = meteor.damage[meteor.size]
		if shield_on:
			shield_level -= dmg
			meteor.explode()
		else:
			get_tree().reload_current_scene()
	if area.get_groups().has("powerups"):
		if area.type == 'shield':
			shield_on = true
			if shield_level < 100:
				shield_level = min(shield_level + 20, 100)
				get_node("shield_sounds").play("sfx_sounds_powerup18")
		area.pickup()
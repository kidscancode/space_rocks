extends Area2D

var bullet = preload("res://player_bullet.tscn")
var bomb = preload("res://bomb.tscn")
onready var bullet_container = get_node("../bullet_container")

var thrust_level = {1: 500, 2: 600, 3: 700, 4: 800}
var rot_level = {1: 100, 2: 150, 3: 180, 4: 210}
var shield_regen = {1: 5, 2: 7.5, 3: 10, 4: 15}
var fire_rate = {1: 5, 2: 7.5, 3: 10, 4: 15}

var ROT_SPEED = 180  # degrees per sec
var THRUST = 500
var MAX_VEL = 400
var FRICTION = 0.65
var SHIELD_REGEN = 5
var shield_level = 100
var shield_on = true

var screen_size
var can_shoot = true
onready var bomb_timer = get_node("bomb_timer")
onready var shoot_timer = get_node("shoot_timer")
onready var pow_timer = get_node("pow_timer")
var pos
var rot = 0
var vel = Vector2(0, 0)
var acc = Vector2(0, 0)
var bomb_active = true
var gun_count = 1
var gun_locations = {
	1: ["muzzle(nose)"],
	2: ["muzzle(lwing)", "muzzle(rwing)"],
	3: ["muzzle(nose)", "muzzle(lwing)", "muzzle(rwing)"],
	4: ["muzzle(nose)", "muzzle(lwing)", "muzzle(rwing)"]
}



func _ready():
	screen_size = get_viewport_rect().size
	shoot_timer.connect("timeout", self, "enable_shoot")
	bomb_timer.connect("timeout", self, "enable_bomb")
	pow_timer.connect("timeout", self, "pow_timeout")
	pos = screen_size / 2
	set_pos(pos)
	set_rotd(rot)
	set_process(true)

func _process(delta):
	gun_count = global.upgrade_level['guns']
	shield_level = min(shield_level + shield_regen[global.upgrade_level['shield_regen']] * delta, 100)
	if Input.is_action_pressed("shoot_main") and can_shoot:
		shoot(gun_count)
		can_shoot = false
		shoot_timer.start()
	if Input.is_action_pressed("shoot_special") and bomb_active:
		launch_bomb()
		bomb_active = false
		bomb_timer.start()
	if Input.is_action_pressed("rotate_left"):
		rot += rot_level[global.upgrade_level['rot']] * delta
	if Input.is_action_pressed("rotate_right"):
		rot -= rot_level[global.upgrade_level['rot']] * delta
	if Input.is_action_pressed("thrust"):
		acc = Vector2(thrust_level[global.upgrade_level['thrust']], 0).rotated(deg2rad(rot))
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
		get_node("pow_sounds").play("shield_down")

func shoot(count):
	for n in gun_locations[count]:
		var new_bullet = bullet.instance()
		bullet_container.add_child(new_bullet)
		new_bullet.set_pos(get_node(n).get_global_pos())
		var dir = get_rotd() + get_node(n).get_rotd()
		new_bullet.set_rotd(dir)
		new_bullet.vel = Vector2(new_bullet.speed, 0).rotated(deg2rad(dir + 90))
		get_node("shoot_sound").play("sfx_wpn_laser7")

func enable_shoot():
	can_shoot = true

func enable_bomb():
	bomb_active = true

func pow_timeout():
	gun_count = max(1, gun_count - 1)
	get_node("pow_sounds").play("gun_down")
	#print("gun downgraded")

func launch_bomb():
	var new_bomb = bomb.instance()
	bullet_container.add_child(new_bomb)
	new_bomb.set_pos(get_node("muzzle(tail)").get_global_pos())
	var dir = get_rotd()
	new_bomb.vel = Vector2(-new_bomb.SPEED, 0).rotated(deg2rad(dir + 90))
	get_node("shoot_sound").play("sfx_wpn_laser6")

func _on_player_area_enter( area ):
	if area.get_parent().get_groups().has("meteors"):
		var meteor = area.get_parent().get_parent()
		var dmg = meteor.damage[meteor.size]
		if shield_on:
			shield_level -= dmg
			meteor.explode()
		else:
			global.game_over = true
			global.goto_scene("res://main.tscn")
	if area.get_groups().has("powerups"):
		if area.type == 'shield':
			shield_on = true
			if shield_level < 100:
				shield_level = min(shield_level + 20, 100)
				get_node("pow_sounds").play("shield_up")

		if area.type == 'bolt':
			gun_count = min(gun_count + 1, 3)
			pow_timer.set_wait_time(10)
			pow_timer.start()
			get_node("pow_sounds").play("gun_up")
		if area.type == 'pill':
			global.cash += 5
			get_node("pow_sounds").play("cash_up")
		area.pickup()
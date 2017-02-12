# TODO: make HUD a separate scene
extends Node2D

var meteor = preload("res://meteor.tscn")
var explosion = preload("res://explosion.tscn")

onready var transition_timer = get_node("transition_timer")
onready var meteor_container = get_node("meteor_container")
onready var message_box = get_node("HUD/message")

var screen_size
#var paused = false
var expl_sounds

# HUD GRAPHICS - TODO: move to separate file
var shield_bar_green = preload("res://art/gui/barHorizontal_green_mid 200.png")
var shield_bar_yellow = preload("res://art/gui/barHorizontal_yellow_mid 200.png")
var shield_bar_red = preload("res://art/gui/barHorizontal_red_mid 200.png")

func _ready():
	if global.game_over:
		global.new_game()
	expl_sounds = ['small1', 'small2', 'small3']
	screen_size = get_viewport_rect().size
	set_process(true)
	get_node("music").play()
	transition_timer.connect("timeout", self, "transition")
	begin_next_level()
	#transition_timer.start()
	#message_box.set_text("Wave %s" % global.level)
	#message_box.show()

func _process(delta):
	if meteor_container.get_child_count() == 0 and transition_timer.get_time_left() == 0:
		global.goto_scene("res://shop.tscn")
		#begin_next_level()
		#level += 1
		#transition_timer.start()
		#message_box.set_text("Wave %s" % level)
		#message_box.show()
		#spawn_meteors(level + 2, 'big', Vector2(0, 0), true)
	get_node("HUD/score").set_text(str(global.score))
	show_hud_shield()

func begin_next_level():
	global.level += 1
	transition_timer.start()
	message_box.set_text("Wave %s" % global.level)
	message_box.show()

func show_hud_shield():
	if get_node("player").shield_on:
		get_node("HUD/shield_indicator/bar").show()
		var texture = shield_bar_green
		var level = get_node("player").shield_level
		if level < 40:
			texture = shield_bar_red
		elif level < 70:
			texture = shield_bar_yellow
		get_node("HUD/shield_indicator/bar").set_progress_texture(texture)
		get_node("HUD/shield_indicator/bar").set_value(level)
	else:
		get_node("HUD/shield_indicator/bar").hide()
		# TODO: set shield indicator to off
		pass

func spawn_meteors(num, size, loc, rand=false, vel=Vector2(0, 0)):
	for i in range(num):
		var meteor_instance = meteor.instance()
		meteor_instance.choose_sprite(size)
		get_node("meteor_container").add_child(meteor_instance)
		if rand:
			meteor_instance.pos = Vector2(rand_range(0, screen_size.width), 0)
		else:
			meteor_instance.pos = loc
		meteor_instance.vel += vel

func play_explosion(pos, type):
	if type == 'regular':
		get_node("explosion_sounds").play(expl_sounds[randi() % expl_sounds.size()])
	elif type == 'sonic':
		get_node("explosion_sounds").play('sonic')
	var expl_instance = explosion.instance()
	add_child(expl_instance)
	expl_instance.set_animation(type)
	expl_instance.set_pos(pos)

func transition():
	# hide announcement
	spawn_meteors(global.level + 2, 'big', Vector2(0, 0), true)
	message_box.hide()

# TODO: make HUD a separate scene
extends Node2D

var meteor = preload("res://meteor.tscn")
var explosion = preload("res://explosion.tscn")

var screen_size
var level = 1
var score = 0
var expl_sounds

# HUD GRAPHICS - TODO: move to separate file
var shield_bar_green = preload("res://art/gui/barHorizontal_green_mid 200.png")
var shield_bar_yellow = preload("res://art/gui/barHorizontal_yellow_mid 200.png")
var shield_bar_red = preload("res://art/gui/barHorizontal_red_mid 200.png")

func _ready():
	expl_sounds = get_node("explosion_sounds").get_sample_library().get_sample_list()
	screen_size = get_viewport_rect().size
	spawn_meteors(3, 'big', screen_size/2, true)
	set_process(true)
	get_node("music").play()

func _process(delta):
	if get_node("meteor_container").get_child_count() == 0:
		level += 1
		spawn_meteors(level + 2, 'big', Vector2(0, 0), true)
	get_node("HUD/score").set_text(str(score))
	show_hud_shield()

func show_hud_shield():
	if get_node("player").shield_on:
		get_node("HUD/shield_indicator").show()
		var texture = shield_bar_green
		var level = get_node("player").shield_level
		if level < 30:
			texture = shield_bar_red
		elif level < 60:
			texture = shield_bar_yellow
		get_node("HUD/shield_indicator/bar").set_progress_texture(texture)
		get_node("HUD/shield_indicator/bar").set_value(level)
	else:
		get_node("HUD/shield_indicator").hide()
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

func play_explosion(pos):
	get_node("explosion_sounds").play(expl_sounds[randi() % expl_sounds.size()])
	var expl_instance = explosion.instance()
	add_child(expl_instance)
	expl_instance.set_pos(pos)
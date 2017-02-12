extends Node

var POW_CHANCE = 7  # from 100

# RUNTIME PROPERTIES
var paused = false
var current_scene = null
var new_scene = null
var game_over = true

# upgradable properties
var level = 0
var score = 0
var cash = 225
var upgrade_level = {'thrust': 1, 'rot': 1,
                     'guns': 1, 'fire_rate': 1,
                     'shield_regen': 1}
var upgrade_costs = {1: 10, 2: 20, 3: 30, 4: 0}

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child( root.get_child_count() - 1 )

func goto_scene(path):
	var s = ResourceLoader.load(path)
	new_scene = s.instance()
	get_tree().get_root().add_child(new_scene)
	get_tree().set_current_scene(new_scene)
	current_scene.queue_free()
	current_scene = new_scene

func new_game():
	game_over = false
	level = 0
	score = 0
	cash = 200
	upgrade_level = {'thrust': 1, 'rot': 1,
                     'guns': 1, 'fire_rate': 1,
                     'shield_regen': 1}
extends Node

var POW_CHANCE = 7  # from 100

# RUNTIME PROPERTIES
var paused = false
var current_scene = null
var new_scene = null

# upgradable properties
var cash = 0
var upgrade_level = {'thrust': 2, 'rot': 1,
                     'guns': 1, 'fire_rate': 3,
                     'shield_recharge': 1}
var upgrade_costs = {1: 10, 2: 10, 3: 10}

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child( root.get_child_count() - 1 )

func goto_scene(path):
	var s = ResourceLoader.load(path)
	new_scene=s.instance()
	get_tree().get_root().add_child(new_scene)
	get_tree().set_current_scene(new_scene)
	current_scene.queue_free()
	current_scene=new_scene

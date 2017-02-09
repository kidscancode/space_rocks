extends Node

var paused = false
var current_scene = null
var new_scene = null

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

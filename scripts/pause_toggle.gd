extends Panel

onready var pause_sounds = get_node("pause_sounds")

func _ready():
	set_process_input(true)

func _input(event):
	if event.is_action_pressed("pause_toggle"):
		global.paused = not global.paused
		get_tree().set_pause(global.paused)
		set_hidden(not global.paused)
		get_node("../message").set_hidden(global.paused)
		if global.paused == true:
			pause_sounds.play("pause_in")
		else:
			pause_sounds.play("pause_out")


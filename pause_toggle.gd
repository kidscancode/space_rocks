extends Panel

var paused = false

func _ready():
	set_process_input(true)

func _input(event):
	if event.is_action_pressed("pause_toggle"):
		paused = not paused
		get_tree().set_pause(paused)
		set_hidden(not paused)

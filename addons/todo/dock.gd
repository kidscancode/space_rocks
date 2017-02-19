tool
extends EditorPlugin

var dock
var texture_todo
var texture_fixme
var re = RegEx.new()

func _enter_tree():
	print("TODO created.")
	re.compile("(TODO|FIXME)\\:[:space:]*([^\\n]*)[:space:]*")
	
	dock = preload("scenes/TODO List.tscn").instance()
	
	texture_todo = ImageTexture.new()
	texture_todo.load("res://addons/todo/images/todo.png")
	
	texture_fixme = ImageTexture.new()
	texture_fixme.load("res://addons/todo/images/fixme.png")
	
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_BL, dock)
	dock.get_node("Toolbar/Refresh").connect("pressed", self, "populate_tree")
	dock.get_node("Toolbar/TODO").connect("pressed", self, "populate_tree", ["TODO"])
	dock.get_node("Toolbar/FIXME").connect("pressed", self, "populate_tree", ["FIXME"])
	populate_tree()

func _exit_tree():
	dock.get_node("Toolbar/Refresh").disconnect("pressed", self, "populate_tree")
	dock.get_node("Toolbar/TODO").disconnect("pressed", self, "populate_tree")
	dock.get_node("Toolbar/FIXME").disconnect("pressed", self, "populate_tree")
	remove_control_from_docks(dock)
	print("TODO freed.")

func item_activated():
	var tree = dock.get_node("Background/Scrollbar/Contents")
	var file = tree.get_selected().get_metadata(0)
	edit_resource(load(file))

func populate_tree(type_filter = null):
	var tree = dock.get_node("Background/Scrollbar/Contents")
	
	tree.clear()
	
	if not tree.is_connected("item_activated", self, "item_activated"):
		tree.connect("item_activated", self, "item_activated")
	
	var root = tree.create_item()
	tree.set_column_expand(0, true)
	tree.set_hide_root(true)
	#tree.set_hide_folding(true)
	
	var files = find_all_todos()
	
	if type_filter == "TODO":
		files = filter_results(files, "TODO")
	elif type_filter == "FIXME":
		files = filter_results(files, "FIXME")
	
	for file in files:
		var where = file["file"]
		var todos = file["todos"]
		if todos.size():
			var file_node = tree.create_item(root)
			file_node.set_metadata(0, file["file"])
			file_node.set_text(0, where)
			for todo in todos:
				var todo_node = tree.create_item(file_node)
				todo_node.set_metadata(0, file["file"])
				if "line" in todo:
					todo_node.set_text(0, "%03d: %s" % [todo["line"], todo["text"]])
					todo_node.set_tooltip(0, todo["text"])
					if todo["type"] == "TODO":
						todo_node.set_icon(0, texture_todo)
					else:
						todo_node.set_icon(0, texture_fixme)
				else:
					todo_node.set_text(0, todo["text"])
					todo_node.move_to_bottom()
					file_node.set_collapsed(true)


func filter_results(results, type):
	var output = []
	for file in results:
		var filtered = {}
		filtered["file"] = file["file"]
		filtered["todos"] = []
		for todo in file["todos"]:
			if todo["type"] == type:
				filtered["todos"].append(todo)
		output.append(filtered)
	return output

func find_files(directory, extensions, recur = false):
	var results = []
	var dir = Directory.new()
	
	if dir.open(directory) != OK:
		return results
	
	dir.list_dir_begin()
	
	var file = dir.get_next()
	
	while file != "":
		var location = dir.get_current_dir() + "/" + file
		
		if file in [".", ".."]:
			file = dir.get_next()
			continue
		
		if recur and dir.current_is_dir():
			for subfile in find_files(location, extensions, true):
				results.append(subfile)
		
		if not dir.current_is_dir() and file.extension().to_lower() in extensions:
			results.append(location)
		
		file = dir.get_next()
	
	dir.list_dir_end()
	return results

func get_all_scripts(node):
	var scripts = [];
	
	var script = node.get_script()
	if script != null:
		scripts.append(script)
	
	for child in node.get_children():
		for script in get_all_scripts(child):
			scripts.append(script)
	
	return scripts

func find_all_todos():
	var files = find_files("res://", ["gd", "tscn", "xscn", "scn"], true)
	var checked = []
	var todos = []
	
	for file in files:
		if file.extension().to_lower() == "gd":
			var file_todos = {"file": file, "todos": []}
			for todo in todos_in_file(file):
				file_todos["todos"].append(todo)
			todos.append(file_todos)
		else:
			var scene = load(file).instance()
			var scripts = get_all_scripts(scene)
			for script in scripts:
				if not script.get_path() in checked:
					var file_todos = {"file": script.get_path(), "todos": []}
					for todo in todos_in_string(script.get_source_code()):
						file_todos["todos"].append(todo)
					todos.append(file_todos)
					checked.append(script.get_path())
	
	return todos

func todos_in_file(location):
	var todos = []
	var line_count = 0
	
	var file = File.new()
	file.open(location, File.READ)
	todos = todos_in_string(file.get_as_text())
	file.close()
	return todos

func todos_in_string(string):
	string = string.split("\n")
	var todos = []
	var line_count = 0
	
	while string.size():
		var line = string[0]
		string.remove(0)
		
		line_count += 1
		
		var pos = re.find(line, 0)
		if pos != -1:
			todos.append({"line": line_count, "type": re.get_capture(1), "text": re.get_capture(2)})
	
	return todos
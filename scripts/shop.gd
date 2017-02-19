extends Control

onready var cash_label = get_node("cash_frame/cash")
onready var done_button = get_node("done_button")

var on = load("res://art/gui/squareGreen.png")
var off = load("res://art/gui/square_shadow.png")
var indicators = {1:'box1', 2:'box2', 3:'box3', 4:'box4'}

func _ready():
	done_button.connect("pressed", self, "_finished")
	for upgrade in global.upgrade_level:
		var n = get_node("%s_button/button" % upgrade)
		n.connect("pressed", self, "_make_purchase_%s" % upgrade)
		n.connect("mouse_enter", self, "_hover_sound")
	_set_current_levels()

func _hover_sound():
	get_node("sounds").play("touch")

func _set_current_levels():
	cash_label.set_text("%s" % global.cash)
	for upgrade in global.upgrade_level:
		# set upgrade levels
		var n = get_node(upgrade)
		for box_num in indicators:
			if box_num <= global.upgrade_level[upgrade]:
				n.get_node(indicators[box_num]).set_texture(on)
			else:
				n.get_node(indicators[box_num]).set_texture(off)
		# set button text/status
		var b = get_node("%s_button/button" % upgrade)
		var cost = global.upgrade_costs[global.upgrade_level[upgrade]]
		if global.upgrade_level[upgrade] < 4:
			b.set_text(str(cost))
		else:
			b.set_text("n/a")
			b.set_disabled(true)
		if cost > global.cash:
			b.set_disabled(true)

func _finished():
	get_node("sounds").play("ok")
	global.goto_scene("res://main.tscn")

func _make_purchase_guns():
	var level = global.upgrade_level['guns']
	global.cash -= global.upgrade_costs[level]
	global.upgrade_level['guns'] += 1
	get_node("sounds").play("up")
	_set_current_levels()

func _make_purchase_fire_rate():
	var level = global.upgrade_level['fire_rate']
	global.cash -= global.upgrade_costs[level]
	global.upgrade_level['fire_rate'] += 1
	get_node("sounds").play("up")
	_set_current_levels()

func _make_purchase_thrust():
	var level = global.upgrade_level['thrust']
	global.cash -= global.upgrade_costs[level]
	global.upgrade_level['thrust'] += 1
	get_node("sounds").play("up")
	_set_current_levels()

func _make_purchase_rot():
	var level = global.upgrade_level['rot']
	global.cash -= global.upgrade_costs[level]
	global.upgrade_level['rot'] += 1
	get_node("sounds").play("up")
	_set_current_levels()

func _make_purchase_shield_regen():
	var level = global.upgrade_level['shield_regen']
	global.cash -= global.upgrade_costs[level]
	global.upgrade_level['shield_regen'] += 1
	get_node("sounds").play("up")
	_set_current_levels()
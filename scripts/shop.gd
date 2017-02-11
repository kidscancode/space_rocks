extends Control

onready var cash_label = get_node("cash_frame/cash")

var on = load("res://art/gui/squareGreen.png")
var off = load("res://art/gui/square_shadow.png")
var indicators = {1:'box1', 2:'box2', 3:'box3', 4:'box4'}

func _ready():
	cash_label.set_text("Cash: %s" % global.cash)
	for upgrade in global.upgrade_level:
		var n = get_node(upgrade)
		for box_num in indicators:
			if box_num <= global.upgrade_level[upgrade]:
				n.get_node(indicators[box_num]).set_texture(on)
			else:
				n.get_node(indicators[box_num]).set_texture(off)


extends Node


# item dictionaries with information about item stats
const item_dict := {
	"VoidOfCthulu": {
		"icon": preload("res://Assets/Heart.png"),
	},
	"homing_sword": {
		"icon": preload("res://icon.png"),
	}
}


func _ready():
	randomize()
	Input.set_custom_mouse_cursor(preload("res://Assets/pixil-frame-0 (1).png"))


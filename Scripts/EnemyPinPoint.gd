extends Sprite

var color = Color(0.769531, 0.180359, 0.180359)

func _ready():
	modulate = color
	yield(get_tree(), "idle_frame")
	queue_free()

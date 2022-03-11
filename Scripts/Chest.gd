extends Area2D

func _ready():
	
	yield(get_tree().create_timer(8.0), "timeout")
	
	var player = get_parent().get_node("Player")
	position = player.position
	

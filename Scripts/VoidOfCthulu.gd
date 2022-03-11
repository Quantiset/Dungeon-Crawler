extends Area2D

var target
var o_radius = 20

var time = 0.0

func _physics_process(delta):
	
	time += delta
	
	position = Vector2(
		cos(time * 4),
		sin(time * 4)
	)* o_radius

func _on_VoidOfCthulu_body_entered(body):
	if body.is_in_group("Enemy"):
		body.take_damage(1)




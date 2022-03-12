extends Area2D

var velocity = Vector2()

var enemy

var speed = 3

var direction



func _ready():
	yield(get_tree(), "idle_frame")
	direction = get_local_mouse_position().normalized()


func _physics_process(delta):
	if direction == null:
		return
	
	velocity = direction * speed
	
	$Sprite.rotation = velocity.angle() + PI/2
	
	position += velocity
	


func _on_ThrowableSword_body_entered(body):
	if body.is_in_group("Enemy"):
		enemy = body
		body.take_damage(1)
		queue_free()
	if body.is_in_group("Map"):
		queue_free()
	if body.is_in_group("Moveable"):
		body.apply_central_impulse(to_local(body.global_position).normalized() * 50)
		queue_free()

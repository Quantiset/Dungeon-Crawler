extends RigidBody2D

var is_touching = false


func _input(event):
	if Input.is_action_just_pressed("ui_accept"):
		var item = preload("res://Scenes/ItemPickup.tscn").instance()
		get_parent().add_child(item)
		item.position = global_position
		queue_free()

func _ready():
	
	pass
	

func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		is_touching = true
		$EKey.show()

func _on_Area2D_body_exited(body):
	if body.is_in_group("Player"):
		is_touching = false
		$EKey.hide()

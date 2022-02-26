extends KinematicBody2D

var velocity = Vector2()
var acceleration = 20
var max_speed = 100
var health = 3
var body


func _ready():
	pass

func _physics_process(delta):
	
	if Input.is_action_pressed("ui_up"):
		$AnimationPlayer.play("PlayerMove")
		velocity.y += -acceleration
		if velocity.y < -max_speed:
			velocity.y = -max_speed
	if Input.is_action_pressed("ui_down"):
		$AnimationPlayer.play("PlayerMove")
		velocity.y += acceleration
		if velocity.y > max_speed:
			velocity.y =max_speed
	if Input.is_action_pressed("ui_right"):
		$Sprite.flip_h = true
		$AnimationPlayer.play("PlayerMove")
		velocity.x += acceleration
		if velocity.x > max_speed:
			velocity.x = max_speed
	if Input.is_action_pressed("ui_left"):
		$Sprite.flip_h = false
		$AnimationPlayer.play("PlayerMove")
		velocity.x += -acceleration
		if velocity.x < -max_speed:
			velocity.x = -max_speed
	if Input.is_action_just_pressed("ui_click"):
		var sword = preload("res://Scenes/ThrowableSword.tscn").instance()
		get_parent().add_child(sword)
		sword.position = position
	
	velocity /= 1.2
		
	velocity = move_and_slide(velocity)

func _process(delta):
	
	for enemy in get_tree().get_nodes_in_group("Enemy"):
		var pinpoint = preload("res://Scenes/EnemyPinPoint.tscn").instance()
		pinpoint.position = enemy.position
		get_node("../Viewport").add_child(pinpoint)
	
	
	get_node("../Viewport/Camera2D").position = get_node("../Player/Camera2D").global_position
	get_node("CanvasLayer/UI/Minimap").texture = get_node("../Viewport").get_texture()


func take_damage(x):
	health -= x
	if health == 0:
		queue_free()

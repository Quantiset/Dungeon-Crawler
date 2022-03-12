extends KinematicBody2D

var velocity = Vector2()
var body

export (int) var health = 3

export (float) var acceleration = 20
export (float) var max_speed = 100

export (bool) var show_minimap = false

var invulnerability = false

var item_list = []

func _ready():
	pass

func _physics_process(delta):
	
	$Particles2D.emitting = false
	$Particles2D2.emitting = false
	if Input.is_action_pressed("ui_up"):
		$Particles2D.emitting = true
		$Particles2D2.emitting = true
		$PlayerMoveAnimation.play("PlayerMove")
		velocity.y += -acceleration
		if velocity.y < -max_speed:
			velocity.y = -max_speed
	if Input.is_action_pressed("ui_down"):
		$Particles2D.emitting = true
		$Particles2D2.emitting = true
		$PlayerMoveAnimation.play("PlayerMove")
		velocity.y += acceleration
		if velocity.y > max_speed:
			velocity.y = max_speed
	if Input.is_action_pressed("ui_right"):
		$Particles2D.emitting = true
		$Particles2D2.emitting = true
		$Sprite.flip_h = true
		$PlayerMoveAnimation.play("PlayerMove")
		velocity.x += acceleration
		if velocity.x > max_speed:
			velocity.x = max_speed
	if Input.is_action_pressed("ui_left"):
		$Particles2D.emitting = true
		$Particles2D2.emitting = true
		$Sprite.flip_h = false
		$PlayerMoveAnimation.play("PlayerMove")
		velocity.x += -acceleration
		if velocity.x < -max_speed:
			velocity.x = -max_speed
	if Input.is_action_pressed("ui_shoot"):
		if not $CanvasLayer/UI/Shot/PlayReload.is_playing():
			var sword = preload("res://Scenes/ThrowableSword.tscn").instance()
			get_parent().add_child(sword)
			sword.position = position
			$CanvasLayer/UI/Shot/PlayReload.play("SwordReset")
	
	velocity /= 1.2
	
	velocity = move_and_slide(velocity, Vector2(), false, 4, PI/3, false)
	for i in range(get_slide_count()):
		var collision_info: KinematicCollision2D = get_slide_collision(i)
		var collider = collision_info.collider
		if collider.is_in_group("Moveable"):
			collider.apply_central_impulse(to_local(collider.global_position).normalized() * 10)
	
	minimap()


func minimap():
	
	if not show_minimap: return
	
	get_node("../Viewport/Camera2D").position = get_node("../Player/Camera2D").global_position
	get_node("CanvasLayer/UI/Minimap").texture = get_node("../Viewport").get_texture()


func take_damage(x):
	if invulnerability == true:
		return
	
	health -= x
	$CanvasLayer/UI/Tween.interpolate_property(
		$CanvasLayer/UI/Healthbar, 
		"rect_size",
		$CanvasLayer/UI/Healthbar.rect_size,
		$CanvasLayer/UI/Healthbar.rect_size - Vector2(11, 0),
		0.5,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN
	)
	$CanvasLayer/UI/Tween.start()
	$PlayerHurtAnimation.play("PlayerHurt")
	$Timer.start()
	invulnerability = true
	if health == 0:
		queue_free()

func _on_Timer_timeout():
	invulnerability = false

func pickup_item(item_picked):
	
	match (item_picked):
		"VoidOfCthulu":
			var VoidOfCthulu = preload("res://Scenes/Items/VoidOfCthulu.tscn").instance()
			VoidOfCthulu.target = self
			add_child(VoidOfCthulu)
		"homing_sword":
			pass
	
	item_list.append(item_picked)

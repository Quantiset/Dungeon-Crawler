extends KinematicBody2D

var velocity = Vector2()
var player
var player_collide

export (float) var speed = 45

func _ready():
	pass 

func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		player = body

func _on_Area2D_body_exited(body):
	if body.is_in_group("Player"):
		player = null
		
func _physics_process(delta):
	
	if player_collide != null:
		player_collide.take_damage(1)
	
	if player != null:
		var to_player: Vector2 = player.position - position
		velocity = to_player.normalized() * speed
		$AnimationPlayer.play("PlayerMove")
		
		velocity = move_and_slide(velocity)
	
func _on_player_hit_body_entered(body):
	if body.is_in_group("Player"):
		player_collide = body

func _on_player_hit_body_exited(body):
	if body.is_in_group("Player"):
		player_collide = null

extends KinematicBody2D

var velocity = Vector2()
var player
var player_collide
export (int) var health = 3

export (float) var speed = 45

func _ready():
	# TODO: set physics process internet false initially 
	set_physics_process(false)
	set_physics_process_internal(false) 

# Detection radius
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
		$EnemyMove.play("PlayerMove")
		
		velocity = move_and_slide(velocity)


# collision radius
func _on_player_hit_body_entered(body):
	if body.is_in_group("Player"):
		player_collide = body

func _on_player_hit_body_exited(body):
	if body.is_in_group("Player"):
		player_collide = null
	
func take_damage(dmg):
	health -= dmg
	$EnemyHurt.play("EnemyHurt")
	if health == 0:
		queue_free()


func _on_VisibilityNotifier2D_screen_entered():
	set_physics_process(true)
	set_physics_process_internal(true) # Replace with function body.

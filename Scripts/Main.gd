extends Node2D

const BLOCK_SIZE = 16

const ADJACENCIES = [Vector2.LEFT, Vector2.RIGHT, Vector2.DOWN, Vector2.UP]
const ROOM = preload("res://Scenes/RoomRigid.tscn")

const TIME_TO_DISPERSE = 2.0
const VSPREAD = 400 # how far in y it spreads
const HSPREAD = 620 # how far in x it spreads
const BODIES = 40 # total rooms to pass to physics
const MIN_SIZE = 70 # min room size
const MAX_SIZE = 100 # max room size
const X_MULTIPLICITY = 1 # controls how wide rooms are (larger = wider)
const CULL_RATE = 0.92 # chance to free room once disperse time is over
const CORRIDOR_SIZE = 4 

var path_astar: AStar2D

var leftmostroom = null
var rightmostroom = null

# amount of enemies per room and their % chance. Values should equal one.
# For instance, having a room that has 2 enemies has a 0.2 or 20% chance of happening
var chance_for_enemies_per_room := {
	0: 0.4,
	1: 0.3,
	2: 0.2,
	3: 0.1,
}

var enemy_pool := {
	preload("res://Scenes/Enemy.tscn"): 10,
	preload("res://Scenes/Enemy2.tscn"): 10,
}

func _ready():
	
	randomize()
	
	$CanvasLayer/LoadingScreen.show()
	
	for i in range(BODIES):
		var pos := Vector2(randi()%(HSPREAD*2)-HSPREAD, randi()%(VSPREAD*2)-VSPREAD)
		var room = set_room(
			pos,
			Vector2(
				MIN_SIZE + randi() % (MAX_SIZE - MIN_SIZE),
				MIN_SIZE + randi() % (MAX_SIZE - MIN_SIZE)
			)
		)
		if leftmostroom == null or pos.x < leftmostroom.position.x:
			leftmostroom = room
		if rightmostroom == null or pos.x > rightmostroom.position.x:
			rightmostroom = room
	
	yield(get_tree().create_timer(TIME_TO_DISPERSE), "timeout")
	
	var room_positions = []
	for room in $Rooms.get_children():
		if not room in [leftmostroom, rightmostroom] and randf() < CULL_RATE:
			room.queue_free()
		else:
			room.mode = RigidBody2D.MODE_STATIC
			room_positions.append(room.position)
	
	# find path and assign it to the astar
	find_mst(room_positions)
	
	yield(get_tree(), "idle_frame")
	
	var corridors = []  # One corridor per connection
	for room in $Rooms.get_children():
		var s: Vector2 = (room.get_node("CollisionShape2D").shape.extents*2 / BLOCK_SIZE).floor()
		var pos = $Foreground.world_to_map(room.position)
		var ul = (room.position / BLOCK_SIZE).floor() - s
		
		# i in range(3) then it
		
		# paints room
		for x in range(2, s.x * 2 - 1):
			for y in range(2, s.y * 2 - 1):
				set_cell(ul.x+x, ul.y+y, 0)
		
		# carves path corridor
		var p = path_astar.get_closest_point(room.position)
		for conn in path_astar.get_point_connections(p):
			if not conn in corridors:
				var start = $Foreground.world_to_map(Vector2(path_astar.get_point_position(p).x, path_astar.get_point_position(p).y))
				var end = $Foreground.world_to_map(Vector2(path_astar.get_point_position(conn).x, path_astar.get_point_position(conn).y))
				carve_path(start, end)
		
		# spawns enemies in the rooms
		if room != leftmostroom:
			
			var random_enemy_f := randf()
			var enemies := 0
			for enemy_count in chance_for_enemies_per_room:
				random_enemy_f -= enemy_count
				if random_enemy_f <= 0:
					enemies = enemy_count
			for i in range(enemies):
				var enemy = get_random_enemy()
				enemy.position = room.position + Vector2(randf()-0.5, randf()-0.5) * (20+randi()%40)
				add_child(enemy)
		
		corridors.append(p)
	
	$Player.position = leftmostroom.position 
	
	for room in $Rooms.get_children():
		room.queue_free()
	
	$Foreground.update_bitmask_region()
	$Foreground.force_update()
	
	$CanvasLayer/LoadingScreen.hide()
	


# find path and update the astar to a valid class
func find_mst(nodes: Array):
	
	# Initialize the AStar and add the first point
	var path = AStar2D.new()
	path.add_point(path.get_available_point_id(), nodes.pop_front())

	# Repeat until no more nodes remain
	while nodes:
		var min_dist: float = INF  # Minimum distance found so far
		var min_p = null  # Position of that node
		var p = null  # Current position
		# Loop through the points in the path
		for p1 in path.get_points():
			p1 = path.get_point_position(p1)
			# Loop through the remaining nodes in the given array
			for p2 in nodes:
				# If the node is closer, make it the closest
				if p1.distance_to(p2) < min_dist:
					min_dist = p1.distance_to(p2)
					min_p = p2
					p = p1
		# Insert the resulting node into the path and add
		# its connection
		var n = path.get_available_point_id()
		path.add_point(n, min_p)
		path.connect_points(path.get_closest_point(p), n)
		# Remove the node from the array so it isn't visited again
		nodes.erase(min_p)
	path_astar = path

func carve_path(pos1, pos2):
	# Carves a path between two points
	var x_diff = sign(pos2.x - pos1.x)
	var y_diff = sign(pos2.y - pos1.y)
	if x_diff == 0: x_diff = pow(-1.0, randi() % 2)
	if y_diff == 0: y_diff = pow(-1.0, randi() % 2)
	# Carve either x/y or y/x
	var x_y = pos1
	var y_x = pos2
	if (randi() % 2) > 0:
		x_y = pos2
		y_x = pos1
	
	for x in range(pos1.x, pos2.x, x_diff):
		for x_add in range(CORRIDOR_SIZE):
			x_add -= CORRIDOR_SIZE/2
			for y_add in range(CORRIDOR_SIZE):
				y_add -= CORRIDOR_SIZE/2
				set_cell(x+x_add, x_y.y+y_add, 0)
				set_cell(x+x_add, x_y.y+y_diff+y_add, 0)  # widen the corridor
	for y in range(pos1.y, pos2.y, y_diff):
		for x_add in range(CORRIDOR_SIZE):
			x_add -= CORRIDOR_SIZE/2
			for y_add in range(CORRIDOR_SIZE):
				y_add -= CORRIDOR_SIZE/2
				set_cell(y_x.x+x_add, y+y_add, 0)
				set_cell(y_x.x+x_diff+x_add, y+y_add, 0)  # widen the corridor
	


func set_room(pos: Vector2, size: Vector2) -> RigidBody2D:
	var r = ROOM.instance()
	r.position = pos
	r.get_node("CollisionShape2D").shape = RectangleShape2D.new()
	r.get_node("CollisionShape2D").shape.extents = size
	$Rooms.add_child(r)
	return r

func set_cell(x: int, y: int, tile: int):
	$Foreground.set_cell(x, y, tile)
	$Viewport/TileMap.set_cell(x, y, 0)

# returns random enemy based on pool from enemy_pool
func get_random_enemy():
	var sum := 0
	for enemy in enemy_pool:
		sum += enemy_pool[enemy]
	
	var chosen_weight := randi()%sum
	for enemy in enemy_pool:
		chosen_weight -= enemy_pool[enemy]
		if chosen_weight <= 0:
			return enemy.instance()
	
	printerr("Enemy weights not configured correctly")
	return preload("res://Scenes/Enemy.tscn").instance()



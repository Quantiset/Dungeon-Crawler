extends Node2D

const BLOCK_SIZE = 16

const ADJACENCIES = [Vector2.LEFT, Vector2.RIGHT, Vector2.DOWN, Vector2.UP]

var leftmostroom = null
var rightmostroom = null

const map_size := Vector2(10, 10)
const room_size := Vector2(20, 12)

var rooms := {}

class WRoom:
	var location: Vector2
	
	func get_global_position(center := false):
		return (location + (Vector2(0.5, 0.5) if center else Vector2())) * room_size * BLOCK_SIZE
	
	func _init(_loc: Vector2):
		location = _loc
	

func _ready():
	generate_rooms()
	tile_rooms()
	spawn_enemies()
	
	$Foreground.update_bitmask_region()
	$Foreground.force_update()
	
	$Player.position = Vector2(100, 100)
	


func generate_rooms():
	for x in map_size.x:
		for y in map_size.y:
			rooms[Vector2(x, y)] = WRoom.new(Vector2(x, y))

func tile_rooms():
	for location in rooms:
		
		var room: WRoom = rooms[location]
		
		# map_x and map_y are for room coords
		var map_x: int = location.x
		var map_y: int = location.y
		
		for x in range(room_size.x):
			for y in range(room_size.y):
				
				# tile coords of current tile
				var vec := Vector2(
					map_x * (room_size.x+1) + x,
					map_y * (room_size.y+1) + y
				)
				
				# pathways between rooms
				if x == room_size.x / 2:
					if y == 0:
						for i in range(3): 
							$Foreground.set_cellv(vec+Vector2(i-1, -1), 0)
					if y == room_size.y - 1: 
						for i in range(3): 
							$Foreground.set_cellv(vec+Vector2(i-1, 1), 0)
				if y == room_size.y / 2:
					if x == 0:
						for i in range(3):
							$Foreground.set_cellv(vec+Vector2(-1, i-1), 0)
					if x == room_size.x -1:
						for i in range(3):
							$Foreground.set_cellv(vec+Vector2(1, i-1), 0)
				
				# set current tile to an empty square
				$Foreground.set_cellv(vec, 0)

func spawn_enemies():
	for room_loc in rooms:
		var room: WRoom = rooms[room_loc]
		
		if randi() % 1 == 0:
			var enemy = preload("res://Scenes/Enemy.tscn").instance()
			enemy.position = room.get_global_position(true)
			add_child(enemy)
		
		
		
		

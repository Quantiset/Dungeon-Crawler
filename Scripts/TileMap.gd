extends TileMap
tool

var tiles: Array


func _on_TileMap_settings_changed():
	print("settings changed")

func _physics_process(delta: float):
	
	if Engine.is_editor_hint():
		
		var temp_tiles: Array = get_used_cells()
		
		if tiles != temp_tiles:
			force_update()
		
		tiles = temp_tiles

func force_update():
	var temp_tiles: Array = get_used_cells()
	get_node("../SingleTiles").clear()
	get_node("../Ground").clear()
	for tile in temp_tiles:
		update_tile(tile)
	get_node("../Ground").update_bitmask_region()

func update_tile(tile: Vector2):
	var tile_pos: Vector2 = \
			get_cell_autotile_coord(tile.x, tile.y)
	
	match tile_pos:
		Vector2(1,1):
			get_node("../SingleTiles").set_cellv(tile+Vector2.DOWN, 3)
			continue
		Vector2(1,1), Vector2(1, 3):
			get_node("../SingleTiles").set_cellv(tile+Vector2.UP, 0)
		Vector2(3,1):
			get_node("../SingleTiles").set_cellv(tile+Vector2.UP, 1)
		Vector2(4,1):
			get_node("../SingleTiles").set_cellv(tile+Vector2.UP, 2)
		Vector2(5,0):
			get_node("../Ground").set_cellv(tile, 0)
	



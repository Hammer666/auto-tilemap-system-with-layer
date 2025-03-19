extends TileMapLayer
class_name LayerNode

signal block_exited(coords: Vector2i)

@onready var terrain_tiles = demo.terrain_system.get_terrain_tiles()

var exit_flag = false
var start_block_coords : Vector2i
var block_size : Vector2i
var task_id : int
var demo : Demo
var terrain_cache := {}

func _ready() -> void:
	task_id = WorkerThreadPool.add_task(thread_generator,true)

func _process(delta: float) -> void:
	if exit_flag and WorkerThreadPool.is_task_completed(task_id) :
		block_exited.emit(start_block_coords)
		queue_free()

func thread_generator():
	var tiles_to_render := []
	block_size = demo.block_size
	var start_coords := start_block_coords * Vector2i(block_size)
	var end_coords := start_coords + Vector2i(block_size)
	for x in range(start_coords.x, end_coords.x):
		for y in range(start_coords.y, end_coords.y):
			tiles_to_render.append(Vector2(x, y))
	call_deferred("set_cells", tiles_to_render)

func exit_block():
	exit_flag = true

func set_cells(cells:Array):
	var cell_count = cells.size()
	for index in range(cell_count):
		var cell = cells[index]
		var tile_id = get_tile_id(cell)
		if terrain_tiles[0].has(tile_id):
			var tile : TerrainTile = terrain_tiles[0][tile_id]
			set_cell(cell, 0, tile.atlas_coords)

func get_tile_id(coords: Vector2) -> int:
	if terrain_cache.has(coords):
		return terrain_cache[coords]
	if return_tile_terrain(demo.main_noise.get_noise_2dv(coords)) == 0: 
		return 0
	
	var id := 0
	
	var right := get_terrain(coords + Vector2.RIGHT)
	var down := get_terrain(coords + Vector2.DOWN)
	var left := get_terrain(coords + Vector2.LEFT)
	var up := get_terrain(coords + Vector2.UP)
	
	id |= (right << 7)
	id |= (down << 5)
	id |= (left << 3)
	id |= (up << 1)
	
	if right and down:
		id |= (get_terrain(coords + Vector2(1, 1)) << 6)
	if left and down:
		id |= (get_terrain(coords + Vector2(-1, 1)) << 4)
	if left and up:
		id |= (get_terrain(coords + Vector2(-1, -1)) << 2)
	if right and up:
		id |= get_terrain(coords + Vector2(1, -1))
	terrain_cache[coords] = id
	return id

func get_terrain(offset: Vector2) -> int:
	if terrain_cache.has(offset) and terrain_cache[offset] != 0:
		return 1
	return return_tile_terrain(demo.main_noise.get_noise_2dv(offset))

func return_tile_terrain(noise_value: float) -> int:
	return 0 if noise_value < -0.2 else 1

extends RefCounted
class_name SimpleTerrainSystem

var terrain_tiles := {}

func _init(tileset: TileSet) -> void:
	for sc : int in tileset.get_source_count():
		var source_id = tileset.get_source_id(sc)
		var source = tileset.get_source(source_id)
		
		if (source is TileSetAtlasSource):
			handle_source(source, source_id)

func handle_source(source: TileSetAtlasSource, source_id: int):
	for tc : int in source.get_tiles_count():
		var tile_id : Vector2i = source.get_tile_id(tc)
		for index : int in source.get_alternative_tiles_count(tile_id):
			var alternative_tile : int = source.get_alternative_tile_id(tile_id, index)
			var tile_data : TileData = source.get_tile_data(tile_id, alternative_tile)
			
			if tile_data.terrain_set > 0:
				push_warning("地形集%s将被忽略，仅支持一个地形集", tile_data.terrain_set)
				continue
			if tile_data.terrain < 0:
				continue
			
			var terrain_tile = TerrainTile.new()
			terrain_tile.source_id = source_id
			terrain_tile.atlas_coords = tile_id
			terrain_tile.alternative_tile = alternative_tile
			terrain_tile.terrain = tile_data.terrain
			
			terrain_tile.right = tile_data.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_RIGHT_SIDE) == tile_data.terrain
			terrain_tile.right_down = tile_data.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER) == terrain_tile.terrain
			terrain_tile.down = tile_data.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_BOTTOM_SIDE) == terrain_tile.terrain
			terrain_tile.left_down = tile_data.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER) == terrain_tile.terrain
			terrain_tile.left = tile_data.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_LEFT_SIDE) == terrain_tile.terrain
			terrain_tile.left_up = tile_data.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER) == terrain_tile.terrain
			terrain_tile.up = tile_data.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_TOP_SIDE) == terrain_tile.terrain
			terrain_tile.right_up = tile_data.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER) == terrain_tile.terrain
			
			add_terrain_tile(terrain_tile)

func add_terrain_tile(tile: TerrainTile):
	var tiles : Dictionary = terrain_tiles[tile.terrain] if terrain_tiles.has(tile.terrain) else {}
	var id = set_terrain_tile_id(tile)
	tiles[id] = tile
	terrain_tiles[tile.terrain] = tiles

func set_terrain_tile_id(tile: TerrainTile) -> int:
	var id := (0 | int(tile.right)) << 1
	id = (id | int(tile.right_down)) << 1
	id = (id | int(tile.down)) << 1
	id = (id | int(tile.left_down)) << 1
	id = (id | int(tile.left)) << 1
	id = (id | int(tile.left_up)) << 1
	id = (id | int(tile.up)) << 1
	id = (id | int(tile.right_up))
	return id

func get_terrain_tiles() -> Dictionary:
	return terrain_tiles.duplicate()

extends Node2D
class_name Demo

@export var main_noise: FastNoiseLite
@export var layer_node: PackedScene
@export var block_size: Vector2 = Vector2(32, 32)
@export var render_radius: int = 1
@export var tileset : TileSet

@onready var map := $Map
@onready var player := $Player
@onready var fps_lab := $CanvasLayer/FPS
@onready var terrain_system: SimpleTerrainSystem = SimpleTerrainSystem.new(tileset)

var render_blocks = {}
var render_block = []
var blocks_to_add = []
var blocks_to_remove = []
var pre_block: Vector2i

func _ready() -> void:
	
	pre_block = tile_to_block(global_to_tile(player.position))
	generate_blocks()

func _process(delta: float) -> void:
	var block_coords := tile_to_block(global_to_tile(player.position))
	fps_lab.text = "FPS: " + str(Engine.get_frames_per_second())
	if pre_block != block_coords:
		pre_block = block_coords
		generate_blocks()
	
	if blocks_to_add.size() > 0:
		add_layer_node(blocks_to_add.pop_front())
	if blocks_to_remove.size() > 0:
		remove_layer_node(blocks_to_remove.pop_front())

# 将需要渲染的区块放入blocks中，处理player对象移动时需要渲染的对应区块
func generate_blocks():
	# 以player对象所在区域为基准，向周围拓展需要渲染的区域
	var current_block := Vector2i(pre_block)
	var blocks_start_coords := current_block - Vector2i(render_radius, render_radius)
	var blocks_end_coords := current_block + Vector2i(render_radius + 1, render_radius + 1)
	
	# 当前需要渲染的区块
	var current_blocks: Array[Vector2i] = []
	for x in range(blocks_start_coords.x, blocks_end_coords.x):
		for y in range(blocks_start_coords.y, blocks_end_coords.y):
			current_blocks.append(Vector2i(x, y))
	
	for coords in current_blocks:
		if not render_blocks.has(coords):
			blocks_to_add.append(coords)
	
	# 需要移除的区块
	blocks_to_remove.clear()
	for coords : Vector2i in render_blocks:
		if not current_blocks.has(coords):
			blocks_to_remove.append(coords)

func add_layer_node(coords: Vector2i):
	var node : LayerNode = layer_node.instantiate()
	node.start_block_coords = coords
	node.demo = self
	map.add_child(node)
	render_blocks[coords] = node

func remove_layer_node(coords:Vector2i):
	var block : LayerNode = render_blocks[coords]
	block.exit_block()
	render_blocks.erase(coords)
	block.connect("block_exited", _on_block_exit)

func _on_block_exit(coords:Vector2i):
	render_blocks.erase(coords)

func tile_to_block(tile:Vector2) -> Vector2i:
	return (tile / block_size).floor()

func global_to_tile(global: Vector2) -> Vector2:
	return (global / get_tile_size()).floor()

func get_tile_size() -> Vector2:
	return tileset.tile_size

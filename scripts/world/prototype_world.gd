# prototype_world.gd
# Prototype world with generated tilemap
extends Node2D

@onready var tilemap_layer: TileMapLayer = $TileMapLayer

func _ready() -> void:
	_setup_tilemap()
	_generate_map()
	_spawn_decorations()
	print("Prototype World loaded")
	print("Controls: WASD=Move | Space=Attack | Q=Chrono Rift")

func _setup_tilemap() -> void:
	# Create and assign tileset
	var tileset = preload("res://scripts/world/tileset_generator.gd").create_tileset()
	tilemap_layer.tile_set = tileset
	
	print("Tileset created with 4 tile types")

func _generate_map() -> void:
	# Generate a 30x30 map with more variety
	var map_size = 30
	
	for y in range(map_size):
		for x in range(map_size):
			var tile_id = _get_tile_for_position(x, y, map_size)
			tilemap_layer.set_cell(Vector2i(x, y), tile_id, Vector2i(0, 0))

func _get_tile_for_position(x: int, y: int, map_size: int) -> int:
	# Stone border
	if x == 0 or x == map_size - 1 or y == 0 or y == map_size - 1:
		return 2  # Stone
	
	# Water ponds in corners
	if (x < 3 and y < 3) or (x > map_size - 4 and y > map_size - 4):
		return 3  # Water
	
	# Dirt paths (diagonal)
	if abs(x - y) < 2:
		return 1  # Dirt
	
	# Random dirt patches
	if (x + y * 7) % 11 == 0:
		return 1  # Dirt
	
	# Default: Grass
	return 0

func _spawn_decorations() -> void:
	# Spawn more trees and rocks for better Y-Sort testing
	var decorations = [
		{"type": "tree", "pos": Vector2(200, 150)},
		{"type": "tree", "pos": Vector2(400, 200)},
		{"type": "tree", "pos": Vector2(300, 350)},
		{"type": "tree", "pos": Vector2(600, 300)},
		{"type": "tree", "pos": Vector2(250, 450)},
		{"type": "rock", "pos": Vector2(500, 250)},
		{"type": "rock", "pos": Vector2(250, 400)},
		{"type": "rock", "pos": Vector2(450, 450)},
		{"type": "bush", "pos": Vector2(350, 250)},
		{"type": "bush", "pos": Vector2(550, 400)},
	]
	
	for deco in decorations:
		match deco.type:
			"tree":
				_spawn_tree(deco.pos)
			"rock":
				_spawn_rock(deco.pos)
			"bush":
				_spawn_bush(deco.pos)

func _spawn_tree(pos: Vector2) -> void:
	var tree = ColorRect.new()
	tree.size = Vector2(20, 60)
	tree.color = Color(0.2, 0.5, 0.2)
	tree.position = pos - Vector2(10, 60)  # Offset for bottom-center
	$YSortRoot.add_child(tree)

func _spawn_rock(pos: Vector2) -> void:
	var rock = ColorRect.new()
	rock.size = Vector2(30, 20)
	rock.color = Color(0.5, 0.5, 0.5)
	rock.position = pos - Vector2(15, 10)  # Offset for center
	$YSortRoot.add_child(rock)

func _spawn_bush(pos: Vector2) -> void:
	var bush = ColorRect.new()
	bush.size = Vector2(25, 15)
	bush.color = Color(0.3, 0.6, 0.3)
	bush.position = pos - Vector2(12, 7)  # Offset for center
	$YSortRoot.add_child(bush)

extends Node2D

const GENERATED_LAYER_NAME := "GeneratedChunk"
const PREVIEW_LAYER_NAME := "PreviewProps"
const PREVIEW_BASE_TILES := {
	"tree": "grass",
	"bush": "grass",
	"decor_bush": "grass",
	"gold_stone": "rock",
	"rock": "rock",
	"boulder": "rock",
	"decor_rock": "rock",
	"water_rock": "water",
	"cloud": "grass"
}

@export var chunk_x: int = 0
@export var chunk_y: int = 0
@export var chunk_size: int = 16
@export var tile_size: int = 32
@export var mapping_path: String = "res://data/tileset_mappings/tiny_swords_map.json"
@export var preview_objects: Array[String] = ["tree", "bush", "decor_bush", "gold_stone", "rock", "boulder", "decor_rock", "water_rock", "cloud"]
@export var preview_spacing_tiles: int = 5

func _ready() -> void:
	var map_gen_script: Variant = load("res://scripts/world/MapGenerator.gd")
	if map_gen_script == null:
		push_error("Failed to load MapGenerator script.")
		return

	var generator = map_gen_script.new()
	generator.seed = 0
	generator.chunk_size = chunk_size
	if generator.has_method("_init_noise"):
		generator._init_noise()
	if generator.has_method("_load_biomes"):
		generator._load_biomes()

	var mapping: Dictionary = _load_mapping()
	var tile_mappings: Dictionary = mapping.get("mappings", {})
	var object_mappings: Dictionary = mapping.get("objects", {})

	var generated_layer: Node2D = _ensure_layer(GENERATED_LAYER_NAME)
	var preview_layer: Node2D = _ensure_layer(PREVIEW_LAYER_NAME)
	_clear_layer(generated_layer)
	_clear_layer(preview_layer)

	var chunk_origin := Vector2(tile_size, tile_size)
	var chunk_extent := Vector2(chunk_size * tile_size, chunk_size * tile_size)
	var generated_chunk := generator.build_chunk_node(chunk_x, chunk_y, mapping_path, tile_size, chunk_origin)
	generated_layer.add_child(generated_chunk)

	var preview_origin := Vector2(tile_size, chunk_origin.y + chunk_extent.y + tile_size * 2)
	_render_preview(preview_layer, tile_mappings, object_mappings, chunk_origin, chunk_extent, preview_origin)
	_position_camera(chunk_origin, chunk_extent, preview_origin)

func _load_mapping() -> Dictionary:
	if not FileAccess.file_exists(mapping_path):
		push_error("Mapping file not found: %s" % mapping_path)
		return {}
	var raw_text := FileAccess.get_file_as_string(mapping_path)
	var parsed: Variant = JSON.parse_string(raw_text)
	if parsed is Dictionary:
		return parsed
	push_error("Failed to parse mapping JSON: %s" % mapping_path)
	return {}

func _ensure_layer(layer_name: String) -> Node2D:
	var existing := get_node_or_null(layer_name)
	if existing is Node2D:
		return existing
	var layer := Node2D.new()
	layer.name = layer_name
	add_child(layer)
	return layer

func _clear_layer(layer: Node2D) -> void:
	for child in layer.get_children():
		child.queue_free()

func _render_preview(layer: Node2D, tile_mappings: Dictionary, object_mappings: Dictionary, chunk_origin: Vector2, chunk_extent: Vector2, preview_origin: Vector2) -> void:
	if preview_objects.is_empty():
		return
	var slot_width: float = float(tile_size * preview_spacing_tiles)
	var preview_width: float = float((preview_objects.size() - 1) * slot_width)
	var start_x: float = chunk_origin.x + max(0.0, (chunk_extent.x - preview_width) * 0.5)
	for index in range(preview_objects.size()):
		var object_name: String = preview_objects[index]
		var tile_name: String = str(PREVIEW_BASE_TILES.get(object_name, "grass"))
		var tile_position := Vector2(start_x + index * slot_width, preview_origin.y)
		_render_tile(layer, tile_mappings, tile_name, tile_position)
		_instantiate_object(layer, object_mappings, object_name, tile_position)

func _render_tile(layer: Node2D, tile_mappings: Dictionary, tile_name: String, tile_position: Vector2) -> void:
	var info: Dictionary = _resolve_tile_mapping(tile_mappings, tile_name)
	var sheet_path: String = str(info.get("sheet", ""))
	if sheet_path == "":
		return
	var texture: Variant = load(sheet_path)
	if not (texture is Texture2D):
		return

	var region: Array = info.get("region", [0, 0])
	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = Rect2(float(region[0]) * tile_size, float(region[1]) * tile_size, tile_size, tile_size)

	var sprite := Sprite2D.new()
	sprite.centered = false
	sprite.texture = atlas
	sprite.position = tile_position
	layer.add_child(sprite)

func _resolve_tile_mapping(tile_mappings: Dictionary, tile_name: String) -> Dictionary:
	var info_variant: Variant = tile_mappings.get(tile_name, null)
	if info_variant is Dictionary:
		return info_variant
	var values: Array = tile_mappings.values()
	if values.is_empty():
		return {}
	var first_variant: Variant = values[0]
	if first_variant is Dictionary:
		return first_variant
	return {}

func _instantiate_object(layer: Node2D, object_mappings: Dictionary, object_name: String, tile_position: Vector2) -> void:
	var info_variant: Variant = object_mappings.get(object_name, null)
	if not (info_variant is Dictionary):
		return
	var info: Dictionary = info_variant
	var scene_path: String = str(info.get("scene", ""))
	if scene_path == "":
		return
	var scene_res: Variant = load(scene_path)
	if not (scene_res is PackedScene):
		return
	var instance: Node = scene_res.instantiate()
	if not (instance is Node2D):
		instance.queue_free()
		return
	var offset: Array = info.get("offset", [0.0, 0.0])
	var node_2d := instance as Node2D
	node_2d.position = tile_position + Vector2(float(offset[0]), float(offset[1]))
	layer.add_child(node_2d)

func _position_camera(chunk_origin: Vector2, chunk_extent: Vector2, preview_origin: Vector2) -> void:
	var camera := get_node_or_null("Camera2D") as Camera2D
	if camera == null:
		camera = Camera2D.new()
		camera.name = "Camera2D"
		camera.enabled = true
		add_child(camera)
	var preview_bottom: float = preview_origin.y + tile_size * 2
	camera.position = Vector2(
		chunk_origin.x + chunk_extent.x * 0.5,
		(chunk_origin.y + preview_bottom) * 0.5
	)

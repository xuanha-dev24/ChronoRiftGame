extends Node
class_name MapGenerator

@export var seed: int = 0
@export var chunk_size: int = 64
@export var frequency: float = 0.02
@export var octaves: int = 4
@export var persistence: float = 0.5
@export var lacunarity: float = 2.0
@export var noise_scale: float = 64.0

var noise = null
var biomes: Dictionary = {}

const DEFAULT_GENERATION_BIOMES := {
	"ocean": {
		"priority": 100,
		"height_max": 0.22,
		"tiles": ["water"],
		"tile_weights": [{"tile": "water", "weight": 1.0}],
		"object_spawn_chance": 0.03,
		"enemy_spawn_chance": 0.0,
		"objects": ["water_rock"],
		"object_weights": [{"object": "water_rock", "weight": 1.0}],
		"enemy_spawns": []
	},
	"beach": {
		"priority": 90,
		"height_min": 0.22,
		"height_max": 0.30,
		"tiles": ["sand", "water"],
		"tile_weights": [{"tile": "sand", "weight": 0.8}, {"tile": "water", "weight": 0.2}],
		"object_spawn_chance": 0.02,
		"enemy_spawn_chance": 0.0,
		"objects": ["water_rock", "bush"],
		"object_weights": [{"object": "water_rock", "weight": 0.75}, {"object": "bush", "weight": 0.25}],
		"enemy_spawns": []
	},
	"plains": {
		"priority": 50,
		"height_min": 0.30,
		"height_max": 0.58,
		"moisture_max": 0.58,
		"tiles": ["grass"],
		"tile_weights": [{"tile": "grass", "weight": 1.0}],
		"object_spawn_chance": 0.035,
		"enemy_spawn_chance": 0.02,
		"objects": ["tree", "bush", "decor_rock", "gold_stone"],
		"object_weights": [{"object": "tree", "weight": 0.46}, {"object": "bush", "weight": 0.18}, {"object": "decor_rock", "weight": 0.14}, {"object": "gold_stone", "weight": 0.08}],
		"enemy_spawns": [{"enemy_id": "slime_basic", "weight": 1.0}]
	},
	"forest": {
		"priority": 60,
		"height_min": 0.35,
		"height_max": 0.68,
		"moisture_min": 0.48,
		"tiles": ["grass"],
		"tile_weights": [{"tile": "grass", "weight": 1.0}],
		"object_spawn_chance": 0.10,
		"enemy_spawn_chance": 0.04,
		"objects": ["tree", "bush", "decor_rock", "gold_stone"],
		"object_weights": [{"object": "tree", "weight": 0.56}, {"object": "bush", "weight": 0.14}, {"object": "decor_rock", "weight": 0.08}, {"object": "gold_stone", "weight": 0.12}],
		"enemy_spawns": [{"enemy_id": "slime_basic", "weight": 1.0}]
	},
	"mountain": {
		"priority": 80,
		"height_min": 0.70,
		"tiles": ["rock", "grass"],
		"tile_weights": [{"tile": "rock", "weight": 0.82}, {"tile": "grass", "weight": 0.18}],
		"object_spawn_chance": 0.05,
		"enemy_spawn_chance": 0.03,
		"objects": ["boulder", "gold_stone", "decor_rock"],
		"object_weights": [{"object": "boulder", "weight": 0.42}, {"object": "gold_stone", "weight": 0.40}, {"object": "decor_rock", "weight": 0.18}],
		"enemy_spawns": [{"enemy_id": "earth_golem", "weight": 0.7}, {"enemy_id": "slime_basic", "weight": 0.3}]
	},
	"volcanic": {
		"priority": 70,
		"height_min": 0.58,
		"moisture_max": 0.38,
		"tiles": ["rock", "sand"],
		"tile_weights": [{"tile": "rock", "weight": 0.68}, {"tile": "sand", "weight": 0.32}],
		"object_spawn_chance": 0.03,
		"enemy_spawn_chance": 0.028,
		"objects": ["boulder", "gold_stone"],
		"object_weights": [{"object": "boulder", "weight": 0.45}, {"object": "gold_stone", "weight": 0.55}],
		"enemy_spawns": [{"enemy_id": "earth_golem", "weight": 0.55}, {"enemy_id": "slime_basic", "weight": 0.45}]
	}
}

func _init(_seed: int = 0) -> void:
	if _seed != 0:
		seed = _seed
	_init_noise()

func _ready() -> void:
	if noise == null:
		_init_noise()
	_load_biomes()

func _init_noise() -> void:
	# Use FastNoiseLite (Godot 4+). Keep initialization minimal — coordinate scaling
	# is handled in _sample_noise.
	noise = FastNoiseLite.new()
	noise.seed = int(seed)

func _load_biomes(path: String = "res://data/biomes.json") -> void:
	if FileAccess.file_exists(path):
		var text := FileAccess.get_file_as_string(path)
		var parsed: Variant = JSON.parse_string(text)
		if parsed is Dictionary:
			biomes = _merge_generation_defaults(parsed)
			return
	biomes = _merge_generation_defaults({})

func _merge_generation_defaults(loaded_biomes: Dictionary) -> Dictionary:
	var merged: Dictionary = DEFAULT_GENERATION_BIOMES.duplicate(true)
	for biome_name in loaded_biomes.keys():
		var biome_data = loaded_biomes[biome_name]
		if biome_data is Dictionary:
			var biome_dict: Dictionary = biome_data.duplicate(true)
			var defaults: Dictionary = DEFAULT_GENERATION_BIOMES.get(biome_name, {})
			for key in defaults.keys():
				if not biome_dict.has(key):
					biome_dict[key] = defaults[key]
			merged[biome_name] = biome_dict
	return merged

func _sample_noise(wx: float, wy: float) -> float:
	# Return normalized 0..1 noise value
	var v: float = float(noise.get_noise_2d(wx * frequency, wy * frequency))
	return (v + 1.0) * 0.5

func generate_chunk(chunk_x: int, chunk_y: int) -> Dictionary:
	var tiles: Array = []
	var objects: Array = []
	var enemies: Array = []
	var tile_rng := RandomNumberGenerator.new()
	tile_rng.seed = int(seed) ^ (chunk_x * 73856093) ^ (chunk_y * 19349663)
	var object_rng := RandomNumberGenerator.new()
	object_rng.seed = int(seed) ^ (chunk_x * 83492791) ^ (chunk_y * 2971215073)
	var enemy_rng := RandomNumberGenerator.new()
	enemy_rng.seed = int(seed) ^ (chunk_x * 1597334677) ^ (chunk_y * 3812015801)
	for y in range(chunk_size):
		for x in range(chunk_size):
			var wx := chunk_x * chunk_size + x
			var wy := chunk_y * chunk_size + y
			var h := _sample_noise(wx, wy)
			var m := _sample_noise(wx + 10000, wy + 10000)
			var biome := _determine_biome(h, m)
			var tile := _choose_tile_for_biome(biome, tile_rng)
			tiles.append({"x": wx, "y": wy, "tile": tile, "biome": biome})
			var spawn_chance := _object_spawn_chance(biome)
			if object_rng.randf() < spawn_chance:
				var otype := _choose_object_for_biome(biome, object_rng)
				objects.append({"x": wx, "y": wy, "type": otype})
			var enemy_spawn_chance := _enemy_spawn_chance(biome)
			if enemy_spawn_chance > 0.0 and enemy_rng.randf() < enemy_spawn_chance:
				var enemy_id := _choose_enemy_for_biome(biome, enemy_rng)
				if enemy_id != "":
					enemies.append({
						"x": wx,
						"y": wy,
						"enemy_id": enemy_id,
						"spawn_id": _make_enemy_spawn_id(enemy_id, wx, wy)
					})
	return {"tiles": tiles, "objects": objects, "enemies": enemies}

func _determine_biome(height: float, moisture: float) -> String:
	# Iterate biomes by priority and return first matching; fallback to "plains"
	for name in _get_biome_names_by_priority():
		var b: Dictionary = biomes[name]
		var min_h: float = float(b.get("height_min", -1.0))
		var max_h: float = float(b.get("height_max", 2.0))
		var min_m: float = float(b.get("moisture_min", -1.0))
		var max_m: float = float(b.get("moisture_max", 2.0))
		if height >= min_h and height <= max_h and moisture >= min_m and moisture <= max_m:
			return name
	return "plains"

func _choose_tile_for_biome(biome_name: String, rng: RandomNumberGenerator) -> String:
	var b_variant: Variant = biomes.get(biome_name, null)
	if not (b_variant is Dictionary):
		return "grass"
	var b: Dictionary = b_variant
	var weighted_tile := _choose_weighted_entry(b.get("tile_weights", []), "tile", rng)
	if weighted_tile != "":
		return weighted_tile
	var tiles: Array = b.get("tiles", [])
	if tiles.size() == 0:
		return "grass"
	return str(tiles[rng.randi() % tiles.size()])

func _object_spawn_chance(biome_name: String) -> float:
	var b: Dictionary = biomes.get(biome_name, {})
	return float(b.get("object_spawn_chance", 0.0))

func _choose_object_for_biome(biome_name: String, rng: RandomNumberGenerator) -> String:
	var b: Dictionary = biomes.get(biome_name, {})
	var weighted_object := _choose_weighted_entry(b.get("object_weights", []), "object", rng)
	if weighted_object != "":
		return weighted_object
	var objs: Array = b.get("objects", [])
	if objs.size() == 0:
		return ""
	return str(objs[rng.randi() % objs.size()])

func _enemy_spawn_chance(biome_name: String) -> float:
	var b: Dictionary = biomes.get(biome_name, {})
	return float(b.get("enemy_spawn_chance", 0.0))


func _choose_enemy_for_biome(biome_name: String, rng: RandomNumberGenerator) -> String:
	var b: Dictionary = biomes.get(biome_name, {})
	var enemy_spawns: Array = b.get("enemy_spawns", [])
	return _choose_weighted_entry(enemy_spawns, "enemy_id", rng)


func _make_enemy_spawn_id(enemy_id: String, world_x: int, world_y: int) -> String:
	return "%s:%d:%d" % [enemy_id, world_x, world_y]

func _get_biome_names_by_priority() -> Array:
	var biome_names: Array = biomes.keys()
	biome_names.sort_custom(func(a: String, b: String) -> bool:
		var a_priority: int = int((biomes.get(a, {}) as Dictionary).get("priority", 0))
		var b_priority: int = int((biomes.get(b, {}) as Dictionary).get("priority", 0))
		if a_priority == b_priority:
			return a < b
		return a_priority > b_priority
	)
	return biome_names


func _choose_weighted_entry(entries: Array, value_key: String, rng: RandomNumberGenerator) -> String:
	if entries.is_empty():
		return ""
	var total_weight: float = 0.0
	for entry_variant in entries:
		if entry_variant is Dictionary:
			total_weight += max(0.0, float(entry_variant.get("weight", 0.0)))
	if total_weight <= 0.0:
		return ""
	var pick := rng.randf() * total_weight
	var cumulative: float = 0.0
	for entry_variant in entries:
		if not (entry_variant is Dictionary):
			continue
		var entry: Dictionary = entry_variant
		cumulative += max(0.0, float(entry.get("weight", 0.0)))
		if pick <= cumulative:
			return str(entry.get(value_key, ""))
	return str((entries.back() as Dictionary).get(value_key, ""))

# Helper: load a mapping JSON file (tile/object mappings)
func _load_mapping_file(mapping_path: String) -> Dictionary:
	var mapping: Dictionary = {}
	if FileAccess.file_exists(mapping_path):
		var raw := FileAccess.get_file_as_string(mapping_path)
		var parsed: Variant = JSON.parse_string(raw)
		if parsed is Dictionary:
			mapping = parsed
	return mapping


# Build a reusable Node2D representing the generated chunk. The returned node
# contains two children: `Tiles` (Node2D) and `Objects` (Node2D) so callers
# can attach it directly into the scene tree.
func build_chunk_node(chunk_x: int, chunk_y: int, mapping_path: String = "res://data/tileset_mappings/tiny_swords_map.json", tile_size: int = 32, origin: Vector2 = Vector2.ZERO) -> Node2D:
	var data: Dictionary = generate_chunk(chunk_x, chunk_y)
	return build_chunk_node_from_data(data, chunk_x, chunk_y, mapping_path, tile_size, origin)


func build_chunk_node_from_data(data: Dictionary, chunk_x: int, chunk_y: int, mapping_path: String = "res://data/tileset_mappings/tiny_swords_map.json", tile_size: int = 32, origin: Vector2 = Vector2.ZERO) -> Node2D:
	var mapping: Dictionary = _load_mapping_file(mapping_path)
	var tile_mappings: Dictionary = mapping.get("mappings", {})
	var object_mappings: Dictionary = mapping.get("objects", {})

	var root := Node2D.new()
	root.name = "Chunk_%d_%d" % [chunk_x, chunk_y]

	var tiles_layer := Node2D.new()
	tiles_layer.name = "Tiles"
	root.add_child(tiles_layer)

	var objects_layer := Node2D.new()
	objects_layer.name = "Objects"
	root.add_child(objects_layer)

	for tile in data.get("tiles", []):
		var local_x: int = int(tile.get("x", 0)) - chunk_x * chunk_size
		var local_y: int = int(tile.get("y", 0)) - chunk_y * chunk_size
		var tile_name: String = str(tile.get("tile", "grass"))
		var tile_position := origin + Vector2(local_x * tile_size, local_y * tile_size)
		_add_tile_sprite(tiles_layer, tile_mappings, tile_name, tile_position, tile_size)

	for obj in data.get("objects", []):
		var local_x: int = int(obj.get("x", 0)) - chunk_x * chunk_size
		var local_y: int = int(obj.get("y", 0)) - chunk_y * chunk_size
		var object_name: String = str(obj.get("type", ""))
		var tile_position := origin + Vector2(local_x * tile_size, local_y * tile_size)
		_add_object_instance(objects_layer, object_mappings, object_name, tile_position)

	return root


# Internal helpers used by build_chunk_node
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


func _add_tile_sprite(parent: Node2D, tile_mappings: Dictionary, tile_name: String, tile_position: Vector2, tile_size: int) -> void:
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
	parent.add_child(sprite)


func _add_object_instance(parent: Node2D, object_mappings: Dictionary, object_name: String, tile_position: Vector2) -> void:
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
	parent.add_child(node_2d)

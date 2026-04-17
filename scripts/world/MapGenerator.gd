extends Node
class_name MapGenerator

@export var seed: int = 0
@export var chunk_size: int = 64
@export var frequency: float = 0.02
@export var octaves: int = 4
@export var persistence: float = 0.5
@export var lacunarity: float = 2.0
@export var noise_scale: float = 64.0

var noise: OpenSimplexNoise = OpenSimplexNoise.new()
var biomes: Dictionary = {}

func _init(_seed: int = 0) -> void:
    if _seed != 0:
        seed = _seed
    _init_noise()

func _ready() -> void:
    if noise == null:
        _init_noise()
    _load_biomes()

func _init_noise() -> void:
    noise = OpenSimplexNoise.new()
    noise.seed = int(seed)
    noise.octaves = octaves
    noise.period = noise_scale
    noise.persistence = persistence
    noise.lacunarity = lacunarity

func _load_biomes(path: String = "res://data/biomes.json") -> void:
    if FileAccess.file_exists(path):
        var text := FileAccess.get_file_as_string(path)
        var parsed = JSON.parse_string(text)
        if parsed.error == OK:
            biomes = parsed.result
            return
    # Fallback default biomes (minimal)
    biomes = {
        "ocean": {"height_max": 0.25, "tiles": ["water"], "object_spawn_chance": 0.0},
        "beach": {"height_min": 0.25, "height_max": 0.3, "tiles": ["sand"], "object_spawn_chance": 0.0},
        "plains": {"height_min": 0.3, "height_max": 0.6, "tiles": ["grass"], "object_spawn_chance": 0.01, "objects": ["bush", "flower"]},
        "forest": {"height_min": 0.4, "height_max": 0.7, "moisture_min": 0.4, "tiles": ["grass", "forest"], "object_spawn_chance": 0.06, "objects": ["tree"]},
        "mountain": {"height_min": 0.7, "tiles": ["rock"], "object_spawn_chance": 0.02, "objects": ["boulder"]}
    }

func _sample_noise(wx: float, wy: float) -> float:
    # Return normalized 0..1 noise value
    var v := noise.get_noise_2d(wx * frequency, wy * frequency)
    return (v + 1.0) * 0.5

func generate_chunk(chunk_x: int, chunk_y: int) -> Dictionary:
    var tiles: Array = []
    var objects: Array = []
    var rng := RandomNumberGenerator.new()
    rng.seed = int(seed) ^ (chunk_x * 73856093) ^ (chunk_y * 19349663)
    for y in range(chunk_size):
        for x in range(chunk_size):
            var wx := chunk_x * chunk_size + x
            var wy := chunk_y * chunk_size + y
            var h := _sample_noise(wx, wy)
            var m := _sample_noise(wx + 10000, wy + 10000)
            var biome := _determine_biome(h, m)
            var tile := _choose_tile_for_biome(biome)
            tiles.append({"x": wx, "y": wy, "tile": tile, "biome": biome})
            var spawn_chance := _object_spawn_chance(biome)
            if rng.randf() < spawn_chance:
                var otype := _choose_object_for_biome(biome, rng)
                objects.append({"x": wx, "y": wy, "type": otype})
    return {"tiles": tiles, "objects": objects}

func _determine_biome(height: float, moisture: float) -> String:
    # Iterate biomes and return first matching; fallback to "plains"
    for name in biomes.keys():
        var b := biomes[name]
        var min_h := b.get("height_min", -1.0)
        var max_h := b.get("height_max", 2.0)
        var min_m := b.get("moisture_min", -1.0)
        var max_m := b.get("moisture_max", 2.0)
        if height >= min_h and height <= max_h and moisture >= min_m and moisture <= max_m:
            return name
    return "plains"

func _choose_tile_for_biome(biome_name: String) -> String:
    var b := biomes.get(biome_name, null)
    if b == null:
        return "grass"
    var tiles := b.get("tiles", [])
    if tiles.size() == 0:
        return "grass"
    # Simple deterministic pick: currently returns first tile. Replace with weighted/random selection later.
    return tiles[0]

func _object_spawn_chance(biome_name: String) -> float:
    var b := biomes.get(biome_name, {})
    return float(b.get("object_spawn_chance", 0.0))

func _choose_object_for_biome(biome_name: String, rng: RandomNumberGenerator) -> String:
    var b := biomes.get(biome_name, {})
    var objs := b.get("objects", [])
    if objs.size() == 0:
        return ""
    return objs[rng.randi() % objs.size()]

# TODO: Provide helper methods to convert generator output into TileMap updates,
# chunk scene creation, and deterministic streaming. This file is a scaffold
# to start integrating the generator into `scripts/world` and `scenes/world`.
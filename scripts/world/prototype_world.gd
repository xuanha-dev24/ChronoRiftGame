# prototype_world.gd
# Runtime world scene with streamed chunks, persistence, and a day/night cycle.
extends Node2D

const MAP_GENERATOR_SCRIPT = preload("res://scripts/world/MapGenerator.gd")
const DEFAULT_MAPPING_PATH := "res://data/tileset_mappings/tiny_swords_map.json"
const QUICK_SAVE_ACTION := "quick_save"
const QUICK_LOAD_ACTION := "quick_load"
const ENEMY_SCENES := {
	"slime_basic": preload("res://scenes/enemies/SlimeBasic.tscn"),
	"earth_golem": preload("res://scenes/enemies/EarthGolem.tscn")
}

@export var world_seed: int = 1337
@export var chunk_size: int = 16
@export var tile_size: int = 32
@export var mapping_path: String = DEFAULT_MAPPING_PATH
@export var chunk_load_radius: int = 1
@export var chunk_keep_radius: int = 2
@export var persistence_enabled: bool = true
@export var start_player_in_chunk_center: bool = true

@onready var tilemap_layer: TileMapLayer = $TileMapLayer
@onready var generated_tiles_root: Node2D = $GeneratedTilesRoot
@onready var y_sort_root: Node2D = $YSortRoot
@onready var player: CharacterBody2D = $YSortRoot/Player
@onready var world_manager: WorldManager = $WorldManager
@onready var world_canvas_modulate: CanvasModulate = $WorldCanvasModulate

var map_generator: MapGenerator
var loaded_chunks: Dictionary = {}
var cached_chunks: Dictionary = {}
var pending_world_state: Dictionary = {}
var dirty_cache: bool = false
var last_center_chunk: Vector2i = Vector2i(2147483647, 2147483647)


func _ready() -> void:
	tilemap_layer.visible = false
	_setup_generator()
	_load_persisted_world_cache()
	_ensure_player_spawn_position()
	_connect_world_signals()
	GameManager.set_game_state(GameManager.GameState.PLAYING)
	GameManager.register_player(player)
	_apply_pending_world_state()
	_refresh_loaded_chunks(true)
	_update_current_biome()
	_apply_day_night(world_manager.time_of_day)
	print("Prototype World loaded")
	print("Controls: WASD=Move | Space=Attack | Q=Chrono Rift | K=Quick Save | L=Quick Load")


func _process(delta: float) -> void:
	world_manager.update_time_of_day(delta)
	_refresh_loaded_chunks()
	_update_current_biome()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(QUICK_SAVE_ACTION):
		_quick_save_world()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed(QUICK_LOAD_ACTION):
		_quick_load_world()
		get_viewport().set_input_as_handled()


func _exit_tree() -> void:
	_save_persisted_world_cache()


func _setup_generator() -> void:
	map_generator = MAP_GENERATOR_SCRIPT.new()
	map_generator.seed = world_seed
	map_generator.chunk_size = chunk_size
	map_generator._init_noise()
	map_generator._load_biomes()


func _connect_world_signals() -> void:
	if not EventBus.day_night_cycle_changed.is_connected(_on_day_night_cycle_changed):
		EventBus.day_night_cycle_changed.connect(_on_day_night_cycle_changed)
	if not EventBus.generated_enemy_killed.is_connected(_on_generated_enemy_killed):
		EventBus.generated_enemy_killed.connect(_on_generated_enemy_killed)


func _ensure_player_spawn_position() -> void:
	if not start_player_in_chunk_center:
		return
	if pending_world_state.has("player_position"):
		return
	if player.global_position.is_zero_approx():
		player.global_position = Vector2(chunk_size * tile_size * 0.5, chunk_size * tile_size * 0.5)


func _refresh_loaded_chunks(force: bool = false) -> void:
	var center_chunk := _world_to_chunk(player.global_position)
	if not force and center_chunk == last_center_chunk:
		return
	last_center_chunk = center_chunk

	for chunk_y in range(center_chunk.y - chunk_load_radius, center_chunk.y + chunk_load_radius + 1):
		for chunk_x in range(center_chunk.x - chunk_load_radius, center_chunk.x + chunk_load_radius + 1):
			_ensure_chunk_loaded(Vector2i(chunk_x, chunk_y))

	var loaded_keys: Array = loaded_chunks.keys()
	for key_variant in loaded_keys:
		var key: String = str(key_variant)
		var chunk_info: Dictionary = loaded_chunks.get(key, {})
		var coords_data: Dictionary = chunk_info.get("coords", {})
		var coords := Vector2i(int(coords_data.get("x", 0)), int(coords_data.get("y", 0)))
		if abs(coords.x - center_chunk.x) > chunk_keep_radius or abs(coords.y - center_chunk.y) > chunk_keep_radius:
			_unload_chunk(key)


func _ensure_chunk_loaded(chunk_coords: Vector2i) -> void:
	var key := _chunk_key(chunk_coords)
	if loaded_chunks.has(key):
		return

	var chunk_data := _get_or_create_chunk_data(chunk_coords)
	var chunk_node := map_generator.build_chunk_node_from_data(chunk_data, chunk_coords.x, chunk_coords.y, mapping_path, tile_size, Vector2.ZERO)
	var tiles_layer := chunk_node.get_node("Tiles") as Node2D
	var objects_layer := chunk_node.get_node("Objects") as Node2D
	var enemies_layer := _build_enemy_layer(chunk_data, chunk_coords)
	chunk_node.remove_child(tiles_layer)
	chunk_node.remove_child(objects_layer)
	chunk_node.queue_free()

	var chunk_origin := _chunk_world_origin(chunk_coords)
	tiles_layer.name = "Tiles_%s" % key.replace(",", "_")
	tiles_layer.position = chunk_origin
	generated_tiles_root.add_child(tiles_layer)

	objects_layer.name = "Objects_%s" % key.replace(",", "_")
	objects_layer.position = chunk_origin
	objects_layer.y_sort_enabled = true
	y_sort_root.add_child(objects_layer)

	enemies_layer.name = "Enemies_%s" % key.replace(",", "_")
	enemies_layer.position = chunk_origin
	enemies_layer.y_sort_enabled = true
	y_sort_root.add_child(enemies_layer)

	loaded_chunks[key] = {
		"coords": {"x": chunk_coords.x, "y": chunk_coords.y},
		"tiles": tiles_layer,
		"objects": objects_layer,
		"enemies": enemies_layer
	}


func _unload_chunk(key: String) -> void:
	var chunk_info: Dictionary = loaded_chunks.get(key, {})
	var tiles_layer := chunk_info.get("tiles", null) as Node2D
	var objects_layer := chunk_info.get("objects", null) as Node2D
	var enemies_layer := chunk_info.get("enemies", null) as Node2D
	if tiles_layer != null:
		tiles_layer.queue_free()
	if objects_layer != null:
		objects_layer.queue_free()
	if enemies_layer != null:
		enemies_layer.queue_free()
	loaded_chunks.erase(key)


func _get_or_create_chunk_data(chunk_coords: Vector2i) -> Dictionary:
	var key := _chunk_key(chunk_coords)
	var cached_variant: Variant = cached_chunks.get(key, null)
	if cached_variant is Dictionary:
		var cached_chunk: Dictionary = cached_variant
		if _normalize_chunk_data(cached_chunk, chunk_coords):
			cached_chunks[key] = cached_chunk
			dirty_cache = true
		return cached_chunk
	var generated := map_generator.generate_chunk(chunk_coords.x, chunk_coords.y)
	if _ensure_starter_gold_node(generated, chunk_coords):
		dirty_cache = true
	cached_chunks[key] = generated
	dirty_cache = true
	return generated


func _normalize_chunk_data(chunk_data: Dictionary, chunk_coords: Vector2i) -> bool:
	var changed: bool = false
	var regenerated: Dictionary = {}
	if not chunk_data.has("tiles") or not chunk_data.has("objects") or not chunk_data.has("enemies"):
		regenerated = map_generator.generate_chunk(chunk_coords.x, chunk_coords.y)
	if not chunk_data.has("tiles"):
		chunk_data["tiles"] = regenerated.get("tiles", [])
		changed = true
	if not chunk_data.has("objects"):
		chunk_data["objects"] = regenerated.get("objects", [])
		changed = true
	if not chunk_data.has("enemies"):
		chunk_data["enemies"] = regenerated.get("enemies", [])
		changed = true
	if not chunk_data.has("defeated_enemies") or not (chunk_data.get("defeated_enemies", []) is Array):
		chunk_data["defeated_enemies"] = []
		changed = true
	if _ensure_enemy_spawn_ids(chunk_data):
		changed = true
	if _ensure_starter_gold_node(chunk_data, chunk_coords):
		changed = true
	return changed


func _ensure_starter_gold_node(chunk_data: Dictionary, chunk_coords: Vector2i) -> bool:
	if chunk_coords != Vector2i.ZERO:
		return false

	var objects: Array = chunk_data.get("objects", [])
	for object_variant in objects:
		if not (object_variant is Dictionary):
			continue
		if str(object_variant.get("type", "")) == "gold_stone":
			return false

	var local_position := _find_starter_gold_position(chunk_data)
	if local_position == Vector2i(-1, -1):
		return false

	objects.append({
		"x": chunk_coords.x * chunk_size + local_position.x,
		"y": chunk_coords.y * chunk_size + local_position.y,
		"type": "gold_stone"
	})
	chunk_data["objects"] = objects
	return true


func _find_starter_gold_position(chunk_data: Dictionary) -> Vector2i:
	var candidate_positions: Array[Vector2i] = [
		Vector2i(chunk_size / 2 + 3, chunk_size / 2),
		Vector2i(chunk_size / 2 - 3, chunk_size / 2 + 1),
		Vector2i(chunk_size / 2 + 1, chunk_size / 2 - 3),
		Vector2i(chunk_size / 2 - 4, chunk_size / 2 - 2)
	]
	for local_position in candidate_positions:
		if local_position.x < 0 or local_position.y < 0 or local_position.x >= chunk_size or local_position.y >= chunk_size:
			continue
		if _can_place_starter_gold_at(chunk_data, local_position):
			return local_position
	return Vector2i(-1, -1)


func _can_place_starter_gold_at(chunk_data: Dictionary, local_position: Vector2i) -> bool:
	var tile_index: int = local_position.y * chunk_size + local_position.x
	var tiles: Array = chunk_data.get("tiles", [])
	if tile_index < 0 or tile_index >= tiles.size():
		return false
	var tile_variant: Variant = tiles[tile_index]
	if not (tile_variant is Dictionary):
		return false
	var tile_info: Dictionary = tile_variant
	if str(tile_info.get("tile", "")) == "water":
		return false

	for object_variant in chunk_data.get("objects", []):
		if not (object_variant is Dictionary):
			continue
		var object_info: Dictionary = object_variant
		var object_local_x: int = int(object_info.get("x", 0)) - chunk_size * int(floor(float(object_info.get("x", 0)) / max(1.0, float(chunk_size))))
		var object_local_y: int = int(object_info.get("y", 0)) - chunk_size * int(floor(float(object_info.get("y", 0)) / max(1.0, float(chunk_size))))
		if Vector2i(object_local_x, object_local_y) == local_position:
			return false
	return true


func _ensure_enemy_spawn_ids(chunk_data: Dictionary) -> bool:
	var changed := false
	var enemies: Array = chunk_data.get("enemies", [])
	for enemy_variant in enemies:
		if not (enemy_variant is Dictionary):
			continue
		var enemy_info := enemy_variant as Dictionary
		if str(enemy_info.get("spawn_id", "")) != "":
			continue
		var enemy_id: String = str(enemy_info.get("enemy_id", ""))
		var world_x: int = int(enemy_info.get("x", 0))
		var world_y: int = int(enemy_info.get("y", 0))
		enemy_info["spawn_id"] = "%s:%d:%d" % [enemy_id, world_x, world_y]
		changed = true
	return changed


func _build_enemy_layer(chunk_data: Dictionary, chunk_coords: Vector2i) -> Node2D:
	var enemies_layer := Node2D.new()
	var enemies: Array = chunk_data.get("enemies", [])
	var defeated_enemies: Array = chunk_data.get("defeated_enemies", [])
	for enemy_variant in enemies:
		if not (enemy_variant is Dictionary):
			continue
		var enemy_info: Dictionary = enemy_variant
		var enemy_id: String = str(enemy_info.get("enemy_id", ""))
		var spawn_id: String = str(enemy_info.get("spawn_id", ""))
		if spawn_id != "" and defeated_enemies.has(spawn_id):
			continue
		var scene_variant: Variant = ENEMY_SCENES.get(enemy_id, null)
		if not (scene_variant is PackedScene):
			continue
		var enemy_instance: Node = (scene_variant as PackedScene).instantiate()
		if not (enemy_instance is Node2D):
			enemy_instance.queue_free()
			continue
		var local_x: int = int(enemy_info.get("x", 0)) - chunk_coords.x * chunk_size
		var local_y: int = int(enemy_info.get("y", 0)) - chunk_coords.y * chunk_size
		var enemy_node := enemy_instance as Node2D
		enemy_node.position = Vector2(local_x * tile_size + tile_size * 0.5, local_y * tile_size + tile_size * 0.5)
		enemy_node.set_meta("generated_chunk_key", _chunk_key(chunk_coords))
		enemy_node.set_meta("generated_spawn_id", spawn_id)
		enemies_layer.add_child(enemy_node)
	return enemies_layer


func _update_current_biome() -> void:
	var chunk_coords := _world_to_chunk(player.global_position)
	var key := _chunk_key(chunk_coords)
	var chunk_data_variant: Variant = cached_chunks.get(key, null)
	if not (chunk_data_variant is Dictionary):
		return
	var chunk_data: Dictionary = chunk_data_variant
	var tile_x: int = int(floor(player.global_position.x / tile_size))
	var tile_y: int = int(floor(player.global_position.y / tile_size))
	var local_x: int = tile_x - chunk_coords.x * chunk_size
	var local_y: int = tile_y - chunk_coords.y * chunk_size
	if local_x < 0 or local_y < 0 or local_x >= chunk_size or local_y >= chunk_size:
		return
	var tile_index: int = local_y * chunk_size + local_x
	var tiles: Array = chunk_data.get("tiles", [])
	if tile_index < 0 or tile_index >= tiles.size():
		return
	var tile_info_variant: Variant = tiles[tile_index]
	if not (tile_info_variant is Dictionary):
		return
	var tile_info: Dictionary = tile_info_variant
	world_manager.change_biome(str(tile_info.get("biome", "plains")))


func _world_to_chunk(world_position: Vector2) -> Vector2i:
	var chunk_pixel_size: float = float(chunk_size * tile_size)
	return Vector2i(
		int(floor(world_position.x / chunk_pixel_size)),
		int(floor(world_position.y / chunk_pixel_size))
	)


func _chunk_world_origin(chunk_coords: Vector2i) -> Vector2:
	return Vector2(chunk_coords.x * chunk_size * tile_size, chunk_coords.y * chunk_size * tile_size)


func _chunk_key(chunk_coords: Vector2i) -> String:
	return "%d,%d" % [chunk_coords.x, chunk_coords.y]


func _get_persistence_path() -> String:
	return "user://world_chunks_%d.json" % world_seed


func _load_persisted_world_cache() -> void:
	if not persistence_enabled:
		return
	var path := _get_persistence_path()
	if not FileAccess.file_exists(path):
		return
	var raw_text := FileAccess.get_file_as_string(path)
	var parsed: Variant = JSON.parse_string(raw_text)
	if not (parsed is Dictionary):
		return
	var save_data: Dictionary = parsed
	if int(save_data.get("seed", world_seed)) != world_seed:
		return
	if int(save_data.get("chunk_size", chunk_size)) != chunk_size:
		return
	var chunks_variant: Variant = save_data.get("chunks", {})
	if chunks_variant is Dictionary:
		cached_chunks = chunks_variant.duplicate(true)
	pending_world_state = save_data.duplicate(true)
	dirty_cache = false


func _save_persisted_world_cache() -> void:
	if not persistence_enabled:
		return
	if not dirty_cache and pending_world_state.is_empty():
		return
	var file := FileAccess.open(_get_persistence_path(), FileAccess.WRITE)
	if file == null:
		push_error("Failed to open world chunk cache for writing")
		return
	file.store_string(JSON.stringify(get_world_save_data(), "\t"))
	file.close()
	dirty_cache = false


func _apply_pending_world_state() -> void:
	if pending_world_state.is_empty():
		return
	if pending_world_state.has("time_of_day"):
		world_manager.set_time_of_day(float(pending_world_state.get("time_of_day", world_manager.time_of_day)))
	if pending_world_state.has("player_position"):
		var pos_data: Variant = pending_world_state.get("player_position", {})
		if pos_data is Dictionary:
			player.global_position = Vector2(float(pos_data.get("x", player.global_position.x)), float(pos_data.get("y", player.global_position.y)))
	last_center_chunk = Vector2i(2147483647, 2147483647)


func get_world_save_data() -> Dictionary:
	return {
		"seed": world_seed,
		"chunk_size": chunk_size,
		"time_of_day": world_manager.time_of_day,
		"player_position": {"x": player.global_position.x, "y": player.global_position.y},
		"chunks": cached_chunks
	}


func load_world_save_data(data: Dictionary) -> void:
	pending_world_state = data.duplicate(true)
	var chunks_variant: Variant = pending_world_state.get("chunks", {})
	if chunks_variant is Dictionary:
		cached_chunks = chunks_variant.duplicate(true)
		dirty_cache = true
	if is_inside_tree():
		_clear_loaded_chunk_nodes()
		_apply_pending_world_state()
		_refresh_loaded_chunks(true)


func _on_day_night_cycle_changed(_time_of_day: float) -> void:
	_apply_day_night(_time_of_day)


func _apply_day_night(_time_of_day: float) -> void:
	world_canvas_modulate.color = world_manager.get_daylight_color()


func _quick_save_world() -> void:
	_save_persisted_world_cache()
	var save_system := get_node_or_null("/root/SaveSystem")
	if save_system != null and save_system.has_method("save_game"):
		save_system.save_game()
		print("Quick save complete")
		return
	push_warning("SaveSystem autoload not found; quick save skipped")


func _quick_load_world() -> void:
	var save_system := get_node_or_null("/root/SaveSystem")
	if save_system != null and save_system.has_method("load_game"):
		if save_system.load_game():
			print("Quick load complete")
		return
	push_warning("SaveSystem autoload not found; quick load skipped")


func _on_generated_enemy_killed(enemy: Node, _enemy_type: String, _position: Vector2) -> void:
	if enemy == null or not is_instance_valid(enemy):
		return
	var chunk_key: String = str(enemy.get_meta("generated_chunk_key", ""))
	var spawn_id: String = str(enemy.get_meta("generated_spawn_id", ""))
	if chunk_key == "" or spawn_id == "":
		return
	_mark_enemy_defeated(chunk_key, spawn_id)


func _mark_enemy_defeated(chunk_key: String, spawn_id: String) -> void:
	var chunk_variant: Variant = cached_chunks.get(chunk_key, null)
	if not (chunk_variant is Dictionary):
		return
	var chunk_data := chunk_variant as Dictionary
	var defeated_enemies: Array = chunk_data.get("defeated_enemies", [])
	if defeated_enemies.has(spawn_id):
		return
	defeated_enemies.append(spawn_id)
	chunk_data["defeated_enemies"] = defeated_enemies
	cached_chunks[chunk_key] = chunk_data
	dirty_cache = true


func _clear_loaded_chunk_nodes() -> void:
	var loaded_keys: Array = loaded_chunks.keys()
	for key_variant in loaded_keys:
		_unload_chunk(str(key_variant))
	last_center_chunk = Vector2i(2147483647, 2147483647)

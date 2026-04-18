# save_system.gd
# Handles game save/load functionality
extends Node

const SAVE_FILE_PATH = "user://savegame.save"

func save_game() -> void:
	var save_data = {
		"player": get_player_data(),
		"world": get_world_data(),
		"structures": save_structures(),
		"timestamp": Time.get_unix_time_from_system()
	}
	
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Failed to open save file for writing")
		return
	
	var json_string = JSON.stringify(save_data)
	file.store_string(json_string)
	file.close()
	print("Game saved successfully")

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		print("No save file found")
		return false
	
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file == null:
		push_error("Failed to open save file for reading")
		return false
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		push_error("Failed to parse save file")
		return false
	
	var save_data = json.data
	apply_save_data(save_data)
	print("Game loaded successfully")
	return true

func get_player_data() -> Dictionary:
	if Player_Inventory != null and Player_Inventory.has_method("get_save_data"):
		return Player_Inventory.get_save_data()
	return {}

func get_world_data() -> Dictionary:
	var current_scene := get_tree().current_scene
	if current_scene != null and current_scene.has_method("get_world_save_data"):
		return current_scene.get_world_save_data()
	return {}

func apply_save_data(data: Dictionary) -> void:
	if data.has("player") and Player_Inventory != null and Player_Inventory.has_method("load_from_save_data"):
		Player_Inventory.load_from_save_data(data["player"])

	var current_scene := get_tree().current_scene
	if data.has("world") and current_scene != null and current_scene.has_method("load_world_save_data"):
		current_scene.load_world_save_data(data["world"])
	
	# Load structures if present
	if data.has("structures"):
		load_structures(data["structures"])

## Save all structures in the scene
func save_structures() -> Array:
	var structure_data = []
	var structures = get_tree().get_nodes_in_group("structures")
	
	for structure in structures:
		if structure.has_method("get_save_data"):
			structure_data.append(structure.get_save_data())
	
	print("[Save_System] Saved %d structures" % structure_data.size())
	return structure_data

## Load structures from save data
func load_structures(structure_data: Array) -> void:
	if structure_data.is_empty():
		print("[Save_System] No structures to load")
		return
	
	var loaded_count = 0
	var failed_count = 0
	
	for data in structure_data:
		# Validate structure data
		if not _validate_structure_data(data):
			push_warning("[Save_System] Invalid structure data, skipping")
			failed_count += 1
			continue
		
		# Load structure through Building_System
		if Building_System.load_structure_from_data(data):
			loaded_count += 1
		else:
			failed_count += 1
	
	print("[Save_System] Loaded %d structures (%d failed)" % [loaded_count, failed_count])

## Validate structure save data
func _validate_structure_data(data: Dictionary) -> bool:
	# Check required fields
	if not data.has("type"):
		return false
	if not data.has("grid_position"):
		return false
	if not data.has("current_health"):
		return false
	
	# Validate grid position
	var grid_pos_data = data["grid_position"]
	if not grid_pos_data.has("x") or not grid_pos_data.has("y"):
		return false
	
	var grid_pos = Vector2i(grid_pos_data["x"], grid_pos_data["y"])
	
	# Check bounds [0, 29]
	if grid_pos.x < 0 or grid_pos.x >= 30 or grid_pos.y < 0 or grid_pos.y >= 30:
		push_warning("[Save_System] Structure position out of bounds: %s" % grid_pos)
		return false
	
	return true

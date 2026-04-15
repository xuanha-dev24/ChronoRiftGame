# save_system.gd
# Handles game save/load functionality
extends Node

const SAVE_FILE_PATH = "user://savegame.save"

func save_game() -> void:
	var save_data = {
		"player": get_player_data(),
		"world": get_world_data(),
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
	# TODO: Collect player data
	return {}

func get_world_data() -> Dictionary:
	# TODO: Collect world data
	return {}

func apply_save_data(data: Dictionary) -> void:
	# TODO: Apply loaded data to game
	pass

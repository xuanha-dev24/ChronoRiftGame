# DataManager.gd
# Loads and caches game data from JSON files
extends Node

var items_data: Dictionary = {}
var enemies_data: Dictionary = {}
var elements_data: Dictionary = {}
var biomes_data: Dictionary = {}

func _ready() -> void:
	load_all_data()

func load_all_data() -> void:
	items_data = load_json_file("res://data/items.json")
	enemies_data = load_json_file("res://data/enemies.json")
	elements_data = load_json_file("res://data/elements.json")
	biomes_data = load_json_file("res://data/biomes.json")
	print("All game data loaded successfully")

func load_json_file(file_path: String) -> Dictionary:
	if not FileAccess.file_exists(file_path):
		push_error("File not found: " + file_path)
		return {}
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("Failed to open file: " + file_path)
		return {}
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		push_error("Failed to parse JSON: " + file_path)
		return {}
	
	return json.data

func get_item_data(item_id: String) -> Dictionary:
	if items_data.has(item_id):
		return items_data[item_id]
	push_warning("Item not found: " + item_id)
	return {}

func get_enemy_data(enemy_id: String) -> Dictionary:
	if enemies_data.has(enemy_id):
		return enemies_data[enemy_id]
	push_warning("Enemy not found: " + enemy_id)
	return {}

func get_element_data(element_id: String) -> Dictionary:
	if elements_data.has(element_id):
		return elements_data[element_id]
	push_warning("Element not found: " + element_id)
	return {}

func get_biome_data(biome_id: String) -> Dictionary:
	if biomes_data.has(biome_id):
		return biomes_data[biome_id]
	push_warning("Biome not found: " + biome_id)
	return {}

func get_drop_table(enemy_id: String) -> Array:
	if enemies_data.has(enemy_id):
		var enemy_data = enemies_data[enemy_id]
		if enemy_data.has("loot_table"):
			return enemy_data["loot_table"]
	return []

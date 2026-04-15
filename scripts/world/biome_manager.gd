# biome_manager.gd
# Manages biome-specific logic and spawning
extends Node

var active_biome_data: Dictionary = {}

func load_biome(biome_id: String) -> void:
	active_biome_data = DataManager.get_biome_data(biome_id)
	if active_biome_data.is_empty():
		push_warning("Failed to load biome: " + biome_id)
		return
	
	print("Biome loaded: ", biome_id)
	# TODO: Apply biome-specific settings (enemy spawns, resources, etc.)

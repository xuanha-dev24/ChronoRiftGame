# world_manager.gd
# Manages world state and transitions
extends Node

var current_biome: String = "plains"
var time_of_day: float = 0.5  # 0.0 = midnight, 0.5 = noon, 1.0 = midnight

func _ready() -> void:
	pass

func change_biome(biome_name: String) -> void:
	current_biome = biome_name
	EventBus.biome_entered.emit(biome_name)
	print("Entered biome: ", biome_name)

func update_time_of_day(delta: float) -> void:
	# TODO: Implement day/night cycle
	pass

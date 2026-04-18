extends GutTest

const PROTOTYPE_WORLD_SCRIPT = preload("res://scripts/world/prototype_world.gd")


func test_world_manager_formats_clock_time() -> void:
	var world_manager := WorldManager.new()
	add_child_autofree(world_manager)
	world_manager.auto_cycle_enabled = false
	world_manager.set_time_of_day(0.5)

	assert_eq(world_manager.get_clock_time_string(), "12:00", "Midday should format as 12:00")
	assert_eq(world_manager.get_time_phase_name(), "Day", "Midday should report Day")


func test_world_manager_reports_dawn_phase() -> void:
	var world_manager := WorldManager.new()
	add_child_autofree(world_manager)
	world_manager.auto_cycle_enabled = false
	world_manager.set_time_of_day(0.25)

	assert_eq(world_manager.get_time_phase_name(), "Dawn", "0.25 time_of_day should be Dawn")


func test_origin_chunk_gets_starter_gold_node() -> void:
	var prototype_world = PROTOTYPE_WORLD_SCRIPT.new()
	add_child_autofree(prototype_world)
	prototype_world.chunk_size = 16

	var tiles: Array = []
	for y in range(prototype_world.chunk_size):
		for x in range(prototype_world.chunk_size):
			tiles.append({"x": x, "y": y, "tile": "grass", "biome": "plains"})

	var chunk_data: Dictionary = {
		"tiles": tiles,
		"objects": [],
		"enemies": []
	}

	var changed: bool = prototype_world._ensure_starter_gold_node(chunk_data, Vector2i.ZERO)

	assert_true(changed, "Origin chunk should receive a starter gold node when missing")
	assert_eq(chunk_data["objects"].size(), 1, "Should append one starter gold object")
	assert_eq(chunk_data["objects"][0]["type"], "gold_stone", "Starter object should be gold_stone")


func test_non_origin_chunk_does_not_get_starter_gold() -> void:
	var prototype_world = PROTOTYPE_WORLD_SCRIPT.new()
	add_child_autofree(prototype_world)
	prototype_world.chunk_size = 16

	var chunk_data: Dictionary = {
		"tiles": [],
		"objects": [],
		"enemies": []
	}

	var changed: bool = prototype_world._ensure_starter_gold_node(chunk_data, Vector2i(1, 0))

	assert_false(changed, "Only the origin chunk should get guaranteed starter gold")
extends GutTest

## Unit tests for Crafting Station structure
## Tests crafting station properties and interaction system

var crafting_station_scene = preload("res://scenes/structures/CraftingStation.tscn")
var crafting_station: Structure

func before_each():
	crafting_station = crafting_station_scene.instantiate()
	add_child_autofree(crafting_station)
	crafting_station.initialize(Vector2i(10, 10))

func after_each():
	crafting_station = null

# ===== Task 6.2: Crafting Station Properties =====

func test_crafting_station_has_correct_type():
	# REQ-005.2: Crafting station has correct structure type
	assert_eq(crafting_station.structure_type, "crafting_station", "Should have type 'crafting_station'")

func test_crafting_station_has_correct_max_health():
	# Crafting station should have 200 max health
	assert_eq(crafting_station.max_health, 200, "Should have 200 max health")

func test_crafting_station_has_correct_grid_size():
	# Crafting station should occupy 2x2 grid
	assert_eq(crafting_station.grid_size, Vector2i(2, 2), "Should be 2x2 grid size")

func test_crafting_station_has_correct_resource_costs():
	# Crafting station should cost 20 wood + 15 stone
	assert_eq(crafting_station.resource_costs, {"wood": 20, "stone": 15}, "Should cost 20 wood + 15 stone")

func test_crafting_station_collision_shape_size():
	# REQ-018.3: Collision shape matches grid size (2x2 = 32x32 pixels)
	var collision_shape = crafting_station.get_node("CollisionShape2D")
	var shape = collision_shape.shape as RectangleShape2D
	
	var expected_size = Vector2(32.0, 32.0)
	assert_eq(shape.size, expected_size, "Collision shape should be 32x32 pixels")

# ===== Task 6.2: Interaction System =====

func test_interaction_indicator_hidden_initially():
	# REQ-011.1: Interaction indicator hidden initially
	var indicator = crafting_station.get_node("InteractionIndicator")
	assert_false(indicator.visible, "Interaction indicator should be hidden initially")

func test_interaction_indicator_shows_when_player_enters():
	# REQ-011.1: Interaction indicator appears when player within range
	var player = Node2D.new()
	player.add_to_group("player")
	add_child_autofree(player)
	
	crafting_station._on_body_entered(player)
	
	var indicator = crafting_station.get_node("InteractionIndicator")
	assert_true(indicator.visible, "Interaction indicator should be visible when player enters")
	assert_true(crafting_station.player_in_range, "player_in_range should be true")

func test_interaction_indicator_hides_when_player_exits():
	# REQ-011.4: Interaction indicator hides when player moves away
	var player = Node2D.new()
	player.add_to_group("player")
	add_child_autofree(player)
	
	crafting_station._on_body_entered(player)
	crafting_station._on_body_exited(player)
	
	var indicator = crafting_station.get_node("InteractionIndicator")
	assert_false(indicator.visible, "Interaction indicator should be hidden when player exits")
	assert_false(crafting_station.player_in_range, "player_in_range should be false")

func test_crafting_ui_signal_emitted_on_interact():
	# REQ-011.2: EventBus.crafting_station_opened signal emitted
	watch_signals(EventBus)
	
	crafting_station.open_crafting_ui()
	
	assert_signal_emitted(EventBus, "crafting_station_opened", "Should emit crafting_station_opened signal")

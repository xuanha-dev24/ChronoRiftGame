extends GutTest

## Unit tests for Storage Chest structure
## Tests chest properties, inventory system, and item dropping

var storage_chest_scene = preload("res://scenes/structures/StorageChest.tscn")
var storage_chest: Structure

func before_each():
	for pickup in get_tree().get_nodes_in_group("pickups"):
		pickup.queue_free()

	storage_chest = storage_chest_scene.instantiate()
	add_child_autofree(storage_chest)
	storage_chest.initialize(Vector2i(10, 10))

func after_each():
	for pickup in get_tree().get_nodes_in_group("pickups"):
		pickup.queue_free()

	storage_chest = null

# ===== Task 7.2: Storage Chest Properties =====

func test_storage_chest_has_correct_type():
	# REQ-005.2: Storage chest has correct structure type
	assert_eq(storage_chest.structure_type, "storage_chest", "Should have type 'storage_chest'")

func test_storage_chest_has_correct_max_health():
	# Storage chest should have 150 max health
	assert_eq(storage_chest.max_health, 150, "Should have 150 max health")

func test_storage_chest_has_correct_grid_size():
	# Storage chest should occupy 2x2 grid
	assert_eq(storage_chest.grid_size, Vector2i(2, 2), "Should be 2x2 grid size")

func test_storage_chest_has_correct_resource_costs():
	# Storage chest should cost 25 wood
	assert_eq(storage_chest.resource_costs, {"wood": 25}, "Should cost 25 wood")

func test_storage_chest_collision_shape_size():
	# REQ-018.3: Collision shape matches grid size (2x2 = 32x32 pixels)
	var collision_shape = storage_chest.get_node("CollisionShape2D")
	var shape = collision_shape.shape as RectangleShape2D
	
	var expected_size = Vector2(32.0, 32.0)
	assert_eq(shape.size, expected_size, "Collision shape should be 32x32 pixels")

# ===== Task 7.3: Chest Inventory Methods =====

func test_chest_inventory_initialized_with_20_slots():
	# REQ-012.3: Chest has 20-slot inventory
	assert_eq(storage_chest.chest_inventory.size(), 20, "Chest should have 20 inventory slots")
	
	# All slots should be null initially
	for i in range(20):
		assert_null(storage_chest.chest_inventory[i], "Slot %d should be null initially" % i)

func test_add_item_to_empty_slot():
	# REQ-012.4: Can add items to chest
	var success = storage_chest.add_item("chrono_dust", 5)
	
	assert_true(success, "Should successfully add item")
	assert_eq(storage_chest.chest_inventory[0]["item_id"], "chrono_dust", "Item ID should be correct")
	assert_eq(storage_chest.chest_inventory[0]["quantity"], 5, "Quantity should be correct")

func test_add_item_stacks_with_existing():
	# Items should stack if same type
	storage_chest.add_item("chrono_dust", 5)
	storage_chest.add_item("chrono_dust", 3)
	
	assert_eq(storage_chest.chest_inventory[0]["quantity"], 8, "Should stack to 8")
	assert_null(storage_chest.chest_inventory[1], "Second slot should remain empty")

func test_add_different_items_to_separate_slots():
	# Different items should go to separate slots
	storage_chest.add_item("chrono_dust", 5)
	storage_chest.add_item("health_potion", 2)
	
	assert_eq(storage_chest.chest_inventory[0]["item_id"], "chrono_dust", "First slot should have chrono_dust")
	assert_eq(storage_chest.chest_inventory[1]["item_id"], "health_potion", "Second slot should have health_potion")

func test_add_item_fails_when_inventory_full():
	# REQ-012.3: Chest has 20-slot limit
	# Fill all 20 slots
	for i in range(20):
		storage_chest.add_item("item_%d" % i, 1)
	
	# Try to add 21st item
	var success = storage_chest.add_item("extra_item", 1)
	
	assert_false(success, "Should fail to add item when inventory full")

func test_remove_item_from_slot():
	# REQ-012.5: Can remove items from chest
	storage_chest.add_item("chrono_dust", 5)
	
	var removed_item = storage_chest.remove_item(0)
	
	assert_eq(removed_item["item_id"], "chrono_dust", "Removed item should be chrono_dust")
	assert_eq(removed_item["quantity"], 5, "Removed quantity should be 5")
	assert_null(storage_chest.chest_inventory[0], "Slot should be empty after removal")

func test_remove_item_from_empty_slot_returns_empty_dict():
	# Removing from empty slot should return empty dictionary
	var removed_item = storage_chest.remove_item(0)
	
	assert_eq(removed_item, {}, "Should return empty dictionary")

func test_get_item_returns_item_data():
	# get_item should return item data without removing
	storage_chest.add_item("chrono_dust", 5)
	
	var item_data = storage_chest.get_item(0)
	
	assert_eq(item_data["item_id"], "chrono_dust", "Should return correct item ID")
	assert_eq(item_data["quantity"], 5, "Should return correct quantity")
	assert_not_null(storage_chest.chest_inventory[0], "Item should still be in slot")

func test_is_inventory_full_returns_false_when_empty():
	# is_inventory_full should return false when slots available
	assert_false(storage_chest.is_inventory_full(), "Should return false when empty")

func test_is_inventory_full_returns_true_when_full():
	# is_inventory_full should return true when all slots occupied
	for i in range(20):
		storage_chest.add_item("item_%d" % i, 1)
	
	assert_true(storage_chest.is_inventory_full(), "Should return true when full")

# ===== Task 7.4: Chest Interaction System =====

func test_interaction_indicator_hidden_initially():
	# REQ-012.1: Interaction indicator hidden initially
	var indicator = storage_chest.get_node("InteractionIndicator")
	assert_false(indicator.visible, "Interaction indicator should be hidden initially")

func test_interaction_indicator_shows_when_player_enters():
	# REQ-012.1: Interaction indicator appears when player within range
	var player = Node2D.new()
	player.add_to_group("player")
	add_child_autofree(player)
	
	storage_chest._on_body_entered(player)
	
	var indicator = storage_chest.get_node("InteractionIndicator")
	assert_true(indicator.visible, "Interaction indicator should be visible when player enters")
	assert_true(storage_chest.player_in_range, "player_in_range should be true")

func test_chest_ui_signal_emitted_on_interact():
	# REQ-012.2: EventBus.storage_chest_opened signal emitted
	watch_signals(EventBus)
	
	storage_chest.open_chest_ui()
	
	assert_signal_emitted(EventBus, "storage_chest_opened", "Should emit storage_chest_opened signal")

# ===== Task 7.5: Chest Item Dropping on Destruction =====

func test_chest_drops_items_on_destruction():
	# REQ-012.7, REQ-015.5: Chest drops all items when destroyed
	storage_chest.add_item("chrono_dust", 5)
	storage_chest.add_item("health_potion", 2)
	
	# Destroy chest
	storage_chest.destroy()
	
	await wait_physics_frames(2)
	
	# Check for pickup items in scene
	var pickups = get_tree().get_nodes_in_group("pickups")
	assert_eq(pickups.size(), 2, "Should spawn 2 pickup items")

func test_chest_drops_no_items_when_empty():
	# Empty chest should not spawn pickups
	storage_chest.destroy()
	
	await wait_physics_frames(2)
	
	var pickups = get_tree().get_nodes_in_group("pickups")
	assert_eq(pickups.size(), 0, "Should not spawn pickups when empty")

# ===== Task 7.7: Chest Inventory Serialization =====

func test_chest_save_data_includes_inventory():
	# REQ-013.2: Save data includes inventory contents
	storage_chest.add_item("chrono_dust", 5)
	storage_chest.add_item("health_potion", 2)
	
	var save_data = storage_chest.get_save_data()
	
	assert_true(save_data.has("inventory"), "Save data should have 'inventory' field")
	assert_eq(save_data["inventory"].size(), 20, "Inventory should have 20 slots")
	assert_eq(save_data["inventory"][0]["item_id"], "chrono_dust", "First item should be chrono_dust")
	assert_eq(save_data["inventory"][1]["item_id"], "health_potion", "Second item should be health_potion")

func test_chest_load_from_data_restores_inventory():
	# REQ-013.4: Load from data restores inventory contents
	var save_data = {
		"type": "storage_chest",
		"grid_position": {"x": 10, "y": 10},
		"current_health": 150,
		"rotation": 0,
		"inventory": [
			{"item_id": "chrono_dust", "quantity": 5},
			{"item_id": "health_potion", "quantity": 2},
			null, null, null, null, null, null, null, null,
			null, null, null, null, null, null, null, null, null, null
		]
	}
	
	storage_chest.load_from_data(save_data)
	
	assert_eq(storage_chest.chest_inventory[0]["item_id"], "chrono_dust", "First item should be restored")
	assert_eq(storage_chest.chest_inventory[0]["quantity"], 5, "First item quantity should be restored")
	assert_eq(storage_chest.chest_inventory[1]["item_id"], "health_potion", "Second item should be restored")
	assert_null(storage_chest.chest_inventory[2], "Empty slots should be null")

func test_chest_inventory_round_trip():
	# REQ-013.2, REQ-013.4: Save and load should preserve inventory
	storage_chest.add_item("chrono_dust", 5)
	storage_chest.add_item("health_potion", 2)
	storage_chest.add_item("mana_potion", 3)
	
	var save_data = storage_chest.get_save_data()
	
	# Create new chest and load data
	var new_chest = storage_chest_scene.instantiate()
	add_child_autofree(new_chest)
	new_chest.initialize(Vector2i(0, 0))
	new_chest.load_from_data(save_data)
	
	assert_eq(new_chest.chest_inventory[0]["item_id"], "chrono_dust", "First item should match")
	assert_eq(new_chest.chest_inventory[0]["quantity"], 5, "First quantity should match")
	assert_eq(new_chest.chest_inventory[1]["item_id"], "health_potion", "Second item should match")
	assert_eq(new_chest.chest_inventory[2]["item_id"], "mana_potion", "Third item should match")

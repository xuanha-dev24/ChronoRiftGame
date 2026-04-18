extends GutTest

var player_inventory_script = preload("res://scripts/player/player_inventory.gd")
var player_inventory: Node

func before_each():
	player_inventory = player_inventory_script.new()
	add_child_autofree(player_inventory)
	player_inventory.initialize_inventory()

func test_inventory_initializes_with_30_slots():
	assert_eq(player_inventory.inventory.size(), 30, "Player inventory should expose 30 slots")
	for i in range(30):
		assert_null(player_inventory.inventory[i], "Slot %d should be empty initially" % i)

func test_add_item_uses_first_empty_slot():
	var success = player_inventory.add_item("chrono_dust", 5)

	assert_true(success, "Should add item into first empty slot")
	assert_eq(player_inventory.inventory[0]["id"], "chrono_dust", "First slot should contain chrono_dust")
	assert_eq(player_inventory.inventory[0]["quantity"], 5, "Quantity should match")

func test_move_slot_item_moves_to_empty_slot():
	player_inventory.add_item("chrono_dust", 5)

	var moved = player_inventory.move_slot_item(0, 4, false)

	assert_true(moved, "Should move item to empty target slot")
	assert_null(player_inventory.inventory[0], "Source slot should be cleared")
	assert_eq(player_inventory.inventory[4]["id"], "chrono_dust", "Target slot should receive the stack")

func test_move_slot_item_swaps_different_items():
	player_inventory.add_item("chrono_dust", 5)
	player_inventory.set_item(3, {"id": "health_potion", "quantity": 2}, false)

	var moved = player_inventory.move_slot_item(0, 3, false)

	assert_true(moved, "Should swap occupied slots with different items")
	assert_eq(player_inventory.inventory[0]["id"], "health_potion", "Source slot should now contain the previous target item")
	assert_eq(player_inventory.inventory[3]["id"], "chrono_dust", "Target slot should now contain the dragged item")

func test_move_slot_item_merges_matching_stack():
	player_inventory.set_item(0, {"id": "chrono_dust", "quantity": 5}, false)
	player_inventory.set_item(1, {"id": "chrono_dust", "quantity": 7}, false)

	var moved = player_inventory.move_slot_item(0, 1, false)

	assert_true(moved, "Should merge matching stacks")
	assert_null(player_inventory.inventory[0], "Merged source slot should be cleared")
	assert_eq(player_inventory.inventory[1]["quantity"], 12, "Target slot should contain combined quantity")

func test_get_save_data_preserves_slot_positions():
	player_inventory.set_item(0, {"id": "chrono_dust", "quantity": 5}, false)
	player_inventory.set_item(4, {"id": "health_potion", "quantity": 2}, false)

	var save_data = player_inventory.get_save_data()

	assert_true(save_data.has("inventory"), "Save payload should include inventory")
	assert_eq(save_data["inventory"].size(), 30, "Save payload should preserve all 30 slots")
	assert_eq(save_data["inventory"][0]["id"], "chrono_dust", "Occupied slot should keep its item id")
	assert_null(save_data["inventory"][1], "Empty slots should be saved as null")
	assert_eq(save_data["inventory"][4]["id"], "health_potion", "Later occupied slot should preserve its position")

func test_load_from_save_data_restores_slot_positions():
	var save_data = {
		"inventory": [
			{"id": "chrono_dust", "quantity": 5},
			null,
			null,
			{"id": "health_potion", "quantity": 2},
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null
		]
	}

	player_inventory.load_from_save_data(save_data, false)

	assert_eq(player_inventory.inventory[0]["id"], "chrono_dust", "First saved slot should be restored")
	assert_null(player_inventory.inventory[1], "Empty saved slot should remain empty")
	assert_eq(player_inventory.inventory[3]["id"], "health_potion", "Non-contiguous saved slot should keep its original index")
	assert_eq(player_inventory.get_used_slot_count(), 2, "Used slot count should match restored data")
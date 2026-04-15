extends GutTest

# Unit tests for DataManager loot methods
# Tests Task 2.1: get_drop_table method

func before_all():
	# Ensure DataManager is loaded
	if not has_node("/root/DataManager"):
		add_child_autofree(preload("res://autoloads/DataManager.gd").new())

func test_get_drop_table_with_valid_enemy_slime_basic():
	# Test get_drop_table with valid enemy type: slime_basic
	var drop_table = DataManager.get_drop_table("slime_basic")
	
	assert_not_null(drop_table, "Drop table should not be null for slime_basic")
	assert_true(drop_table is Array, "Drop table should be an Array")
	assert_eq(drop_table.size(), 2, "slime_basic should have 2 loot entries")
	
	# Verify first entry structure
	assert_true(drop_table[0].has("item_id"), "First entry should have item_id")
	assert_true(drop_table[0].has("chance"), "First entry should have chance")
	assert_true(drop_table[0].has("quantity"), "First entry should have quantity")
	
	# Verify specific values for slime_basic
	assert_eq(drop_table[0]["item_id"], "chrono_dust", "First item should be chrono_dust")
	assert_eq(drop_table[0]["chance"], 0.3, "chrono_dust drop chance should be 0.3")

func test_get_drop_table_with_valid_enemy_fire_imp():
	# Test get_drop_table with valid enemy type: fire_imp
	var drop_table = DataManager.get_drop_table("fire_imp")
	
	assert_not_null(drop_table, "Drop table should not be null for fire_imp")
	assert_true(drop_table is Array, "Drop table should be an Array")
	assert_eq(drop_table.size(), 2, "fire_imp should have 2 loot entries")
	
	# Verify first entry for fire_imp
	assert_eq(drop_table[0]["item_id"], "fire_crystal", "First item should be fire_crystal")
	assert_eq(drop_table[0]["chance"], 0.15, "fire_crystal drop chance should be 0.15")

func test_get_drop_table_with_valid_enemy_earth_golem():
	# Test get_drop_table with valid enemy type: earth_golem
	var drop_table = DataManager.get_drop_table("earth_golem")
	
	assert_not_null(drop_table, "Drop table should not be null for earth_golem")
	assert_true(drop_table is Array, "Drop table should be an Array")
	assert_eq(drop_table.size(), 3, "earth_golem should have 3 loot entries")

func test_get_drop_table_with_unknown_enemy():
	# Test get_drop_table with unknown enemy type (should return empty array)
	var drop_table = DataManager.get_drop_table("unknown_enemy_type")
	
	assert_not_null(drop_table, "Drop table should not be null even for unknown enemy")
	assert_true(drop_table is Array, "Drop table should be an Array")
	assert_eq(drop_table.size(), 0, "Unknown enemy should return empty array")

func test_get_drop_table_with_empty_string():
	# Test get_drop_table with empty string
	var drop_table = DataManager.get_drop_table("")
	
	assert_not_null(drop_table, "Drop table should not be null for empty string")
	assert_true(drop_table is Array, "Drop table should be an Array")
	assert_eq(drop_table.size(), 0, "Empty string should return empty array")

func test_get_drop_table_quantity_array_structure():
	# Test that quantity field is properly structured as [min, max]
	var drop_table = DataManager.get_drop_table("slime_basic")
	
	var first_entry = drop_table[0]
	assert_true(first_entry["quantity"] is Array, "Quantity should be an Array")
	assert_eq(first_entry["quantity"].size(), 2, "Quantity array should have 2 elements [min, max]")
	assert_true(first_entry["quantity"][0] is int or first_entry["quantity"][0] is float, "Min quantity should be numeric")
	assert_true(first_entry["quantity"][1] is int or first_entry["quantity"][1] is float, "Max quantity should be numeric")

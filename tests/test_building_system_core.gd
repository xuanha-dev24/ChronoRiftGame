extends GutTest

# Unit tests for Building_System core functionality (Task 1)
# Tests build mode, grid conversion, and placement validation

func before_each():
	# Reset Building_System state
	Building_System.build_mode_active = false
	Building_System.selected_structure_type = ""
	Building_System.structures.clear()
	Building_System.structure_count = 0
	Building_System.spatial_grid.clear()
	if Building_System.placement_preview != null:
		Building_System.placement_preview.queue_free()
		Building_System.placement_preview = null

# Helper function to create mock structure with required properties
func create_mock_structure(grid_pos: Vector2i, grid_size: Vector2i = Vector2i(1, 1)) -> Node2D:
	var structure = Node2D.new()
	structure.set_meta("grid_position", grid_pos)
	structure.set_meta("grid_size", grid_size)
	add_child_autofree(structure)
	return structure

# ===== Task 1.2: Build Mode Toggle =====

func test_toggle_build_mode_activates():
	# REQ-001.1: Toggle build mode on
	assert_false(Building_System.build_mode_active, "Build mode should start inactive")
	
	Building_System.toggle_build_mode()
	
	assert_true(Building_System.build_mode_active, "Build mode should be active after toggle")

func test_toggle_build_mode_deactivates():
	# REQ-001.1: Toggle build mode off
	Building_System.build_mode_active = true
	
	Building_System.toggle_build_mode()
	
	assert_false(Building_System.build_mode_active, "Build mode should be inactive after toggle")

func test_toggle_build_mode_emits_signal():
	# REQ-001.5: Emit build_mode_changed signal
	watch_signals(EventBus)
	
	Building_System.toggle_build_mode()
	
	assert_signal_emitted(EventBus, "build_mode_changed", "Should emit build_mode_changed signal")

# ===== Task 1.3: Grid Coordinate Conversion =====

func test_world_to_grid_conversion():
	# REQ-003.2, REQ-017.1: Convert world position to grid coordinates
	var world_pos = Vector2(32, 48)
	var grid_pos = Building_System.world_to_grid(world_pos)
	
	assert_eq(grid_pos, Vector2i(2, 3), "World position (32, 48) should map to grid (2, 3)")

func test_world_to_grid_with_offset():
	# Test conversion with non-aligned world position
	var world_pos = Vector2(37, 52)
	var grid_pos = Building_System.world_to_grid(world_pos)
	
	assert_eq(grid_pos, Vector2i(2, 3), "World position (37, 52) should snap to grid (2, 3)")

func test_grid_to_world_conversion():
	# REQ-003.2, REQ-017.1: Convert grid coordinates to world position (center of cell)
	var grid_pos = Vector2i(5, 10)
	var world_pos = Building_System.grid_to_world(grid_pos)
	
	assert_eq(world_pos, Vector2(88.0, 168.0), "Grid (5, 10) should map to world center (88, 168)")

func test_grid_conversion_round_trip():
	# Test bidirectional conversion
	var original_grid = Vector2i(7, 14)
	var world_pos = Building_System.grid_to_world(original_grid)
	var converted_grid = Building_System.world_to_grid(world_pos)
	
	assert_eq(converted_grid, original_grid, "Round-trip conversion should preserve grid position")

func test_world_to_grid_at_origin():
	# Test conversion at origin
	var world_pos = Vector2(0, 0)
	var grid_pos = Building_System.world_to_grid(world_pos)
	
	assert_eq(grid_pos, Vector2i(0, 0), "World origin should map to grid origin")

func test_grid_to_world_at_origin():
	# Test conversion at origin
	var grid_pos = Vector2i(0, 0)
	var world_pos = Building_System.grid_to_world(grid_pos)
	
	assert_eq(world_pos, Vector2(8.0, 8.0), "Grid origin should map to world center (8, 8)")

# ===== Task 1.7: Placement Validation - Bounds Checking =====

func test_is_within_bounds_valid_1x1():
	# REQ-004.1: Valid placement within bounds
	var grid_pos = Vector2i(10, 15)
	var grid_size = Vector2i(1, 1)
	
	var result = Building_System.is_within_bounds(grid_pos, grid_size)
	
	assert_true(result, "Position (10, 15) with size 1x1 should be within bounds")

func test_is_within_bounds_valid_2x2():
	# REQ-004.1: Valid placement for 2x2 structure
	var grid_pos = Vector2i(28, 28)
	var grid_size = Vector2i(2, 2)
	
	var result = Building_System.is_within_bounds(grid_pos, grid_size)
	
	assert_true(result, "Position (28, 28) with size 2x2 should be within bounds (occupies 28-29, 28-29)")

func test_is_within_bounds_out_of_bounds_negative_x():
	# REQ-004.1: Invalid placement with negative X
	var grid_pos = Vector2i(-1, 10)
	var grid_size = Vector2i(1, 1)
	
	var result = Building_System.is_within_bounds(grid_pos, grid_size)
	
	assert_false(result, "Position (-1, 10) should be out of bounds")

func test_is_within_bounds_out_of_bounds_negative_y():
	# REQ-004.1: Invalid placement with negative Y
	var grid_pos = Vector2i(10, -1)
	var grid_size = Vector2i(1, 1)
	
	var result = Building_System.is_within_bounds(grid_pos, grid_size)
	
	assert_false(result, "Position (10, -1) should be out of bounds")

func test_is_within_bounds_out_of_bounds_x_too_large():
	# REQ-004.1: Invalid placement with X >= 30
	var grid_pos = Vector2i(30, 10)
	var grid_size = Vector2i(1, 1)
	
	var result = Building_System.is_within_bounds(grid_pos, grid_size)
	
	assert_false(result, "Position (30, 10) should be out of bounds (max is 29)")

func test_is_within_bounds_out_of_bounds_y_too_large():
	# REQ-004.1: Invalid placement with Y >= 30
	var grid_pos = Vector2i(10, 30)
	var grid_size = Vector2i(1, 1)
	
	var result = Building_System.is_within_bounds(grid_pos, grid_size)
	
	assert_false(result, "Position (10, 30) should be out of bounds (max is 29)")

func test_is_within_bounds_2x2_partially_out():
	# REQ-004.1: Invalid placement for 2x2 structure partially out of bounds
	var grid_pos = Vector2i(29, 29)
	var grid_size = Vector2i(2, 2)
	
	var result = Building_System.is_within_bounds(grid_pos, grid_size)
	
	assert_false(result, "Position (29, 29) with size 2x2 should be out of bounds (would occupy 29-30, 29-30)")

# ===== Task 1.7: Placement Validation - Overlap Detection =====

func test_check_overlap_with_structures_no_overlap():
	# REQ-004.2: No overlap with existing structures
	var mock_structure = create_mock_structure(Vector2i(5, 5), Vector2i(1, 1))
	Building_System.register_structure(Vector2i(5, 5), mock_structure)
	
	var grid_pos = Vector2i(10, 10)
	var grid_size = Vector2i(1, 1)
	
	var result = Building_System.check_overlap_with_structures(grid_pos, grid_size)
	
	assert_false(result, "Position (10, 10) should not overlap with structure at (5, 5)")

func test_check_overlap_with_structures_exact_overlap():
	# REQ-004.2: Exact overlap with existing structure
	var mock_structure = create_mock_structure(Vector2i(10, 10), Vector2i(1, 1))
	Building_System.register_structure(Vector2i(10, 10), mock_structure)
	
	var grid_pos = Vector2i(10, 10)
	var grid_size = Vector2i(1, 1)
	
	var result = Building_System.check_overlap_with_structures(grid_pos, grid_size)
	
	assert_true(result, "Position (10, 10) should overlap with structure at (10, 10)")

func test_check_overlap_with_structures_2x2_overlap():
	# REQ-004.2: 2x2 structure overlapping with existing structure
	var mock_structure = create_mock_structure(Vector2i(11, 11), Vector2i(1, 1))
	Building_System.register_structure(Vector2i(11, 11), mock_structure)
	
	var grid_pos = Vector2i(10, 10)
	var grid_size = Vector2i(2, 2)
	
	var result = Building_System.check_overlap_with_structures(grid_pos, grid_size)
	
	assert_true(result, "2x2 structure at (10, 10) should overlap with structure at (11, 11)")

func test_check_overlap_with_structures_adjacent_no_overlap():
	# REQ-004.2: Adjacent structures should not overlap
	var mock_structure = create_mock_structure(Vector2i(10, 10), Vector2i(1, 1))
	Building_System.register_structure(Vector2i(10, 10), mock_structure)
	
	var grid_pos = Vector2i(11, 10)
	var grid_size = Vector2i(1, 1)
	
	var result = Building_System.check_overlap_with_structures(grid_pos, grid_size)
	
	assert_false(result, "Position (11, 10) should not overlap with structure at (10, 10)")

# ===== Task 1.7: Placement Validation - Complete Validation =====

func test_validate_placement_valid():
	# REQ-004.5: Valid placement returns success
	var grid_pos = Vector2i(10, 10)
	var grid_size = Vector2i(1, 1)
	
	var result = Building_System.validate_placement(grid_pos, grid_size)
	
	assert_true(result["valid"], "Valid placement should return valid=true")
	assert_eq(result["error"], "", "Valid placement should have empty error message")

func test_validate_placement_out_of_bounds():
	# REQ-004.5: Out of bounds placement returns error
	var grid_pos = Vector2i(30, 10)
	var grid_size = Vector2i(1, 1)
	
	var result = Building_System.validate_placement(grid_pos, grid_size)
	
	assert_false(result["valid"], "Out of bounds placement should return valid=false")
	assert_eq(result["error"], "Cannot place here: Out of bounds", "Should return bounds error message")

func test_validate_placement_overlapping_structure():
	# REQ-004.5: Overlapping placement returns error
	var mock_structure = create_mock_structure(Vector2i(10, 10), Vector2i(1, 1))
	Building_System.register_structure(Vector2i(10, 10), mock_structure)
	
	var grid_pos = Vector2i(10, 10)
	var grid_size = Vector2i(1, 1)
	
	var result = Building_System.validate_placement(grid_pos, grid_size)
	
	assert_false(result["valid"], "Overlapping placement should return valid=false")
	assert_eq(result["error"], "Cannot place here: Overlapping with existing structure", "Should return overlap error message")

func test_validate_placement_structure_limit_reached():
	# REQ-020.1, REQ-020.2: Structure limit enforcement
	Building_System.structure_count = 100
	
	var grid_pos = Vector2i(10, 10)
	var grid_size = Vector2i(1, 1)
	
	var result = Building_System.validate_placement(grid_pos, grid_size)
	
	assert_false(result["valid"], "Placement at structure limit should return valid=false")
	assert_eq(result["error"], "Structure limit reached (100/100)", "Should return limit error message")

# ===== Structure Registry =====

func test_register_structure():
	# REQ-005.4: Register structure in dictionary
	var structure = Node2D.new()
	add_child_autofree(structure)
	var grid_pos = Vector2i(10, 10)
	
	Building_System.register_structure(grid_pos, structure)
	
	assert_eq(Building_System.structures[grid_pos], structure, "Structure should be registered at grid position")
	assert_eq(Building_System.structure_count, 1, "Structure count should be 1")

func test_unregister_structure():
	# REQ-007.4, REQ-015.3: Unregister structure from dictionary
	var structure = create_mock_structure(Vector2i(10, 10), Vector2i(1, 1))
	var grid_pos = Vector2i(10, 10)
	Building_System.register_structure(grid_pos, structure)
	
	Building_System.unregister_structure(grid_pos)
	
	assert_false(Building_System.structures.has(grid_pos), "Structure should be removed from dictionary")
	assert_eq(Building_System.structure_count, 0, "Structure count should be 0")

func test_get_structure_at_position():
	# Test getting structure at position
	var structure = create_mock_structure(Vector2i(10, 10), Vector2i(1, 1))
	var grid_pos = Vector2i(10, 10)
	Building_System.register_structure(grid_pos, structure)
	
	var result = Building_System.get_structure_at_position(grid_pos)
	
	assert_eq(result, structure, "Should return structure at position")

func test_get_structure_at_empty_position():
	# Test getting structure at empty position
	var grid_pos = Vector2i(10, 10)
	
	var result = Building_System.get_structure_at_position(grid_pos)
	
	assert_null(result, "Should return null for empty position")

# ===== Structure Selection =====

func test_select_structure():
	# REQ-002.1: Select structure type
	Building_System.select_structure("wall")
	
	assert_eq(Building_System.selected_structure_type, "wall", "Selected structure type should be 'wall'")

func test_select_invalid_structure():
	# Test selecting invalid structure type
	Building_System.select_structure("invalid_type")
	
	assert_eq(Building_System.selected_structure_type, "", "Invalid structure type should not be selected")

func test_deselect_structure():
	# REQ-006.1: Deselect structure
	Building_System.selected_structure_type = "wall"
	
	Building_System.deselect_structure()
	
	assert_eq(Building_System.selected_structure_type, "", "Structure type should be deselected")

# ===== Structure Data Loading =====

func test_structure_data_loaded():
	# REQ-019.1: Structure data should be loaded from JSON
	assert_true(Building_System.structure_data.has("wall"), "Structure data should contain 'wall'")
	assert_true(Building_System.structure_data.has("turret"), "Structure data should contain 'turret'")
	assert_true(Building_System.structure_data.has("crafting_station"), "Structure data should contain 'crafting_station'")
	assert_true(Building_System.structure_data.has("storage_chest"), "Structure data should contain 'storage_chest'")

func test_structure_data_schema_wall():
	# REQ-019.2: Validate structure data schema for wall
	var wall_data = Building_System.structure_data["wall"]
	
	assert_true(wall_data.has("name"), "Wall data should have 'name' field")
	assert_true(wall_data.has("max_health"), "Wall data should have 'max_health' field")
	assert_true(wall_data.has("costs"), "Wall data should have 'costs' field")
	assert_true(wall_data.has("grid_size"), "Wall data should have 'grid_size' field")
	assert_true(wall_data.has("scene_path"), "Wall data should have 'scene_path' field")
	
	assert_eq(wall_data["name"], "Wall", "Wall name should be 'Wall'")
	assert_eq(wall_data["max_health"], 100.0, "Wall max_health should be 100")
	assert_eq(wall_data["costs"]["wood"], 10.0, "Wall should cost 10 wood")
	assert_eq(wall_data["grid_size"]["x"], 1.0, "Wall grid_size.x should be 1")
	assert_eq(wall_data["grid_size"]["y"], 1.0, "Wall grid_size.y should be 1")

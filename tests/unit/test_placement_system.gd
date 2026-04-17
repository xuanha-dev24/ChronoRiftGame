# test_placement_system.gd
# Unit tests for placement system functionality (Phase 5: Tasks 11.1-11.8)
# Tests placement preview, structure placement, and cancellation
extends GutTest

func before_each():
	# Reset Building_System state
	Building_System.build_mode_active = false
	Building_System.selected_structure_type = ""
	Building_System.structures.clear()
	Building_System.structure_count = 0
	Building_System.spatial_grid.clear()
	
	# Clean up any existing placement preview
	if Building_System.placement_preview != null:
		Building_System.placement_preview.queue_free()
		Building_System.placement_preview = null

# ===== Task 11.2: Placement Preview Position Updates =====

func test_preview_position_snapping():
	# REQ-003.2: Preview should snap to grid
	var mouse_pos = Vector2(123, 456)
	var grid_pos = Building_System.world_to_grid(mouse_pos)
	var snapped_pos = Building_System.grid_to_world(grid_pos)
	
	# Verify snapping to grid center
	assert_eq(snapped_pos.x, float(int(123 / 16) * 16 + 8), "X should snap to grid center")
	assert_eq(snapped_pos.y, float(int(456 / 16) * 16 + 8), "Y should snap to grid center")

# ===== Task 11.3: Structure Selection =====

func test_select_structure_sets_type():
	# REQ-002.1: Select structure type
	Building_System.select_structure("wall")
	
	assert_eq(Building_System.selected_structure_type, "wall", "Selected structure type should be 'wall'")

func test_deselect_structure_clears_type():
	# REQ-006.1: Deselect structure
	Building_System.selected_structure_type = "wall"
	
	Building_System.deselect_structure()
	
	assert_eq(Building_System.selected_structure_type, "", "Structure type should be deselected")

# ===== Task 11.5: Structure Placement =====

func test_place_structure_validates_placement():
	# REQ-005.1: Placement should validate before placing
	Building_System.selected_structure_type = "wall"
	
	# Try to place out of bounds
	var result = Building_System.place_structure(Vector2i(30, 10))
	
	assert_false(result, "Should not place structure out of bounds")

func test_place_structure_checks_resources():
	# REQ-004.4, REQ-005.2: Should check and deduct resources
	Building_System.selected_structure_type = "wall"
	
	# Ensure player has no wood
	ResourceManager.resources["wood"] = 0
	
	# Try to place structure
	var result = Building_System.place_structure(Vector2i(10, 10))
	
	assert_false(result, "Should not place structure without sufficient resources")

# ===== Task 11.8: Structure Cancellation =====

func test_deselect_structure_clears_preview():
	# REQ-006.1, REQ-006.2: Deselect should clear preview
	Building_System.selected_structure_type = "wall"
	
	# Create a mock preview
	var mock_preview = Node2D.new()
	add_child_autofree(mock_preview)
	Building_System.placement_preview = mock_preview
	
	Building_System.deselect_structure()
	
	assert_eq(Building_System.selected_structure_type, "", "Structure type should be cleared")
	assert_null(Building_System.placement_preview, "Preview should be cleared")

# ===== Multi-cell Structure Registry =====

func test_register_multi_cell_structure():
	# REQ-005.4: Multi-cell structures should register all cells
	Building_System.structures.clear()
	Building_System.structure_count = 0
	
	# Create a mock 2x2 structure
	var mock_structure = Area2D.new()
	mock_structure.set_meta("grid_position", Vector2i(5, 5))
	mock_structure.set_meta("grid_size", Vector2i(2, 2))
	add_child_autofree(mock_structure)
	Building_System.register_structure(Vector2i(5, 5), mock_structure)
	
	# Verify all cells are registered
	assert_true(Building_System.structures.has(Vector2i(5, 5)), "Cell (5,5) should be registered")
	assert_true(Building_System.structures.has(Vector2i(6, 5)), "Cell (6,5) should be registered")
	assert_true(Building_System.structures.has(Vector2i(5, 6)), "Cell (5,6) should be registered")
	assert_true(Building_System.structures.has(Vector2i(6, 6)), "Cell (6,6) should be registered")
	assert_eq(Building_System.structure_count, 1, "Structure count should be 1 (not 4)")
	
	# Cleanup
	mock_structure.queue_free()

func test_unregister_multi_cell_structure():
	# REQ-007.4: Multi-cell structures should unregister all cells
	Building_System.structures.clear()
	Building_System.structure_count = 0
	
	# Create a mock 2x2 structure
	var mock_structure = Area2D.new()
	mock_structure.set_meta("grid_position", Vector2i(5, 5))
	mock_structure.set_meta("grid_size", Vector2i(2, 2))
	add_child_autofree(mock_structure)
	Building_System.register_structure(Vector2i(5, 5), mock_structure)
	
	# Unregister structure
	Building_System.unregister_structure(Vector2i(5, 5))
	
	# Verify all cells are unregistered
	assert_false(Building_System.structures.has(Vector2i(5, 5)), "Cell (5,5) should be unregistered")
	assert_false(Building_System.structures.has(Vector2i(6, 5)), "Cell (6,5) should be unregistered")
	assert_false(Building_System.structures.has(Vector2i(5, 6)), "Cell (5,6) should be unregistered")
	assert_false(Building_System.structures.has(Vector2i(6, 6)), "Cell (6,6) should be unregistered")
	assert_eq(Building_System.structure_count, 0, "Structure count should be 0")
	
	# Cleanup
	mock_structure.queue_free()


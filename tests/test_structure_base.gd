extends GutTest

## Unit tests for Structure base class
## Tests health system, visual feedback, and save/load functionality

var wall_scene = preload("res://scenes/structures/Wall.tscn")
var wall: Structure

func before_each():
	# Instantiate a wall for testing
	wall = wall_scene.instantiate()
	add_child_autofree(wall)
	wall.initialize(Vector2i(10, 10))

func after_each():
	wall = null

# ===== Task 3.1: Structure Base Class =====

func test_structure_initializes_with_max_health():
	# REQ-007.1: Structure initializes with max health
	assert_eq(wall.current_health, wall.max_health, "Structure should start with max health")
	assert_false(wall.is_destroyed, "Structure should not be destroyed initially")

func test_structure_sets_collision_layers():
	# REQ-018.1, REQ-018.2: Collision layer 4, mask 3
	assert_eq(wall.collision_layer, 4, "Structure should be on collision layer 4")
	assert_eq(wall.collision_mask, 3, "Structure should have collision mask 3")

func test_structure_added_to_group():
	# Structure should be added to "structures" group
	assert_true(wall.is_in_group("structures"), "Structure should be in 'structures' group")

func test_structure_grid_position_set():
	# Structure should store grid position
	assert_eq(wall.grid_position, Vector2i(10, 10), "Grid position should be set correctly")

# ===== Task 3.2: Health System Methods =====

func test_structure_takes_damage():
	# REQ-007.2: Structure takes damage correctly
	var initial_health = wall.current_health
	wall.take_damage(25)
	
	assert_eq(wall.current_health, initial_health - 25, "Health should decrease by damage amount")
	assert_false(wall.is_destroyed, "Structure should not be destroyed yet")

func test_structure_health_cannot_go_negative():
	# Health should be clamped to 0
	wall.take_damage(wall.max_health + 50)
	
	assert_eq(wall.current_health, 0, "Health should be clamped to 0")

func test_structure_destroyed_at_zero_health():
	# REQ-007.3: Structure destroyed when health reaches 0
	wall.take_damage(wall.max_health)
	
	await wait_physics_frames(1)
	if is_instance_valid(wall):
		assert_true(wall.is_destroyed, "Structure should be destroyed at 0 health")
	else:
		pass_test("Structure was freed (destroyed)")

func test_structure_cannot_take_damage_when_destroyed():
	# Destroyed structures should not take further damage
	wall.take_damage(wall.max_health)
	await wait_physics_frames(1)
	
	if not is_instance_valid(wall):
		pass_test("Structure was freed (destroyed)")
		return
	
	var health_after_destroy = wall.current_health
	wall.take_damage(10)
	
	assert_eq(wall.current_health, health_after_destroy, "Destroyed structure should not take damage")

# ===== Task 3.5: Visual Feedback System =====

func test_health_bar_updates_on_damage():
	# REQ-007.6: Health bar displays current health percentage
	var initial_fill_width = wall.health_bar_fill.size.x
	wall.take_damage(wall.max_health / 2)
	
	await wait_physics_frames(1)
	var new_fill_width = wall.health_bar_fill.size.x
	
	assert_lt(new_fill_width, initial_fill_width, "Health bar should shrink when damaged")
	assert_almost_eq(new_fill_width, wall.health_bar.size.x * 0.5, 0.1, "Health bar should be 50% full")

func test_visual_feedback_white_above_66_percent():
	# REQ-016.1: White color above 66% health
	wall.current_health = int(wall.max_health * 0.7)
	wall.update_visual_feedback()
	
	assert_eq(wall.visual.modulate, Color(1, 1, 1), "Should be white above 66% health")

func test_visual_feedback_yellow_between_33_and_66_percent():
	# REQ-016.2: Yellow color between 33% and 66% health
	wall.current_health = int(wall.max_health * 0.5)
	wall.update_visual_feedback()
	
	assert_eq(wall.visual.modulate, Color(1, 1, 0), "Should be yellow between 33% and 66% health")

func test_visual_feedback_red_below_33_percent():
	# REQ-016.3: Red color below 33% health
	wall.current_health = int(wall.max_health * 0.2)
	wall.update_visual_feedback()
	
	assert_eq(wall.visual.modulate, Color(1, 0, 0), "Should be red below 33% health")

# ===== Task 3.7: Save/Load Interface =====

func test_get_save_data_contains_required_fields():
	# REQ-013.1: Save data contains all required fields
	var save_data = wall.get_save_data()
	
	assert_true(save_data.has("type"), "Save data should have 'type' field")
	assert_true(save_data.has("grid_position"), "Save data should have 'grid_position' field")
	assert_true(save_data.has("current_health"), "Save data should have 'current_health' field")
	assert_true(save_data.has("rotation"), "Save data should have 'rotation' field")

func test_get_save_data_values_correct():
	# Save data should contain correct values
	wall.current_health = 75
	wall.rotation_degrees = 90
	
	var save_data = wall.get_save_data()
	
	assert_eq(save_data["type"], "wall", "Type should be 'wall'")
	assert_eq(save_data["grid_position"]["x"], 10, "Grid X should be 10")
	assert_eq(save_data["grid_position"]["y"], 10, "Grid Y should be 10")
	assert_eq(save_data["current_health"], 75, "Current health should be 75")
	assert_eq(save_data["rotation"], 90.0, "Rotation should be 90")

func test_load_from_data_restores_state():
	# REQ-013.3: Load from data restores structure state
	var save_data = {
		"type": "wall",
		"grid_position": {"x": 15, "y": 20},
		"current_health": 60,
		"rotation": 180
	}
	
	wall.load_from_data(save_data)
	
	assert_eq(wall.grid_position, Vector2i(15, 20), "Grid position should be restored")
	assert_eq(wall.current_health, 60, "Current health should be restored")
	assert_eq(wall.rotation_degrees, 180.0, "Rotation should be restored")

func test_save_load_round_trip():
	# Save and load should preserve state
	wall.current_health = 80
	wall.rotation_degrees = 45
	
	var save_data = wall.get_save_data()
	
	# Create new wall and load data
	var new_wall = wall_scene.instantiate()
	add_child_autofree(new_wall)
	new_wall.initialize(Vector2i(0, 0))
	new_wall.load_from_data(save_data)
	
	assert_eq(new_wall.current_health, 80, "Health should match after round trip")
	assert_eq(new_wall.rotation_degrees, 45.0, "Rotation should match after round trip")
	assert_eq(new_wall.grid_position, Vector2i(10, 10), "Grid position should match after round trip")

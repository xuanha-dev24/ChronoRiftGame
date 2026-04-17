extends GutTest

# Unit tests for HarvestableObject resource integration (Task 5.1)
# Tests complete_gathering() method and ResourceManager integration

var harvestable_object: HarvestableObject
var visual: ColorRect
var interaction_indicator: ColorRect
var progress_bar: ColorRect
var progress_fill: ColorRect
var collision_shape: CollisionShape2D

func before_each():
	# Create a minimal harvestable object scene for testing
	harvestable_object = HarvestableObject.new()
	
	# Create required child nodes
	visual = ColorRect.new()
	visual.name = "Visual"
	harvestable_object.add_child(visual)
	
	interaction_indicator = ColorRect.new()
	interaction_indicator.name = "InteractionIndicator"
	harvestable_object.add_child(interaction_indicator)
	
	progress_bar = ColorRect.new()
	progress_bar.name = "ProgressBar"
	progress_bar.size = Vector2(40, 6)
	harvestable_object.add_child(progress_bar)
	
	progress_fill = ColorRect.new()
	progress_fill.name = "Fill"
	progress_bar.add_child(progress_fill)
	
	collision_shape = CollisionShape2D.new()
	collision_shape.name = "CollisionShape2D"
	harvestable_object.add_child(collision_shape)
	
	# Set test colors
	harvestable_object.normal_color = Color.GREEN
	harvestable_object.interactable_color = Color.YELLOW
	harvestable_object.depleted_color = Color.GRAY
	
	# Set resource configuration
	harvestable_object.min_resource_amount = 1
	harvestable_object.max_resource_amount = 3
	
	add_child_autofree(harvestable_object)

# ===== Task 5.1: complete_gathering() Method =====

func test_complete_gathering_generates_random_amount():
	# REQ-004.1, REQ-004.2, REQ-004.3: Generate random amount between min and max
	harvestable_object.resource_type = "wood"
	harvestable_object.min_resource_amount = 1
	harvestable_object.max_resource_amount = 3
	
	# Get initial wood amount
	var initial_wood = ResourceManager.get_resource("wood")
	
	# Complete gathering
	harvestable_object.complete_gathering()
	
	# Check that wood increased by 1-3
	var final_wood = ResourceManager.get_resource("wood")
	var amount_gained = final_wood - initial_wood
	
	assert_between(amount_gained, 1, 3,
		"Should gain between 1 and 3 wood")

func test_complete_gathering_adds_wood_resource():
	# REQ-004.1: Tree adds wood to ResourceManager
	harvestable_object.resource_type = "wood"
	
	var initial_wood = ResourceManager.get_resource("wood")
	harvestable_object.complete_gathering()
	var final_wood = ResourceManager.get_resource("wood")
	
	assert_gt(final_wood, initial_wood,
		"Wood resource should increase after gathering")

func test_complete_gathering_adds_stone_resource():
	# REQ-004.2: Rock adds stone to ResourceManager
	harvestable_object.resource_type = "stone"
	
	var initial_stone = ResourceManager.get_resource("stone")
	harvestable_object.complete_gathering()
	var final_stone = ResourceManager.get_resource("stone")
	
	assert_gt(final_stone, initial_stone,
		"Stone resource should increase after gathering")

func test_complete_gathering_adds_meat_resource():
	# REQ-004.3: Bush adds meat to ResourceManager
	harvestable_object.resource_type = "meat"
	
	var initial_meat = ResourceManager.get_resource("meat")
	harvestable_object.complete_gathering()
	var final_meat = ResourceManager.get_resource("meat")
	
	assert_gt(final_meat, initial_meat,
		"Meat resource should increase after gathering")

func test_complete_gathering_transitions_to_depleted():
	# REQ-005.1: Transition to DEPLETED state after gathering
	harvestable_object.resource_type = "wood"
	harvestable_object.current_state = HarvestableObject.State.GATHERING
	
	harvestable_object.complete_gathering()
	
	assert_eq(harvestable_object.current_state, HarvestableObject.State.DEPLETED,
		"Should transition to DEPLETED state after gathering")

func test_complete_gathering_hides_progress_bar():
	# REQ-003.6: Hide progress bar after gathering completes
	harvestable_object.resource_type = "wood"
	progress_bar.visible = true
	
	harvestable_object.complete_gathering()
	
	assert_false(progress_bar.visible,
		"Progress bar should be hidden after gathering completes")

func test_complete_gathering_resets_respawn_timer():
	# REQ-005.1: Reset respawn timer to 0
	harvestable_object.resource_type = "wood"
	harvestable_object.respawn_timer = 10.0  # Set to non-zero value
	
	harvestable_object.complete_gathering()
	
	assert_eq(harvestable_object.respawn_timer, 0.0,
		"Respawn timer should be reset to 0")

func test_complete_gathering_validates_resource_type():
	# REQ-004.1, REQ-004.2, REQ-004.3: Validate resource type
	harvestable_object.resource_type = "invalid_type"
	
	# Should log error but not crash
	harvestable_object.complete_gathering()
	
	# Should still transition to DEPLETED even with invalid type
	assert_eq(harvestable_object.current_state, HarvestableObject.State.DEPLETED,
		"Should transition to DEPLETED even with invalid resource type")

func test_complete_gathering_skips_invalid_resource_addition():
	# REQ-004.1, REQ-004.2, REQ-004.3: Skip ResourceManager call for invalid types
	harvestable_object.resource_type = "invalid_type"
	
	# Get all resource amounts before
	var initial_resources = ResourceManager.get_all_resources()
	
	harvestable_object.complete_gathering()
	
	# Get all resource amounts after
	var final_resources = ResourceManager.get_all_resources()
	
	# All resources should remain unchanged
	assert_eq(initial_resources, final_resources,
		"No resources should change with invalid resource type")

# ===== Integration Tests =====

func test_resource_changed_signal_emitted():
	# REQ-004.4: EventBus.resource_changed signal emitted
	harvestable_object.resource_type = "wood"
	
	# Watch for signal emission
	watch_signals(EventBus)
	
	harvestable_object.complete_gathering()
	
	# Verify signal was emitted
	assert_signal_emitted(EventBus, "resource_changed",
		"EventBus.resource_changed should be emitted")

func test_full_gathering_cycle_with_completion():
	# Test complete gathering cycle from NORMAL to DEPLETED
	var player = Node2D.new()
	player.add_to_group("player")
	add_child_autofree(player)
	
	harvestable_object.resource_type = "wood"
	var initial_wood = ResourceManager.get_resource("wood")
	
	# Start in NORMAL state
	assert_eq(harvestable_object.current_state, HarvestableObject.State.NORMAL)
	
	# Player enters range
	harvestable_object._on_body_entered(player)
	assert_eq(harvestable_object.current_state, HarvestableObject.State.INTERACTABLE)
	
	# Player presses interact
	harvestable_object.start_gathering()
	assert_eq(harvestable_object.current_state, HarvestableObject.State.GATHERING)
	assert_true(progress_bar.visible)
	
	# Gathering completes
	harvestable_object.player_in_range = true
	harvestable_object.gathering_time = 1.0
	harvestable_object.update_gathering(1.0)
	
	# Verify completion
	assert_eq(harvestable_object.current_state, HarvestableObject.State.DEPLETED,
		"Should be in DEPLETED state after gathering completes")
	assert_false(progress_bar.visible,
		"Progress bar should be hidden")
	assert_eq(harvestable_object.respawn_timer, 0.0,
		"Respawn timer should be reset")
	
	# Verify resource was added
	var final_wood = ResourceManager.get_resource("wood")
	assert_gt(final_wood, initial_wood,
		"Wood should have increased")

func test_depleted_visual_state_after_gathering():
	# REQ-005.2: Depleted objects have reduced opacity
	harvestable_object.resource_type = "wood"
	
	harvestable_object.complete_gathering()
	
	# Check visual state matches DEPLETED
	assert_eq(visual.color, harvestable_object.depleted_color,
		"Visual color should be depleted color")
	assert_eq(visual.modulate.a, 0.5,
		"Visual opacity should be 0.5 in depleted state")
	assert_false(interaction_indicator.visible,
		"Interaction indicator should be hidden")
	assert_true(collision_shape.disabled,
		"Collision shape should be disabled in depleted state")

func test_multiple_gathering_cycles():
	# Test that gathering can be repeated after respawn
	harvestable_object.resource_type = "wood"
	var initial_wood = ResourceManager.get_resource("wood")
	
	# First gathering cycle
	harvestable_object.complete_gathering()
	var wood_after_first = ResourceManager.get_resource("wood")
	assert_gt(wood_after_first, initial_wood,
		"Wood should increase after first gathering")
	
	# Simulate respawn (this will be implemented in Task 6.2)
	# For now, manually reset state
	harvestable_object.current_state = HarvestableObject.State.NORMAL
	
	# Second gathering cycle
	harvestable_object.complete_gathering()
	var wood_after_second = ResourceManager.get_resource("wood")
	assert_gt(wood_after_second, wood_after_first,
		"Wood should increase again after second gathering")

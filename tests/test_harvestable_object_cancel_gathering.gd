extends GutTest

# Unit tests for HarvestableObject cancel_gathering() method
# Tests Task 3.3: Cancel gathering and reset progress

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
	
	add_child_autofree(harvestable_object)

func test_cancel_gathering_transitions_to_normal_state():
	# REQ-003.5: Cancel gathering should transition to NORMAL state
	harvestable_object.current_state = HarvestableObject.State.GATHERING
	harvestable_object.cancel_gathering()
	
	assert_eq(harvestable_object.current_state, HarvestableObject.State.NORMAL, 
		"cancel_gathering() should transition to NORMAL state")

func test_cancel_gathering_resets_gathering_progress():
	# REQ-003.5: Cancel gathering should reset progress to zero
	harvestable_object.gathering_progress = 0.5
	harvestable_object.cancel_gathering()
	
	assert_eq(harvestable_object.gathering_progress, 0.0, 
		"cancel_gathering() should reset gathering_progress to 0.0")

func test_cancel_gathering_resets_gathering_timer():
	# REQ-003.5: Cancel gathering should reset timer to zero
	harvestable_object.gathering_timer = 1.5
	harvestable_object.cancel_gathering()
	
	assert_eq(harvestable_object.gathering_timer, 0.0, 
		"cancel_gathering() should reset gathering_timer to 0.0")

func test_cancel_gathering_hides_progress_bar():
	# REQ-006.4: Progress indicator should disappear when gathering is cancelled
	progress_bar.visible = true
	harvestable_object.cancel_gathering()
	
	assert_false(progress_bar.visible, 
		"cancel_gathering() should hide progress_bar")

func test_cancel_gathering_full_reset():
	# Test complete reset of all gathering-related state
	harvestable_object.current_state = HarvestableObject.State.GATHERING
	harvestable_object.gathering_progress = 0.75
	harvestable_object.gathering_timer = 2.0
	progress_bar.visible = true
	
	harvestable_object.cancel_gathering()
	
	assert_eq(harvestable_object.current_state, HarvestableObject.State.NORMAL, 
		"State should be NORMAL")
	assert_eq(harvestable_object.gathering_progress, 0.0, 
		"Progress should be 0.0")
	assert_eq(harvestable_object.gathering_timer, 0.0, 
		"Timer should be 0.0")
	assert_false(progress_bar.visible, 
		"Progress bar should be hidden")

func test_cancel_gathering_updates_visual_state():
	# REQ-008.4: Visual effect should stop immediately when cancelled
	harvestable_object.current_state = HarvestableObject.State.GATHERING
	harvestable_object.update_visual_state()
	
	# Verify GATHERING state visuals
	assert_eq(visual.color, Color.YELLOW, "Should have GATHERING color before cancel")
	
	harvestable_object.cancel_gathering()
	
	# Verify NORMAL state visuals after cancel
	assert_eq(visual.color, Color.GREEN, "Should have NORMAL color after cancel")
	assert_false(interaction_indicator.visible, "Indicator should be hidden after cancel")

func test_cancel_gathering_from_different_states():
	# Test that cancel_gathering works regardless of current state
	var states = [
		HarvestableObject.State.NORMAL,
		HarvestableObject.State.INTERACTABLE,
		HarvestableObject.State.GATHERING,
		HarvestableObject.State.DEPLETED
	]
	
	for state in states:
		harvestable_object.current_state = state
		harvestable_object.gathering_progress = 0.5
		harvestable_object.gathering_timer = 1.0
		progress_bar.visible = true
		
		harvestable_object.cancel_gathering()
		
		assert_eq(harvestable_object.current_state, HarvestableObject.State.NORMAL, 
			"Should transition to NORMAL from %s state" % state)
		assert_eq(harvestable_object.gathering_progress, 0.0, 
			"Should reset progress from %s state" % state)
		assert_eq(harvestable_object.gathering_timer, 0.0, 
			"Should reset timer from %s state" % state)
		assert_false(progress_bar.visible, 
			"Should hide progress bar from %s state" % state)

func test_cancel_gathering_called_when_player_exits_range():
	# REQ-003.5: Gathering should cancel when player moves outside range
	# This test verifies the integration with update_gathering()
	harvestable_object.current_state = HarvestableObject.State.GATHERING
	harvestable_object.gathering_progress = 0.5
	harvestable_object.gathering_timer = 1.0
	harvestable_object.player_in_range = false
	progress_bar.visible = true
	
	# Simulate one frame of gathering update with player out of range
	harvestable_object.update_gathering(0.016)
	
	# Verify cancel_gathering was called (state reset to NORMAL)
	assert_eq(harvestable_object.current_state, HarvestableObject.State.NORMAL, 
		"update_gathering() should call cancel_gathering() when player_in_range is false")
	assert_eq(harvestable_object.gathering_progress, 0.0, 
		"Progress should be reset when player exits range")
	assert_false(progress_bar.visible, 
		"Progress bar should be hidden when player exits range")

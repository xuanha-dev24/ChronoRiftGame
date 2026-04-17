extends GutTest

# Unit tests for HarvestableObject update_visual_state() method
# Tests Task 2.2: Visual state updates based on object state

var harvestable_object: HarvestableObject
var visual: ColorRect
var interaction_indicator: ColorRect
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
	
	var progress_bar = ColorRect.new()
	progress_bar.name = "ProgressBar"
	harvestable_object.add_child(progress_bar)
	
	var progress_fill = ColorRect.new()
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

func test_normal_state_visual_updates():
	# Test visual updates in NORMAL state
	harvestable_object.current_state = HarvestableObject.State.NORMAL
	harvestable_object.update_visual_state()
	
	assert_eq(visual.color, Color.GREEN, "Visual color should be normal_color (GREEN) in NORMAL state")
	assert_eq(visual.modulate.a, 1.0, "Visual alpha should be 1.0 in NORMAL state")
	assert_false(interaction_indicator.visible, "Interaction indicator should be hidden in NORMAL state")
	assert_false(collision_shape.disabled, "Collision shape should be enabled in NORMAL state")

func test_interactable_state_visual_updates():
	# Test visual updates in INTERACTABLE state
	harvestable_object.current_state = HarvestableObject.State.INTERACTABLE
	harvestable_object.update_visual_state()
	
	assert_eq(visual.color, Color.YELLOW, "Visual color should be interactable_color (YELLOW) in INTERACTABLE state")
	assert_eq(visual.modulate.a, 1.0, "Visual alpha should be 1.0 in INTERACTABLE state")
	assert_true(interaction_indicator.visible, "Interaction indicator should be visible in INTERACTABLE state")
	assert_false(collision_shape.disabled, "Collision shape should be enabled in INTERACTABLE state")

func test_gathering_state_visual_updates():
	# Test visual updates in GATHERING state
	harvestable_object.current_state = HarvestableObject.State.GATHERING
	harvestable_object.update_visual_state()
	
	assert_eq(visual.color, Color.YELLOW, "Visual color should be interactable_color (YELLOW) in GATHERING state")
	assert_eq(visual.modulate.a, 1.0, "Visual alpha should be 1.0 in GATHERING state")
	assert_false(interaction_indicator.visible, "Interaction indicator should be hidden in GATHERING state")
	assert_false(collision_shape.disabled, "Collision shape should be enabled in GATHERING state")

func test_depleted_state_visual_updates():
	# Test visual updates in DEPLETED state
	harvestable_object.current_state = HarvestableObject.State.DEPLETED
	harvestable_object.update_visual_state()
	
	assert_eq(visual.color, Color.GRAY, "Visual color should be depleted_color (GRAY) in DEPLETED state")
	assert_eq(visual.modulate.a, 0.5, "Visual alpha should be 0.5 in DEPLETED state")
	assert_false(interaction_indicator.visible, "Interaction indicator should be hidden in DEPLETED state")
	assert_true(collision_shape.disabled, "Collision shape should be disabled in DEPLETED state")

func test_interaction_indicator_only_visible_in_interactable():
	# Test that interaction indicator is only visible in INTERACTABLE state
	var states = [
		HarvestableObject.State.NORMAL,
		HarvestableObject.State.INTERACTABLE,
		HarvestableObject.State.GATHERING,
		HarvestableObject.State.DEPLETED
	]
	
	for state in states:
		harvestable_object.current_state = state
		harvestable_object.update_visual_state()
		
		if state == HarvestableObject.State.INTERACTABLE:
			assert_true(interaction_indicator.visible, "Indicator should be visible in INTERACTABLE state")
		else:
			assert_false(interaction_indicator.visible, "Indicator should be hidden in %s state" % state)

func test_collision_disabled_only_in_depleted():
	# Test that collision is only disabled in DEPLETED state
	var states = [
		HarvestableObject.State.NORMAL,
		HarvestableObject.State.INTERACTABLE,
		HarvestableObject.State.GATHERING,
		HarvestableObject.State.DEPLETED
	]
	
	for state in states:
		harvestable_object.current_state = state
		harvestable_object.update_visual_state()
		
		if state == HarvestableObject.State.DEPLETED:
			assert_true(collision_shape.disabled, "Collision should be disabled in DEPLETED state")
		else:
			assert_false(collision_shape.disabled, "Collision should be enabled in %s state" % state)

func test_alpha_reduced_only_in_depleted():
	# Test that alpha is reduced (0.5) only in DEPLETED state
	var states = [
		HarvestableObject.State.NORMAL,
		HarvestableObject.State.INTERACTABLE,
		HarvestableObject.State.GATHERING,
		HarvestableObject.State.DEPLETED
	]
	
	for state in states:
		harvestable_object.current_state = state
		harvestable_object.update_visual_state()
		
		if state == HarvestableObject.State.DEPLETED:
			assert_eq(visual.modulate.a, 0.5, "Alpha should be 0.5 in DEPLETED state")
		else:
			assert_eq(visual.modulate.a, 1.0, "Alpha should be 1.0 in %s state" % state)

func test_transition_to_state_calls_update_visual_state():
	# Test that transition_to_state properly updates visuals
	harvestable_object.current_state = HarvestableObject.State.NORMAL
	harvestable_object.update_visual_state()
	
	# Verify initial state
	assert_eq(visual.color, Color.GREEN, "Initial color should be GREEN")
	assert_false(interaction_indicator.visible, "Initial indicator should be hidden")
	
	# Transition to INTERACTABLE
	harvestable_object.transition_to_state(HarvestableObject.State.INTERACTABLE)
	
	# Verify state changed and visuals updated
	assert_eq(harvestable_object.current_state, HarvestableObject.State.INTERACTABLE, "State should be INTERACTABLE")
	assert_eq(visual.color, Color.YELLOW, "Color should update to YELLOW")
	assert_true(interaction_indicator.visible, "Indicator should be visible")

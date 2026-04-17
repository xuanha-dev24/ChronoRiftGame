extends GutTest

# Unit tests for HarvestableObject state machine (Tasks 1-3)
# Tests state transitions and gathering mechanics

var harvestable_object: HarvestableObject
var visual: ColorRect
var interaction_indicator: ColorRect
var progress_bar: ColorRect
var progress_fill: ColorRect
var collision_shape: CollisionShape2D
var player: Node2D

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
	
	# Create a mock player
	player = Node2D.new()
	player.add_to_group("player")
	
	# Set test colors
	harvestable_object.normal_color = Color.GREEN
	harvestable_object.interactable_color = Color.YELLOW
	harvestable_object.depleted_color = Color.GRAY
	
	# Set gathering time to a known value for testing
	harvestable_object.gathering_time = 2.0
	
	add_child_autofree(harvestable_object)
	add_child_autofree(player)

# ===== Task 1: State Machine Initialization =====

func test_initial_state_is_normal():
	# REQ-002.1: Object should start in NORMAL state
	assert_eq(harvestable_object.current_state, HarvestableObject.State.NORMAL,
		"Initial state should be NORMAL")

func test_gathering_time_randomized_on_ready():
	# REQ-003.2: Gathering time should be randomized between 1-3 seconds
	# Note: This is set in _ready(), so we need to trigger it
	harvestable_object._ready()
	assert_between(harvestable_object.gathering_time, 1.0, 3.0,
		"Gathering time should be between 1.0 and 3.0 seconds")

func test_respawn_time_randomized_on_ready():
	# REQ-005.3: Respawn time should be randomized between 30-60 seconds
	harvestable_object._ready()
	assert_between(harvestable_object.respawn_time, 30.0, 60.0,
		"Respawn time should be between 30.0 and 60.0 seconds")

# ===== Task 2: State Transitions =====

func test_normal_to_interactable_on_player_enter():
	# REQ-002.1: Transition to INTERACTABLE when player enters range
	harvestable_object.current_state = HarvestableObject.State.NORMAL
	harvestable_object._on_body_entered(player)
	
	assert_eq(harvestable_object.current_state, HarvestableObject.State.INTERACTABLE,
		"Should transition to INTERACTABLE when player enters")
	assert_true(harvestable_object.player_in_range,
		"player_in_range should be true")
	assert_eq(harvestable_object.player_ref, player,
		"player_ref should be set to player")

func test_interactable_to_normal_on_player_exit():
	# REQ-002.3: Transition to NORMAL when player exits range
	harvestable_object.current_state = HarvestableObject.State.INTERACTABLE
	harvestable_object.player_in_range = true
	harvestable_object.player_ref = player
	
	harvestable_object._on_body_exited(player)
	
	assert_eq(harvestable_object.current_state, HarvestableObject.State.NORMAL,
		"Should transition to NORMAL when player exits")
	assert_false(harvestable_object.player_in_range,
		"player_in_range should be false")
	assert_null(harvestable_object.player_ref,
		"player_ref should be null")

func test_gathering_cancelled_on_player_exit():
	# REQ-003.5: Cancel gathering when player exits range
	harvestable_object.current_state = HarvestableObject.State.GATHERING
	harvestable_object.player_in_range = true
	harvestable_object.player_ref = player
	harvestable_object.gathering_progress = 0.5
	progress_bar.visible = true
	
	harvestable_object._on_body_exited(player)
	
	assert_eq(harvestable_object.current_state, HarvestableObject.State.NORMAL,
		"Should transition to NORMAL when player exits during gathering")
	assert_eq(harvestable_object.gathering_progress, 0.0,
		"Gathering progress should be reset")
	assert_false(progress_bar.visible,
		"Progress bar should be hidden")

func test_non_player_bodies_ignored():
	# REQ-002.1: Only respond to player bodies
	var non_player = Node2D.new()
	add_child_autofree(non_player)
	
	harvestable_object.current_state = HarvestableObject.State.NORMAL
	harvestable_object._on_body_entered(non_player)
	
	assert_eq(harvestable_object.current_state, HarvestableObject.State.NORMAL,
		"Should ignore non-player bodies")
	assert_false(harvestable_object.player_in_range,
		"player_in_range should remain false")

# ===== Task 3: Gathering Mechanics =====

func test_start_gathering_transitions_to_gathering_state():
	# REQ-003.1: Start gathering when interact pressed
	harvestable_object.current_state = HarvestableObject.State.INTERACTABLE
	harvestable_object.start_gathering()
	
	assert_eq(harvestable_object.current_state, HarvestableObject.State.GATHERING,
		"Should transition to GATHERING state")
	assert_eq(harvestable_object.gathering_progress, 0.0,
		"Gathering progress should start at 0.0")
	assert_eq(harvestable_object.gathering_timer, 0.0,
		"Gathering timer should start at 0.0")
	assert_true(progress_bar.visible,
		"Progress bar should be visible")

func test_gathering_progress_updates_over_time():
	# REQ-003.2, REQ-006.2: Progress updates smoothly over time
	harvestable_object.current_state = HarvestableObject.State.GATHERING
	harvestable_object.gathering_time = 2.0
	harvestable_object.gathering_progress = 0.0
	harvestable_object.gathering_timer = 0.0
	harvestable_object.player_in_range = true
	
	# Simulate 1 second of gathering (50% progress)
	harvestable_object.update_gathering(1.0)
	
	assert_almost_eq(harvestable_object.gathering_progress, 0.5, 0.01,
		"Progress should be 50% after 1 second of 2-second gather")
	assert_almost_eq(harvestable_object.gathering_timer, 1.0, 0.01,
		"Timer should be 1.0 second")

func test_progress_bar_fill_updates():
	# REQ-006.1, REQ-006.2: Progress bar visual updates
	harvestable_object.gathering_progress = 0.5
	progress_bar.size = Vector2(40, 6)
	
	harvestable_object.update_progress_bar()
	
	assert_almost_eq(progress_fill.size.x, 20.0, 0.1,
		"Progress fill should be 50% of progress bar width")

func test_gathering_cancels_when_player_leaves_range():
	# REQ-003.5: Gathering cancels when player moves out of range
	harvestable_object.current_state = HarvestableObject.State.GATHERING
	harvestable_object.gathering_progress = 0.5
	harvestable_object.gathering_timer = 1.0
	harvestable_object.player_in_range = false  # Player left range
	progress_bar.visible = true
	
	harvestable_object.update_gathering(0.016)
	
	assert_eq(harvestable_object.current_state, HarvestableObject.State.NORMAL,
		"Should cancel gathering when player leaves range")
	assert_eq(harvestable_object.gathering_progress, 0.0,
		"Progress should be reset")
	assert_false(progress_bar.visible,
		"Progress bar should be hidden")

func test_complete_gathering_called_at_100_percent():
	# REQ-003.6: Gathering completes at 100% progress
	harvestable_object.current_state = HarvestableObject.State.GATHERING
	harvestable_object.gathering_time = 1.0
	harvestable_object.gathering_timer = 0.0
	harvestable_object.gathering_progress = 0.0
	harvestable_object.player_in_range = true
	
	# Simulate gathering for full duration
	harvestable_object.update_gathering(1.0)
	
	assert_almost_eq(harvestable_object.gathering_progress, 1.0, 0.01,
		"Progress should reach 100%")
	# Note: complete_gathering() is not implemented yet (Task 5.1)
	# This test verifies the progress reaches 100%, actual completion will be tested later

# ===== Integration Tests =====

func test_full_gathering_cycle_without_completion():
	# Test complete gathering cycle from NORMAL to GATHERING
	# (without completion since that's Task 5)
	
	# Start in NORMAL state
	assert_eq(harvestable_object.current_state, HarvestableObject.State.NORMAL)
	
	# Player enters range
	harvestable_object._on_body_entered(player)
	assert_eq(harvestable_object.current_state, HarvestableObject.State.INTERACTABLE)
	assert_true(interaction_indicator.visible)
	
	# Player presses interact
	harvestable_object.start_gathering()
	assert_eq(harvestable_object.current_state, HarvestableObject.State.GATHERING)
	assert_true(progress_bar.visible)
	assert_false(interaction_indicator.visible)
	
	# Gathering progresses
	harvestable_object.player_in_range = true
	harvestable_object.update_gathering(0.5)
	assert_gt(harvestable_object.gathering_progress, 0.0)
	
	# Player leaves range (cancel)
	harvestable_object.player_in_range = false
	harvestable_object.update_gathering(0.016)
	assert_eq(harvestable_object.current_state, HarvestableObject.State.NORMAL)
	assert_eq(harvestable_object.gathering_progress, 0.0)
	assert_false(progress_bar.visible)

func test_visual_state_consistency():
	# Test that visual state is consistent across all state transitions
	var states = [
		HarvestableObject.State.NORMAL,
		HarvestableObject.State.INTERACTABLE,
		HarvestableObject.State.GATHERING,
		HarvestableObject.State.DEPLETED
	]
	
	for state in states:
		harvestable_object.transition_to_state(state)
		
		# Verify state was set
		assert_eq(harvestable_object.current_state, state,
			"State should be set to %s" % state)
		
		# Verify visual updates were called (by checking visual properties)
		match state:
			HarvestableObject.State.NORMAL:
				assert_eq(visual.color, Color.GREEN)
				assert_false(interaction_indicator.visible)
			HarvestableObject.State.INTERACTABLE:
				assert_eq(visual.color, Color.YELLOW)
				assert_true(interaction_indicator.visible)
			HarvestableObject.State.GATHERING:
				assert_eq(visual.color, Color.YELLOW)
				assert_false(interaction_indicator.visible)
			HarvestableObject.State.DEPLETED:
				assert_eq(visual.color, Color.GRAY)
				assert_eq(visual.modulate.a, 0.5)

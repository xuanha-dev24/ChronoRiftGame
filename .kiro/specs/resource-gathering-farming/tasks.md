# Implementation Plan: Resource Gathering & Farming System

## Overview

This implementation plan breaks down the Resource Gathering & Farming System into discrete coding tasks. The system introduces harvestable environmental objects (trees, rocks, bushes) that players can interact with to gather resources. The implementation follows a phased approach: core components, gathering mechanics, resource integration, respawn system, spawner, and polish.

## Tasks

- [x] 1. Create HarvestableObject base script with state machine
  - Create `scripts/world/harvestable_object.gd` script extending Area2D
  - Define State enum (NORMAL, INTERACTABLE, GATHERING, DEPLETED)
  - Add exported properties for resource_type, amounts, timings, colors, and interaction_range
  - Add internal state variables (current_state, player_in_range, player_ref, timers)
  - Implement `_ready()` to randomize gathering_time (1-3s) and respawn_time (30-60s)
  - Connect Area2D signals (body_entered, body_exited) to handler methods
  - _Requirements: REQ-002.1, REQ-002.2, REQ-003.1, REQ-005.1_

- [ ] 2. Implement state transition and visual update logic
  - [x] 2.1 Implement transition_to_state() method
    - Update current_state variable
    - Call update_visual_state() after transition
    - _Requirements: REQ-002.1, REQ-002.3, REQ-005.2_
  
  - [x] 2.2 Implement update_visual_state() method
    - Update visual ColorRect color based on state (normal_color, interactable_color, depleted_color)
    - Set visual modulate.a to 0.5 for DEPLETED, 1.0 otherwise
    - Show/hide interaction_indicator based on state (visible only in INTERACTABLE)
    - Enable/disable collision_shape based on state (disabled in DEPLETED)
    - _Requirements: REQ-002.1, REQ-002.3, REQ-002.4, REQ-005.2_
  
  - [x] 2.3 Implement _on_body_entered() and _on_body_exited() handlers
    - Check if body is in "player" group
    - Update player_in_range and player_ref variables
    - Transition to INTERACTABLE when player enters (if in NORMAL state)
    - Transition to NORMAL when player exits (if in INTERACTABLE state)
    - Cancel gathering when player exits (if in GATHERING state)
    - _Requirements: REQ-002.1, REQ-002.2, REQ-002.3, REQ-003.4, REQ-003.5_
  
  - [ ]* 2.4 Write unit tests for state transitions
    - Test NORMAL → INTERACTABLE on player enter
    - Test INTERACTABLE → NORMAL on player exit
    - Test GATHERING → NORMAL on player exit (cancellation)
    - Test state transitions ignore non-player bodies
    - _Requirements: REQ-002.1, REQ-002.2, REQ-002.3_

- [ ] 3. Implement gathering mechanics
  - [x] 3.1 Implement check_for_interact_input() and start_gathering()
    - Check Input.is_action_just_pressed("interact") in INTERACTABLE state
    - Transition to GATHERING state
    - Reset gathering_progress and gathering_timer to 0
    - Show progress_bar and call update_progress_bar()
    - _Requirements: REQ-003.1, REQ-003.2, REQ-006.1_
  
  - [x] 3.2 Implement update_gathering() method
    - Increment gathering_timer by delta
    - Calculate gathering_progress as timer / gathering_time
    - Call update_progress_bar() to update visual
    - Check if player_in_range is false, call cancel_gathering() if true
    - Check if gathering_progress >= 1.0, call complete_gathering() if true
    - _Requirements: REQ-003.2, REQ-003.3, REQ-003.4, REQ-003.5, REQ-006.2_
  
  - [x] 3.3 Implement cancel_gathering() method
    - Transition to NORMAL state
    - Reset gathering_progress and gathering_timer to 0
    - Hide progress_bar
    - _Requirements: REQ-003.5, REQ-006.4, REQ-008.4_
  
  - [x] 3.4 Implement update_progress_bar() method
    - Calculate fill_width as progress_bar.size.x * gathering_progress
    - Set progress_fill.size.x to fill_width
    - _Requirements: REQ-006.1, REQ-006.2_
  
  - [ ]* 3.5 Write unit tests for gathering mechanics
    - Test gathering starts on interact input
    - Test progress updates correctly over time
    - Test gathering completes at 100% progress
    - Test gathering cancels when player exits range
    - Test progress bar visibility states
    - _Requirements: REQ-003.1, REQ-003.2, REQ-003.5, REQ-006.1_

- [x] 4. Checkpoint - Ensure gathering state machine works
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 5. Implement resource integration
  - [x] 5.1 Implement complete_gathering() method
    - Generate random amount between min_resource_amount and max_resource_amount
    - Validate resource_type is one of ["wood", "stone", "meat"]
    - Call ResourceManager.add_resource(resource_type, amount)
    - Transition to DEPLETED state
    - Hide progress_bar
    - Reset respawn_timer to 0
    - _Requirements: REQ-003.6, REQ-004.1, REQ-004.2, REQ-004.3, REQ-004.4, REQ-005.1_
  
  - [x] 5.2 Add error handling for invalid resource types
    - Log push_error() if resource_type not in valid list
    - Skip ResourceManager call if invalid
    - _Requirements: REQ-004.1, REQ-004.2, REQ-004.3_
  
  - [ ]* 5.3 Write integration tests for ResourceManager
    - Test wood resource added to ResourceManager.resources["wood"]
    - Test stone resource added to ResourceManager.resources["stone"]
    - Test meat resource added to ResourceManager.resources["meat"]
    - Test EventBus.resource_changed signal emitted with correct type and amount
    - Test invalid resource type logs error and skips addition
    - _Requirements: REQ-004.1, REQ-004.2, REQ-004.3, REQ-004.4, REQ-007.3_

- [ ] 6. Implement respawn system
  - [x] 6.1 Implement update_respawn() method
    - Increment respawn_timer by delta
    - Check if respawn_timer >= respawn_time
    - Call respawn() when timer expires
    - _Requirements: REQ-005.3, REQ-005.4_
  
  - [x] 6.2 Implement respawn() method
    - Check if player_in_range is true
    - Transition to INTERACTABLE if player in range, NORMAL otherwise
    - Re-randomize gathering_time (1-3s) and respawn_time (30-60s)
    - _Requirements: REQ-005.4, REQ-005.5_
  
  - [x] 6.3 Implement _process() method with state-based logic
    - Match current_state and call appropriate update method
    - INTERACTABLE: call check_for_interact_input()
    - GATHERING: call update_gathering(delta)
    - DEPLETED: call update_respawn(delta)
    - _Requirements: REQ-003.1, REQ-003.2, REQ-005.3_
  
  - [ ]* 6.4 Write unit tests for respawn system
    - Test respawn timer increments in DEPLETED state
    - Test respawn() transitions to NORMAL after timer expires
    - Test respawn() transitions to INTERACTABLE if player in range
    - Test gathering_time and respawn_time re-randomized on respawn
    - _Requirements: REQ-005.3, REQ-005.4, REQ-005.5_

- [ ] 7. Create Tree, Rock, and Bush scenes
  - [x] 7.1 Create Tree.tscn scene
    - Create Area2D root node named "Tree"
    - Attach harvestable_object.gd script
    - Add CollisionShape2D with CircleShape2D (radius=20)
    - Add Visual ColorRect (size=32x48, color=brown 0.55,0.35,0.2)
    - Add InteractionIndicator ColorRect (size=40x4, color=white, position above object)
    - Add ProgressBar ColorRect (size=40x6, color=black, position above indicator)
    - Add ProgressBar/Fill ColorRect (size=0x6, color=green)
    - Set exported properties: resource_type="wood", normal_color=brown, interactable_color=light brown, depleted_color=dark brown
    - _Requirements: REQ-001.4, REQ-004.1, REQ-006.1, REQ-008.1_
  
  - [x] 7.2 Create Rock.tscn scene
    - Create Area2D root node named "Rock"
    - Attach harvestable_object.gd script
    - Add CollisionShape2D with CircleShape2D (radius=18)
    - Add Visual ColorRect (size=36x28, color=gray 0.6,0.6,0.65)
    - Add InteractionIndicator ColorRect (size=40x4, color=white)
    - Add ProgressBar ColorRect (size=40x6, color=black)
    - Add ProgressBar/Fill ColorRect (size=0x6, color=green)
    - Set exported properties: resource_type="stone", normal_color=gray, interactable_color=light gray, depleted_color=dark gray
    - _Requirements: REQ-001.5, REQ-004.2, REQ-006.1, REQ-008.1_
  
  - [x] 7.3 Create Bush.tscn scene
    - Create Area2D root node named "Bush"
    - Attach harvestable_object.gd script
    - Add CollisionShape2D with CircleShape2D (radius=16)
    - Add Visual ColorRect (size=28x24, color=green 0.2,0.6,0.3)
    - Add InteractionIndicator ColorRect (size=40x4, color=white)
    - Add ProgressBar ColorRect (size=40x6, color=black)
    - Add ProgressBar/Fill ColorRect (size=0x6, color=green)
    - Set exported properties: resource_type="meat", normal_color=green, interactable_color=light green, depleted_color=dark green
    - _Requirements: REQ-001.6, REQ-004.3, REQ-006.1, REQ-008.1_
  
  - [x] 7.4 Add node validation to harvestable_object.gd _ready()
    - Check has_node("Visual"), log error and queue_free() if missing
    - Check has_node("ProgressBar/Fill"), log error and queue_free() if missing
    - Check has_node("InteractionIndicator"), log error and queue_free() if missing
    - Check has_node("CollisionShape2D"), log error and queue_free() if missing
    - _Requirements: REQ-001.4, REQ-001.5, REQ-001.6_

- [x] 8. Checkpoint - Ensure scenes are properly configured
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 9. Create HarvestableObjectSpawner script
  - [x] 9.1 Create spawner script and exported properties
    - Create `scripts/world/harvestable_object_spawner.gd` extending Node
    - Add @export var tree_scene: PackedScene
    - Add @export var rock_scene: PackedScene
    - Add @export var bush_scene: PackedScene
    - Add @export var min_spawn_count: int = 5
    - Add @export var map_size: Vector2 = Vector2(960, 960)
    - Add @export var spawn_margin: float = 50.0
    - Add @export var min_object_spacing: float = 80.0
    - Add spawned_positions: Array[Vector2] = []
    - _Requirements: REQ-001.1, REQ-001.3_
  
  - [x] 9.2 Implement spawn_objects() method
    - Call spawn_object_type(tree_scene, min_spawn_count)
    - Call spawn_object_type(rock_scene, min_spawn_count)
    - Call spawn_object_type(bush_scene, min_spawn_count)
    - _Requirements: REQ-001.1, REQ-001.3_
  
  - [x] 9.3 Implement spawn_object_type() method
    - Loop 'count' times
    - Call get_valid_spawn_position() for each iteration
    - Instantiate scene.instantiate()
    - Set instance.global_position to returned position
    - Add spawned position to spawned_positions array
    - Add instance to get_parent().get_node("YSortRoot")
    - _Requirements: REQ-001.1, REQ-001.2, REQ-007.5_
  
  - [x] 9.4 Implement get_valid_spawn_position() method
    - Set max_attempts = 50
    - Loop max_attempts times
    - Generate random position within map bounds (spawn_margin to map_size - spawn_margin)
    - Call is_position_valid(pos) to check spacing
    - Return position if valid
    - If all attempts fail, log push_warning() and return fallback position (map center + random offset)
    - _Requirements: REQ-001.1, REQ-001.2_
  
  - [x] 9.5 Implement is_position_valid() method
    - Loop through spawned_positions array
    - Calculate distance from pos to each spawned position
    - Return false if any distance < min_object_spacing
    - Return true if all distances >= min_object_spacing
    - _Requirements: REQ-001.2_
  
  - [x] 9.6 Implement _ready() method
    - Call spawn_objects()
    - _Requirements: REQ-001.1, REQ-007.1_
  
  - [ ]* 9.7 Write unit tests for spawner
    - Test spawn_objects() spawns min_spawn_count of each type
    - Test spawned positions are within map bounds
    - Test spawned positions maintain min_object_spacing
    - Test fallback position used after max attempts
    - _Requirements: REQ-001.1, REQ-001.2, REQ-001.3_

- [ ] 10. Integrate spawner into Prototype_World
  - [x] 10.1 Add HarvestableObjectSpawner to Prototype_World scene
    - Open scenes/world/Prototype_World.tscn
    - Add Node child to root named "HarvestableObjectSpawner"
    - Attach harvestable_object_spawner.gd script
    - Assign Tree.tscn to tree_scene export
    - Assign Rock.tscn to rock_scene export
    - Assign Bush.tscn to bush_scene export
    - Verify YSortRoot node exists in scene
    - _Requirements: REQ-001.1, REQ-007.1, REQ-007.5_
  
  - [x] 10.2 Ensure Player node is in "player" group
    - Open scenes/player/player.tscn
    - Add "player" to node groups if not already present
    - _Requirements: REQ-002.1, REQ-003.1, REQ-007.4_
  
  - [ ]* 10.3 Write integration tests for spawner in world
    - Test spawner spawns objects when Prototype_World loads
    - Test spawned objects are children of YSortRoot
    - Test minimum 15 total objects spawned (5 of each type)
    - Test objects don't overlap with player spawn position
    - _Requirements: REQ-001.1, REQ-001.3, REQ-007.1, REQ-007.5_

- [x] 11. Checkpoint - Ensure spawning and integration works
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 12. Polish and tuning
  - [x] 12.1 Verify visual feedback and colors
    - Test interaction indicator visibility in-game
    - Test progress bar fills smoothly during gathering
    - Test color changes are noticeable (normal, interactable, depleted)
    - Adjust colors if needed for better visibility
    - _Requirements: REQ-002.4, REQ-006.1, REQ-006.2, REQ-008.1_
  
  - [x] 12.2 Tune timing values for game feel
    - Test gathering time (1-3s) feels appropriate
    - Test respawn time (30-60s) is balanced
    - Test interaction range (50 pixels) is comfortable
    - Adjust exported defaults if needed
    - _Requirements: REQ-003.2, REQ-005.3, REQ-002.2_
  
  - [x] 12.3 Test edge cases and error handling
    - Test multiple objects in range (only one interactable at a time)
    - Test rapid enter/exit of interaction range
    - Test spamming interact key during gathering
    - Test gathering with missing ResourceManager
    - Test gathering with invalid resource type
    - Fix any issues found
    - _Requirements: REQ-002.1, REQ-003.1, REQ-004.1, REQ-007.3_
  
  - [x] 12.4 Verify integration with existing systems
    - Test ResourceManager.add_resource() increases resource totals
    - Test EventBus.resource_changed signal updates HUD
    - Test "interact" input action works as expected
    - Test objects don't interfere with enemy AI or player movement
    - Test YSort layering is correct (objects render in proper order)
    - _Requirements: REQ-007.1, REQ-007.2, REQ-007.3, REQ-007.4, REQ-007.5_

- [x] 13. Final checkpoint - Complete system verification
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation at key milestones
- All code uses GDScript (Godot 4.x syntax)
- Visual elements use ColorRect placeholders (no sprite assets required)
- System integrates with existing ResourceManager and EventBus autoloads
- Player must be in "player" group for interaction detection to work

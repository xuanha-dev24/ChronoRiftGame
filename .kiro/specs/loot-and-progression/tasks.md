# Implementation Plan: Loot & Progression System

## Overview

This implementation plan breaks down the Loot & Progression System into discrete coding tasks. The system enables enemies to drop collectible items when defeated, with automatic or manual pickup mechanics, inventory integration, and UI display. Implementation follows a bottom-up approach: data structures → core systems → pickup mechanics → inventory integration → UI → polish.

## Tasks

- [x] 1. Set up data structures and configuration files
  - Create `data/items.json` with item definitions (chrono_dust, health_potion)
  - Create or update `data/enemies.json` with loot_table entries for enemy types
  - Define item properties: id, name, description, type, icon_color, stack_size, rarity
  - Define drop table structure: item_id, chance, quantity [min, max]
  - _Requirements: 2.1, 2.2, 2.4, 2.5, 9.1, 9.2, 9.5_

- [ ]* 1.1 Write property test for item data retrieval
  - **Property 13: Item Data Retrieval**
  - **Validates: Requirements 9.3**

- [ ]* 1.2 Write property test for invalid item handling
  - **Property 14: Invalid Item Handling**
  - **Validates: Requirements 9.4**

- [ ] 2. Enhance DataManager with loot system methods
  - [x] 2.1 Implement `get_drop_table(enemy_id: String) -> Array` method
    - Query enemy data from loaded enemies.json
    - Return loot_table array for specified enemy type
    - Return empty array if enemy not found
    - _Requirements: 1.2, 2.1, 2.3_

  - [x] 2.2 Implement `get_item_data(item_id: String) -> Dictionary` method (if not exists)
    - Query item data from loaded items.json
    - Return item properties dictionary
    - Return empty dictionary or null for invalid item_id
    - _Requirements: 8.6, 9.3, 9.4_

  - [ ]* 2.3 Write unit tests for DataManager loot methods
    - Test get_drop_table with valid enemy types (slime_basic, fire_imp)
    - Test get_drop_table with unknown enemy type (returns empty array)
    - Test get_item_data with valid item_ids
    - Test get_item_data with invalid item_id
    - _Requirements: 2.3, 9.4_

- [ ] 3. Create PickupItem scene and script
  - [x] 3.1 Create PickupItem scene structure
    - Create `scenes/items/PickupItem.tscn`
    - Add Node2D root with script
    - Add Area2D child with CollisionShape2D (CircleShape2D, radius 16)
    - Add ColorRect visual (16x16 pixels)
    - Add Timer node for despawn (60 seconds)
    - Configure Area2D to use collision layer 3
    - _Requirements: 3.1, 3.2, 3.6_

  - [x] 3.2 Implement PickupItem script core properties
    - Create `scripts/items/PickupItem.gd`
    - Add `@export var item_id: String` and `@export var quantity: int`
    - Add `setup(p_item_id: String, p_quantity: int)` method
    - Store item_id and quantity in properties
    - Load item data from DataManager to set visual color
    - _Requirements: 3.3, 3.4_

  - [x] 3.3 Implement PickupItem collision detection
    - Connect Area2D `body_entered` and `body_exited` signals
    - Implement `_on_area_entered(body: Node2D)` to detect player
    - Implement `_on_area_exited(body: Node2D)` to track player exit
    - Store `player_in_range` boolean flag
    - _Requirements: 5.1, 6.1_

  - [x] 3.4 Implement PickupItem highlight effect
    - Implement `highlight()` method with color modulation (1.2x brightness)
    - Implement `unhighlight()` method to restore normal color
    - Call highlight() when player enters Area2D
    - Call unhighlight() when player exits Area2D
    - _Requirements: 4.1, 4.2, 4.3_

  - [x] 3.5 Implement PickupItem idle animation
    - Add subtle float/pulse animation using Tween
    - Animate position.y with sine wave (±3 pixels)
    - Animate scale with pulse (0.95 to 1.05)
    - Loop animation continuously
    - _Requirements: 4.4_

  - [x] 3.6 Implement PickupItem collection logic
    - Implement `collect()` method
    - Emit `EventBus.item_picked_up(item_id, quantity)` signal
    - Call `play_pickup_effect()` for visual/audio feedback
    - Call `queue_free()` to remove from scene
    - _Requirements: 5.2, 5.3_

  - [x] 3.7 Implement PickupItem despawn timer
    - Connect DespawnTimer `timeout` signal
    - Implement `_on_despawn_timer_timeout()` method
    - Fade out ColorRect using Tween (0.5 seconds)
    - Call `queue_free()` after fade completes
    - Start timer in `_ready()` method
    - _Requirements: 12.1_

  - [x] 3.8 Implement PickupItem audio and visual effects
    - Implement `play_pickup_effect()` method
    - Play pickup sound using AudioStreamPlayer (handle missing file gracefully)
    - Spawn particle effect via `EventBus.spawn_effect("pickup_effect", global_position)`
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5_

  - [ ]* 3.9 Write property test for item spawn positioning
    - **Property 2: Item Spawn Positioning**
    - **Validates: Requirements 1.4, 3.3, 3.4, 11.1_

  - [ ]* 3.10 Write property test for highlight state transitions
    - **Property 7: Highlight State Transitions**
    - **Validates: Requirements 4.1, 4.3**

  - [ ]* 3.11 Write property test for despawn timer
    - **Property 17: Despawn Timer**
    - **Validates: Requirements 12.1**

  - [ ]* 3.12 Write property test for missing audio handling
    - **Property 16: Missing Audio Graceful Handling**
    - **Validates: Requirements 10.5**

  - [ ]* 3.13 Write property test for pickup effect spawning
    - **Property 15: Pickup Effect Spawning**
    - **Validates: Requirements 10.2**

- [ ] 4. Checkpoint - Ensure PickupItem scene works in isolation
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 5. Create LootSystem autoload
  - [x] 5.1 Create LootSystem script and register as autoload
    - Create `scripts/systems/LootSystem.gd`
    - Add `class_name LootSystem` and `extends Node`
    - Register as autoload in Project Settings (name: "LootSystem")
    - Add constants: `MAX_ACTIVE_PICKUPS = 50`, `PICKUP_ITEM_SCENE` preload
    - Add variables: `active_pickups: int = 0`, `pickup_mode: String = "automatic"`
    - _Requirements: 1.1_

  - [x] 5.2 Implement LootSystem signal connection
    - Connect to `EventBus.enemy_killed` signal in `_ready()`
    - Implement `_on_enemy_killed(enemy_type: String, position: Vector2)` callback
    - Call `spawn_loot(enemy_type, position)` from callback
    - _Requirements: 1.1_

  - [x] 5.3 Implement drop table query and RNG logic
    - Implement `get_drop_table(enemy_type: String) -> Array` method
    - Call `DataManager.get_drop_table(enemy_type)`
    - Implement `roll_for_drops(drop_table: Array) -> Array` method
    - For each entry: roll random float 0.0-1.0, compare to chance
    - Roll quantity between min_quantity and max_quantity using `randi_range()`
    - Return array of {item_id, quantity} dictionaries for successful rolls
    - _Requirements: 1.2, 1.3, 1.6, 1.7_

  - [x] 5.4 Implement spawn positioning logic
    - Implement `get_offset_position(base_position: Vector2, index: int) -> Vector2` method
    - Use circular offset pattern with radius 10-30 pixels
    - Calculate angle based on index: `angle = (index / total) * TAU`
    - Return `base_position + Vector2(cos(angle), sin(angle)) * radius`
    - _Requirements: 1.5, 11.2_

  - [x] 5.5 Implement PickupItem spawning
    - Implement `spawn_pickup_item(item_id: String, quantity: int, position: Vector2)` method
    - Check if `active_pickups >= MAX_ACTIVE_PICKUPS`, log warning and return if true
    - Instance PICKUP_ITEM_SCENE
    - Call `setup(item_id, quantity)` on instance
    - Set `global_position` to calculated offset position
    - Add to scene tree via `get_tree().current_scene.add_child()`
    - Increment `active_pickups` counter
    - Connect to PickupItem's `tree_exited` signal to decrement counter
    - _Requirements: 1.4, 12.2, 12.3, 12.5_

  - [x] 5.6 Implement main spawn_loot method
    - Implement `spawn_loot(enemy_type: String, position: Vector2)` method
    - Call `get_drop_table(enemy_type)`
    - Call `roll_for_drops(drop_table)`
    - For each dropped item, call `spawn_pickup_item()` with offset position
    - Handle empty drop table gracefully (no items spawned)
    - _Requirements: 1.2, 1.3, 1.4, 2.3_

  - [ ]* 5.7 Write property test for drop rate convergence
    - **Property 1: Drop Rate Convergence**
    - **Validates: Requirements 1.3, 1.6**

  - [ ]* 5.8 Write property test for quantity range compliance
    - **Property 4: Quantity Range Compliance**
    - **Validates: Requirements 1.7**

  - [ ]* 5.9 Write property test for empty drop table handling
    - **Property 5: Empty Drop Table Handling**
    - **Validates: Requirements 2.3**

  - [ ]* 5.10 Write property test for multiple item offset
    - **Property 3: Multiple Item Offset**
    - **Validates: Requirements 1.5, 11.2**

  - [ ]* 5.11 Write property test for maximum pickup limit
    - **Property 18: Maximum Pickup Limit**
    - **Validates: Requirements 12.2, 12.3**

  - [ ]* 5.12 Write property test for limit warning emission
    - **Property 19: Limit Warning Emission**
    - **Validates: Requirements 12.5**

- [ ] 6. Checkpoint - Ensure LootSystem spawns items correctly
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 7. Implement automatic pickup mode
  - [x] 7.1 Configure player collision for pickup detection
    - Add or update player's Area2D to monitor collision layer 3
    - Ensure player collision area covers appropriate range (e.g., 32 pixel radius)
    - _Requirements: 5.1_

  - [x] 7.2 Implement automatic collection in PickupItem
    - In `_on_area_entered(body)`, check if `pickup_mode == "automatic"`
    - If automatic and body is player, call `collect()` immediately
    - _Requirements: 5.1, 5.4_

  - [ ]* 7.3 Write property test for pickup collection behavior
    - **Property 6: Pickup Collection Behavior**
    - **Validates: Requirements 5.1, 5.2, 5.3, 5.4**

- [ ] 8. Implement manual pickup mode
  - [x] 8.1 Add interact key input handling
    - Add "interact" action to Input Map (default: E key)
    - In PickupItem, implement `_input(event)` or `_unhandled_input(event)`
    - Check if interact key pressed and `player_in_range == true`
    - If manual mode and player in range, call `collect()`
    - _Requirements: 6.1_

  - [x] 8.2 Implement proximity selection for multiple items
    - In LootSystem or Player script, track all PickupItems in range
    - When interact key pressed, find closest PickupItem to player
    - Call `collect()` on closest item only
    - _Requirements: 6.2_

  - [x] 8.3 Add interact prompt display
    - Add Label node to PickupItem scene for prompt text ("Press E")
    - Show prompt when `player_in_range == true` and manual mode enabled
    - Hide prompt when player exits range
    - _Requirements: 6.3_

  - [x] 8.4 Add pickup mode configuration
    - Add `pickup_mode` variable to LootSystem or game settings
    - Support toggling between "automatic" and "manual" modes
    - _Requirements: 6.4_

  - [ ]* 8.5 Write property test for manual pickup proximity selection
    - **Property 8: Manual Pickup Proximity Selection**
    - **Validates: Requirements 6.2**

- [ ] 9. Enhance Player_Inventory for loot integration
  - [x] 9.1 Connect to item_picked_up signal
    - In Player_Inventory `_ready()`, connect to `EventBus.item_picked_up` signal
    - Implement `_on_item_picked_up(item_id: String, quantity: int)` callback
    - Call `add_item(item_id, quantity)` from callback
    - _Requirements: 7.1_

  - [x] 9.2 Implement or enhance add_item method
    - Implement `add_item(item_id: String, quantity: int) -> bool` method
    - Check if item_id already exists in inventory array
    - If exists: increment quantity, emit `inventory_changed` signal, return true
    - If not exists and inventory size < MAX_INVENTORY_SIZE: add new entry, emit signal, return true
    - If inventory full: return false (item remains in world)
    - Handle invalid item_id gracefully (log error, return false)
    - _Requirements: 7.2, 7.3, 7.4, 7.5, 7.6_

  - [x] 9.3 Add inventory capacity constant
    - Define `const MAX_INVENTORY_SIZE: int = 30`
    - Check capacity before adding new unique items
    - _Requirements: 7.5_

  - [ ]* 9.4 Write property test for inventory stacking
    - **Property 9: Inventory Stacking**
    - **Validates: Requirements 7.3**

  - [ ]* 9.5 Write property test for inventory new entry creation
    - **Property 10: Inventory New Entry Creation**
    - **Validates: Requirements 7.4**

  - [ ]* 9.6 Write property test for inventory capacity enforcement
    - **Property 11: Inventory Capacity Enforcement**
    - **Validates: Requirements 7.5**

  - [ ]* 9.7 Write property test for inventory change signal
    - **Property 12: Inventory Change Signal**
    - **Validates: Requirements 7.6**

- [ ] 10. Checkpoint - Ensure inventory integration works
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 11. Implement Inventory_UI display
  - [x] 11.1 Create or enhance Inventory_UI scene
    - Create `scenes/ui/Inventory_UI.tscn` if not exists
    - Add Panel background
    - Add Label for title ("Inventory")
    - Add GridContainer for item display (6 columns)
    - Add Panel for tooltip (initially hidden)
    - _Requirements: 8.3_

  - [x] 11.2 Implement inventory display refresh
    - Connect to `EventBus.inventory_changed` signal in `_ready()`
    - Implement `_on_inventory_changed()` method
    - Clear existing item displays from GridContainer
    - For each item in `Player_Inventory.inventory`:
      - Get item data from `DataManager.get_item_data(item_id)`
      - Create Panel with ColorRect (using icon_color) and Label
      - Set Label text to format: "{name} x{quantity}"
      - Add to GridContainer
      - Connect mouse_entered/exited signals for tooltip
    - _Requirements: 8.1, 8.2, 8.6_

  - [x] 11.3 Implement item color display
    - Use `icon_color` from Item_Data to set ColorRect color
    - Ensure distinct colors for different item types
    - _Requirements: 8.4_

  - [x] 11.4 Implement tooltip display
    - Implement `show_tooltip(item_id: String)` method
    - Get item data from DataManager
    - Set tooltip Label text to item name and description
    - Position tooltip near mouse cursor
    - Show tooltip panel
    - Implement `hide_tooltip()` method to hide panel
    - _Requirements: 8.5_

  - [ ]* 11.5 Write property test for UI display text format
    - **Property 20: UI Display Text Format**
    - **Validates: Requirements 8.2**

  - [ ]* 11.6 Write property test for tooltip data accuracy
    - **Property 21: Tooltip Data Accuracy**
    - **Validates: Requirements 8.5**

  - [ ]* 11.7 Write property test for distinct item colors
    - **Property 22: Distinct Item Colors**
    - **Validates: Requirements 8.4**

- [ ] 12. Add pickup visual and audio effects
  - [x] 12.1 Create pickup effect scene
    - Create `scenes/effects/pickup_effect.tscn`
    - Add CPUParticles2D or GPUParticles2D node
    - Configure particle properties (color, lifetime, spread)
    - Add AnimationPlayer for fade-out
    - Auto-free after animation completes
    - _Requirements: 10.2, 10.3_

  - [x] 12.2 Add pickup sound effect
    - Add placeholder audio file to `assets/audio/pickup.wav`
    - Configure AudioStreamPlayer in PickupItem scene
    - Set audio stream to pickup sound
    - Play sound in `play_pickup_effect()` method
    - _Requirements: 10.1, 10.4_

  - [x] 12.3 Integrate with EffectManager
    - Ensure EffectManager can spawn "pickup_effect" by name
    - Call `EventBus.spawn_effect("pickup_effect", position)` in PickupItem
    - _Requirements: 10.3_

- [ ] 13. Add spawn positioning enhancements
  - [x] 13.1 Implement terrain collision detection
    - In `spawn_pickup_item()`, raycast or check TileMap collision at spawn position
    - If collision detected, search for nearest valid position within 50 pixels
    - Use spiral search pattern to find valid position
    - Fallback to original position if no valid position found
    - _Requirements: 11.3, 11.4_

  - [x] 13.2 Add spawn animation
    - Add upward velocity or bounce animation to PickupItem on spawn
    - Use Tween to animate position.y with ease-out curve
    - Animate from spawn position + Vector2(0, -20) to spawn position
    - Duration: 0.3 seconds
    - _Requirements: 11.5_

- [ ] 14. Final integration and polish
  - [ ] 14.1 Wire all systems together
    - Ensure EventBus has all required signals defined
    - Verify signal connections between all components
    - Test full flow: enemy death → loot spawn → pickup → inventory → UI
    - _Requirements: All_

  - [x] 14.2 Add Y-Sort integration
    - Ensure PickupItem is child of Y-Sort node or has y_sort_enabled
    - Verify items render at correct depth based on Y position
    - _Requirements: 3.5_

  - [ ]* 14.3 Write integration tests
    - Test enemy death → loot drop flow
    - Test pickup → inventory → UI flow
    - Test manual vs automatic pickup modes
    - Test inventory full scenario
    - Test terrain collision adjustment
    - Test despawn cleanup
    - _Requirements: All_

- [ ] 15. Final checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation at key milestones
- Property tests validate universal correctness properties from the design document
- Unit tests validate specific examples and edge cases
- Integration tests verify system interactions
- The implementation uses GDScript for Godot Engine
- Placeholder visuals (ColorRect) are used for MVP; sprites can be added later
- The system integrates with existing EventBus, DataManager, Player_Inventory, and EffectManager

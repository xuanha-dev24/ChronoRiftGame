# Implementation Plan: Building/Base Building System

## Overview

This implementation plan follows the 10-phase development order specified in the design document. The Building/Base Building System enables players to construct defensive structures (Walls, Turrets, Crafting Stations, Storage Chests) on a grid-based map using gathered resources. The system integrates with ResourceManager, EventBus, YSortRoot, Enemy AI, and the Save System.

## Tasks

### Phase 1: Core Building System (Foundation)

- [x] 1. Set up Building_System autoload and core data structures
  - [x] 1.1 Create `scripts/systems/building_system.gd` as autoload singleton
    - Implement core properties: `build_mode_active`, `selected_structure_type`, `placement_preview`, `structures` dictionary, `structure_count`, `MAX_STRUCTURES`, `GRID_SIZE`
    - Add to Project Settings > Autoload as "Building_System"
    - _Requirements: 1.1, 20.1_
  
  - [x] 1.2 Implement build mode toggle functionality
    - Write `toggle_build_mode()` method to switch build mode on/off
    - Emit `EventBus.build_mode_changed` signal
    - _Requirements: 1.1, 1.5_
  
  - [x] 1.3 Implement grid coordinate conversion functions
    - Write `world_to_grid(world_pos: Vector2) -> Vector2i` method
    - Write `grid_to_world(grid_pos: Vector2i) -> Vector2` method
    - Ensure grid cells are 16x16 pixels, grid origin at (0, 0)
    - _Requirements: 3.2, 17.1_
  
  - [ ]* 1.4 Write property test for grid coordinate conversion
    - **Property 1: Grid Coordinate Bidirectional Conversion**
    - **Validates: Requirements 3.2, 17.1**
    - Test that world_to_grid and grid_to_world produce positions on 16px grid boundaries
    - Run 100 iterations with random world positions
  
  - [x] 1.5 Create `data/structures.json` data file
    - Define structure data for wall, turret, crafting_station, storage_chest
    - Include fields: name, max_health, costs, grid_size, scene_path
    - _Requirements: 19.1, 19.2, 19.5_
  
  - [ ]* 1.6 Write property test for structure data schema validation
    - **Property 20: Structure Data Schema Validation**
    - **Validates: Requirements 19.2, 19.4**
    - Test that all structure entries contain required fields with correct types
  
  - [x] 1.7 Implement placement validation logic
    - Write `is_within_bounds(grid_pos: Vector2i, grid_size: Vector2i) -> bool` method
    - Write `check_overlap_with_structures(grid_pos: Vector2i, grid_size: Vector2i) -> bool` method
    - Write `check_overlap_with_harvestables(grid_pos: Vector2i, grid_size: Vector2i) -> bool` method
    - Write `validate_placement(grid_pos: Vector2i, grid_size: Vector2i) -> Dictionary` method returning {valid: bool, error: String}
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_
  
  - [ ]* 1.8 Write property tests for placement validation
    - **Property 2: Bounds Checking Correctness**
    - **Validates: Requirements 4.1**
    - Test that bounds check returns true iff all cells are in [0, 29] range
  
  - [ ]* 1.9 Write property test for spatial overlap detection
    - **Property 3: Spatial Overlap Detection**
    - **Validates: Requirements 4.2, 4.3**
    - Test that overlap detection returns true iff two rectangular regions share at least one grid cell
  
  - [ ]* 1.10 Write property test for resource sufficiency check
    - **Property 4: Resource Sufficiency Check**
    - **Validates: Requirements 4.4**
    - Test that sufficiency check returns true iff all resource amounts >= costs

- [x] 2. Checkpoint - Core Building System
  - Ensure all tests pass, ask the user if questions arise.

### Phase 2: Structure Base Class (Common Functionality)

- [x] 3. Create Structure base class with health system
  - [x] 3.1 Create `scripts/structures/structure.gd` base class extending Area2D
    - Define class_name Structure
    - Implement @export properties: structure_type, max_health, grid_size, resource_costs
    - Implement runtime state: current_health, grid_position, is_destroyed
    - Add to collision layer 4 (structures), collision mask 3 (player + enemies)
    - _Requirements: 7.1, 18.1, 18.2_
  
  - [x] 3.2 Implement health system methods
    - Write `initialize(grid_pos: Vector2i)` method
    - Write `take_damage(amount: int)` method
    - Write `destroy()` method
    - Emit appropriate EventBus signals
    - _Requirements: 7.2, 7.3, 7.4, 7.5_
  
  - [ ]* 3.3 Write property tests for health system
    - **Property 7: Health Initialization**
    - **Validates: Requirements 7.1**
    - Test that newly instantiated structures have current_health == max_health
  
  - [ ]* 3.4 Write property test for health damage calculation
    - **Property 8: Health Damage Calculation**
    - **Validates: Requirements 7.2**
    - Test that after taking damage D, current_health == H - D
  
  - [x] 3.5 Implement visual feedback system
    - Write `update_health_bar()` method
    - Write `update_visual_feedback()` method for color modulation
    - Implement damage flash effect (white for 0.1s)
    - _Requirements: 7.6, 16.1, 16.2, 16.3, 16.4_
  
  - [ ]* 3.6 Write property test for health-to-color modulation
    - **Property 17: Health-to-Color Modulation Mapping**
    - **Validates: Requirements 16.1, 16.2, 16.3**
    - Test that color is white if H/M > 0.66, yellow if 0.33 < H/M <= 0.66, red if H/M <= 0.33
  
  - [x] 3.7 Implement save/load interface
    - Write `get_save_data() -> Dictionary` method
    - Write `load_from_data(data: Dictionary)` method
    - _Requirements: 13.1_
  
  - [ ]* 3.8 Write property test for structure save data completeness
    - **Property 14: Structure Save Data Completeness**
    - **Validates: Requirements 13.1**
    - Test that get_save_data() returns dictionary with all required fields: type, grid_position, current_health, rotation

- [x] 4. Checkpoint - Structure Base Class
  - Ensure all tests pass, ask the user if questions arise.

### Phase 3: Basic Structures (Wall, Crafting Station, Storage Chest)

- [x] 5. Create Wall structure
  - [x] 5.1 Create `scenes/structures/Wall.tscn` scene
    - Root: Area2D (extends Structure)
    - Add ColorRect visual (16x16, brown)
    - Add CollisionShape2D with RectangleShape2D (16x16)
    - Add ProgressBar for health bar
    - _Requirements: 5.3, 18.3_
  
  - [x] 5.2 Create `scripts/structures/wall.gd` script
    - Extend Structure base class
    - Set structure_type = "wall", max_health = 100, grid_size = Vector2i(1, 1), resource_costs = {"wood": 10}
    - _Requirements: 5.2_
  
  - [ ]* 5.3 Write property test for collision shape sizing
    - **Property 19: Collision Shape Size Matching**
    - **Validates: Requirements 18.3**
    - Test that collision shape dimensions == (grid_size.x * 16, grid_size.y * 16)

- [x] 6. Create Crafting Station structure
  - [x] 6.1 Create `scenes/structures/CraftingStation.tscn` scene
    - Root: Area2D (extends Structure)
    - Add ColorRect visual (32x32, orange)
    - Add CollisionShape2D with RectangleShape2D (32x32)
    - Add ProgressBar for health bar
    - Add ColorRect for interaction indicator (white bar, initially hidden)
    - _Requirements: 5.3, 11.1_
  
  - [x] 6.2 Create `scripts/structures/crafting_station.gd` script
    - Extend Structure base class
    - Set structure_type = "crafting_station", max_health = 200, grid_size = Vector2i(2, 2), resource_costs = {"wood": 20, "stone": 15}
    - Implement interaction system: player_in_range detection, _on_body_entered, _on_body_exited
    - Implement `open_crafting_ui()` method to emit EventBus.crafting_station_opened and show placeholder message
    - _Requirements: 5.2, 11.1, 11.2, 11.3, 11.4_

- [x] 7. Create Storage Chest structure with inventory system
  - [x] 7.1 Create `scenes/structures/StorageChest.tscn` scene
    - Root: Area2D (extends Structure)
    - Add ColorRect visual (32x32, blue)
    - Add CollisionShape2D with RectangleShape2D (32x32)
    - Add ProgressBar for health bar
    - Add ColorRect for interaction indicator (white bar, initially hidden)
    - _Requirements: 5.3, 12.1_
  
  - [x] 7.2 Create `scripts/structures/storage_chest.gd` script
    - Extend Structure base class
    - Set structure_type = "storage_chest", max_health = 150, grid_size = Vector2i(2, 2), resource_costs = {"wood": 25}
    - Implement chest_inventory array (20 slots)
    - _Requirements: 5.2, 12.3_
  
  - [x] 7.3 Implement chest inventory methods
    - Write `initialize_inventory()` method
    - Write `add_item(item_id: String, quantity: int) -> bool` method
    - Write `remove_item(slot_index: int) -> Dictionary` method
    - Write `get_item(slot_index: int) -> Dictionary` method
    - Write `is_inventory_full() -> bool` method
    - _Requirements: 12.4, 12.5_
  
  - [x] 7.4 Implement chest interaction system
    - Implement player_in_range detection, _on_body_entered, _on_body_exited
    - Implement `open_chest_ui()` method to emit EventBus.storage_chest_opened
    - Implement chest UI closing on distance or Escape key
    - _Requirements: 12.1, 12.2, 12.6_
  
  - [x] 7.5 Implement chest item dropping on destruction
    - Override `destroy()` method to spawn PickupItems for all inventory items
    - _Requirements: 12.7, 15.5_
  
  - [ ]* 7.6 Write property test for chest item dropping
    - **Property 13: Chest Item Dropping on Destruction**
    - **Validates: Requirements 12.7, 15.5**
    - Test that destroying chest with N items spawns exactly N PickupItems
  
  - [x] 7.7 Implement chest inventory serialization
    - Override `get_save_data()` to include inventory
    - Override `load_from_data()` to restore inventory
    - _Requirements: 13.2, 13.4_
  
  - [ ]* 7.8 Write property test for chest inventory round-trip
    - **Property 15: Chest Inventory Serialization Round-Trip**
    - **Validates: Requirements 13.2, 13.4**
    - Test that saving and loading chest results in identical inventory contents

- [x] 8. Checkpoint - Basic Structures
  - Ensure all tests pass, ask the user if questions arise.

### Phase 4: Build UI (User Interface)

- [x] 9. Create Build UI scene and structure buttons
  - [x] 9.1 Create `scenes/ui/Build_UI.tscn` scene
    - Root: CanvasLayer
    - Add Panel (Control) positioned in bottom-right corner
    - Add VBoxContainer with ResourceDisplay (HBoxContainer), StructureButtons (GridContainer), InfoLabel
    - Add 4 structure buttons: WallButton, TurretButton, CraftingStationButton, StorageChestButton
    - Add ErrorMessage label
    - _Requirements: 14.1, 14.6_
  
  - [x] 9.2 Create `scripts/ui/build_ui.gd` script
    - Implement `show_build_ui()` and `hide_build_ui()` methods
    - Implement `update_resource_display()` method
    - Implement `update_button_states()` method to enable/disable buttons based on resources
    - Implement `highlight_button(type: String)` and `clear_button_highlights()` methods
    - Implement `show_error_message(message: String)` method
    - Implement `_on_structure_button_pressed(type: String)` signal handlers
    - _Requirements: 14.2, 14.3, 14.4, 14.5_
  
  - [ ]* 9.3 Write property test for button state based on resources
    - **Property 22: Button State Based on Resources**
    - **Validates: Requirements 14.3, 14.4**
    - Test that button opacity is 1.0 if resources sufficient, 0.5 if insufficient
  
  - [x] 9.4 Connect Build_UI to Building_System signals
    - Connect to EventBus.build_mode_changed to show/hide UI
    - Connect to EventBus.resource_changed to update resource display
    - _Requirements: 1.3_

- [x] 10. Checkpoint - Build UI
  - Ensure all tests pass, ask the user if questions arise.

### Phase 5: Placement System (Preview and Placement)

- [x] 11. Create Placement Preview system
  - [x] 11.1 Create `scenes/ui/Placement_Preview.tscn` scene
    - Root: Node2D
    - Add ColorRect visual with 50% opacity
    - Add GridIndicator node for multi-cell structures
    - _Requirements: 2.5, 3.1_
  
  - [x] 11.2 Create `scripts/ui/placement_preview.gd` script
    - Implement `set_structure_type(type: String)` method
    - Implement `update_position(mouse_pos: Vector2)` method with grid snapping
    - Implement `set_valid(is_valid: bool)` method for green/red color feedback
    - Implement `show_preview()` and `hide_preview()` methods
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_
  
  - [x] 11.3 Implement structure selection in Building_System
    - Write `select_structure(type: String)` method
    - Write `deselect_structure()` method
    - Instantiate and manage Placement_Preview
    - _Requirements: 2.1, 2.2, 2.3, 2.4_
  
  - [x] 11.4 Implement preview position updates
    - Write `update_preview_position(mouse_pos: Vector2)` method
    - Call validate_placement and update preview color
    - _Requirements: 3.1, 3.3, 3.4_
  
  - [x] 11.5 Implement structure placement action
    - Write `place_structure(grid_pos: Vector2i) -> bool` method
    - Check validation, check resources, deduct resources, instantiate structure
    - Add structure to YSortRoot, register in structures dictionary
    - Emit EventBus.structure_placed signal
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_
  
  - [ ]* 11.6 Write property test for resource deduction accuracy
    - **Property 5: Resource Deduction Accuracy**
    - **Validates: Requirements 5.2**
    - Test that resource amounts after placement == amounts before - costs
  
  - [ ]* 11.7 Write property test for structure registry consistency
    - **Property 6: Structure Registry Consistency**
    - **Validates: Requirements 5.4, 7.4, 15.3**
    - Test that structures dictionary contains entry at grid position after placement, and entry is removed after destruction
  
  - [x] 11.8 Implement structure cancellation
    - Handle Escape key and right mouse button to deselect structure
    - _Requirements: 6.1, 6.2, 6.3, 6.4_

- [x] 12. Checkpoint - Placement System
  - Ensure all tests pass, ask the user if questions arise.

### Phase 6: Turret and AI (Advanced Structure)

- [x] 13. Create Turret structure with AI component
  - [x] 13.1 Create `scenes/structures/Turret.tscn` scene
    - Root: Area2D (extends Structure)
    - Add ColorRect visual (16x16, gray) with directional indicator
    - Add CollisionShape2D with RectangleShape2D (16x16)
    - Add ProgressBar for health bar
    - Add Node child for Turret_AI component
    - _Requirements: 5.3_
  
  - [x] 13.2 Create `scripts/structures/turret.gd` script
    - Extend Structure base class
    - Set structure_type = "turret", max_health = 150, grid_size = Vector2i(1, 1), resource_costs = {"wood": 15, "stone": 10}
    - Support rotation (affects firing direction)
    - _Requirements: 5.2, 17.4_
  
  - [ ]* 13.3 Write property test for rotation increment
    - **Property 21: Rotation Increment**
    - **Validates: Requirements 17.4**
    - Test that pressing rotate key results in rotation angle (R + 90) mod 360
  
  - [x] 13.4 Create `scripts/structures/turret_ai.gd` component
    - Extend Node, class_name TurretAI
    - Define constants: SCAN_RANGE = 150.0, ATTACK_COOLDOWN = 1.5, PROJECTILE_SPEED = 200.0, PROJECTILE_DAMAGE = 15, PROJECTILE_MAX_DISTANCE = 200.0
    - Implement properties: current_target, attack_cooldown_timer, scan_timer, SCAN_INTERVAL = 0.5
    - _Requirements: 9.1, 9.6_
  
  - [x] 13.5 Implement enemy scanning and target selection
    - Write `scan_for_enemies()` method to detect enemies within 150px range
    - Write `select_closest_enemy(enemies: Array) -> Node2D` method
    - Write `is_target_valid()` method
    - _Requirements: 9.1, 9.2, 9.7_
  
  - [ ]* 13.6 Write property test for closest target selection
    - **Property 9: Closest Target Selection**
    - **Validates: Requirements 8.2, 9.2**
    - Test that selected target is the one with minimum distance to selector position
  
  - [x] 13.7 Implement turret rotation toward target
    - Write `rotate_to_target(delta: float)` method
    - _Requirements: 9.3_
  
  - [ ]* 13.8 Write property test for turret rotation toward target
    - **Property 10: Turret Rotation Toward Target**
    - **Validates: Requirements 9.3**
    - Test that turret rotation angle points toward target position (within epsilon)
  
  - [x] 13.9 Implement turret AI main loop
    - Write `_process(delta: float)` method
    - Handle scan timer, target validation, rotation, attack cooldown, firing
    - _Requirements: 9.1, 9.3, 9.4, 9.6_

- [x] 14. Create Turret Projectile system
  - [x] 14.1 Create `scenes/structures/TurretProjectile.tscn` scene
    - Root: Area2D
    - Add ColorRect visual (4x4, yellow)
    - Add CollisionShape2D with CircleShape2D (radius 2)
    - Set collision mask to layer 2 (enemies)
    - _Requirements: 10.5, 18.5_
  
  - [x] 14.2 Create `scripts/structures/turret_projectile.gd` script
    - Implement projectile movement toward target at 200 px/s
    - Implement collision detection with enemies
    - Implement damage dealing (15 damage) and self-destruction on hit
    - Implement max travel distance (200px) and self-destruction
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.6_
  
  - [ ]* 14.3 Write property test for projectile velocity magnitude
    - **Property 11: Projectile Velocity Magnitude**
    - **Validates: Requirements 10.2**
    - Test that velocity vector magnitude == 200 pixels per second
  
  - [ ]* 14.4 Write property test for projectile lifetime distance
    - **Property 12: Projectile Lifetime Distance**
    - **Validates: Requirements 10.4**
    - Test that projectile is removed after traveling 200 pixels
  
  - [x] 14.5 Implement projectile firing in Turret_AI
    - Write `fire_projectile()` method
    - Instantiate projectile at turret position, add to YSortRoot
    - _Requirements: 9.4, 9.5_

- [x] 15. Checkpoint - Turret and AI
  - Ensure all tests pass, ask the user if questions arise.

### Phase 7: Enemy Integration (Structure Targeting)

- [x] 16. Modify Enemy AI to target structures
  - [x] 16.1 Update enemy Chase state to detect structures
    - Modify `enemy_states/chase_state.gd` to add structures within 100px to potential targets
    - Implement `detect_targets()` method to include both player and structures
    - Implement `select_closest_target(targets: Array)` method
    - _Requirements: 8.1, 8.2_
  
  - [x] 16.2 Update enemy Attack state to damage structures
    - Modify `enemy_states/attack_state.gd` to call `take_damage()` on structure targets
    - Ensure same attack cooldown and damage values used for structures
    - _Requirements: 8.3, 8.5_
  
  - [x] 16.3 Implement target clearing when structure destroyed
    - Handle case where structure is destroyed while enemy is targeting it
    - Clear target and search for new targets
    - _Requirements: 8.4_

- [x] 17. Checkpoint - Enemy Integration
  - Ensure all tests pass, ask the user if questions arise.

### Phase 8: Demolition System (Structure Removal)

- [x] 18. Implement structure demolition
  - [x] 18.1 Implement demolition input handling in Building_System
    - Detect X key hold + mouse click on structure
    - Write `demolish_structure(grid_pos: Vector2i)` method
    - _Requirements: 15.1_
  
  - [x] 18.2 Implement refund calculation and resource return
    - Calculate 50% refund (rounded down) for each resource type
    - Call ResourceManager.add_resource for each refund
    - _Requirements: 15.2_
  
  - [ ]* 18.3 Write property test for demolition refund calculation
    - **Property 18: Demolition Refund Calculation**
    - **Validates: Requirements 15.2**
    - Test that refund amount == int(cost * 0.5) for each resource
  
  - [x] 18.4 Implement structure removal and cleanup
    - Remove structure from structures dictionary
    - Remove structure from scene
    - Emit EventBus.structure_demolished signal
    - _Requirements: 15.3, 15.4_

- [x] 19. Checkpoint - Demolition System
  - Ensure all tests pass, ask the user if questions arise.

### Phase 9: Save/Load Integration (Persistence)

- [x] 20. Integrate structures with Save System
  - [x] 20.1 Implement structure saving in Save_System
    - Write `save_structures() -> Array` method
    - Iterate through all structures, call get_save_data()
    - _Requirements: 13.1_
  
  - [x] 20.2 Implement structure loading in Save_System
    - Write `load_structures(structure_data: Array)` method
    - Validate structure data, instantiate structures at saved positions
    - _Requirements: 13.3, 13.5_
  
  - [ ]* 20.3 Write property test for save data position validation
    - **Property 16: Save Data Position Validation**
    - **Validates: Requirements 13.5**
    - Test that validation rejects data with positions outside [0, 29] or overlapping existing structures
  
  - [x] 20.4 Implement structure loading in Building_System
    - Write `load_structure_from_data(data: Dictionary)` method
    - Instantiate structure scene, call load_from_data(), add to scene and registry
    - _Requirements: 13.3_

- [x] 21. Checkpoint - Save/Load Integration
  - Ensure all tests pass, ask the user if questions arise.

### Phase 10: Polish and Optimization (Final Touches)

- [x] 22. Implement structure limits and performance optimizations
  - [x] 22.1 Implement structure limit enforcement
    - Check structure_count against MAX_STRUCTURES (100) before placement
    - Display error message "Structure limit reached (100/100)" when limit reached
    - Display warning message "Approaching structure limit (X/100)" at 50+ structures
    - _Requirements: 20.1, 20.2, 20.5_
  
  - [x] 22.2 Implement turret AI staggering for performance
    - Limit turret AI processing to max 10 turrets per frame
    - Distribute turret updates across frames
    - _Requirements: 20.3_
  
  - [x] 22.3 Implement spatial partitioning for collision detection
    - Divide 30x30 grid into 6x6 sectors (5x5 cells each)
    - Use spatial_grid dictionary to optimize placement validation
    - Only check structures in relevant sectors
    - _Requirements: 20.4_

- [ ] 23. Add visual and audio effects
  - [x] 23.1 Implement damage flash effect for structures
    - Flash white for 0.1 seconds when taking damage
    - _Requirements: 16.4_
  
  - [ ] 23.2 Implement destruction particle effect
    - Play particle effect before structure removal
    - _Requirements: 16.6_
  
  - [ ] 23.3 Implement turret muzzle flash animation
    - Play muzzle flash for 0.2 seconds when firing
    - _Requirements: 16.5_
  
  - [ ] 23.4 Add sound effects (optional)
    - Add sounds for: structure placement, demolition, turret fire, structure destroyed
    - Use AudioStreamPlayer2D for positional audio

- [ ] 24. Implement build mode input handling
  - [x] 24.1 Implement mouse position capture and grid conversion
    - Capture mouse position in _process or _input
    - Convert to grid coordinates
    - _Requirements: 17.1_
  
  - [x] 24.2 Disable player movement in build mode
    - Prevent WASD input when build_mode_active
    - _Requirements: 1.2, 17.2_
  
  - [ ] 24.3 Implement camera panning with middle mouse button (optional)
    - Allow camera panning while in build mode
    - _Requirements: 17.3_
  
  - [ ] 24.4 Implement rotation input for turrets
    - Handle R key press to rotate Placement_Preview 90 degrees
    - Only allow rotation for turret structures
    - _Requirements: 17.4, 17.5_

- [x] 25. Add EventBus signals for building system
  - [x] 25.1 Add new signals to EventBus.gd
    - Add: build_mode_changed, structure_placed, structure_destroyed, structure_demolished, crafting_station_opened, storage_chest_opened, storage_chest_closed
    - _Requirements: 1.5, 5.5, 7.5, 15.4_

- [x] 26. Final checkpoint - Complete system integration
  - Ensure all tests pass, ask the user if questions arise.
  - Test complete workflow: toggle build mode, select structure, place structure, structure takes damage, structure destroyed
  - Test turret AI: turret scans, targets, rotates, fires, projectile hits enemy
  - Test chest: open chest, transfer items, close chest, destroy chest (items drop)
  - Test save/load: place structures, save game, load game, verify structures restored
  - Test demolition: demolish structure, verify refund
  - Test structure limit: place 100 structures, verify limit enforcement

## Notes

- Tasks marked with `*` are optional property-based tests and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation throughout development
- Property tests validate universal correctness properties with 100+ iterations
- The 10-phase structure follows the design document's recommended development order
- All structures use GDScript (Godot's scripting language)
- Integration with existing systems (ResourceManager, EventBus, YSortRoot, Enemy AI, Save System) is critical
- Performance optimizations (spatial partitioning, turret AI staggering) are included in Phase 10

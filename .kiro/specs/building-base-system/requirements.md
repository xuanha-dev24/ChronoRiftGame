# Requirements Document: Building/Base Building System

## Introduction

The Building/Base Building System enables players to construct and manage structures on the game map to create a defensive base. Players can place walls, turrets, crafting stations, and storage chests using gathered resources. Structures can be damaged by enemies and must be strategically positioned to defend the player's base. This system integrates with the existing ResourceManager, EventBus, YSortRoot, and enemy AI systems.

## Glossary

- **Building_System**: The autoload singleton that manages building mode, placement validation, and structure instantiation
- **Structure**: A placeable game object (Wall, Turret, Crafting_Station, or Storage_Chest) that occupies grid cells
- **Build_Mode**: A game state where the player can preview and place structures
- **Build_UI**: The user interface displaying available structures, resource costs, and build mode controls
- **Grid_Cell**: A 16x16 pixel tile unit on the 30x30 tile map used for structure placement
- **Placement_Preview**: A semi-transparent visual representation of a structure shown during Build_Mode
- **Structure_Health_System**: The component managing structure hit points and damage reception
- **Turret_AI**: The automated targeting and attack system for Turret structures
- **Crafting_Station**: A structure that enables access to crafting recipes when interacted with
- **Storage_Chest**: A structure that provides additional inventory capacity through item transfer
- **Collision_Detection**: The validation system ensuring structures do not overlap with existing objects
- **Save_System**: The persistence layer storing structure positions, types, health, and states
- **ResourceManager**: The existing autoload tracking player resources (fire_shard, gold, stone, wood, meat)
- **EventBus**: The existing global signal bus for inter-system communication
- **YSortRoot**: The existing node managing proper rendering order for isometric objects
- **Enemy_AI**: The existing enemy behavior system that can target and attack structures

## Requirements

### Requirement 1: Build Mode Activation

**User Story:** As a player, I want to toggle build mode on and off, so that I can switch between normal gameplay and structure placement.

#### Acceptance Criteria

1. WHEN the player presses the build mode key (B), THE Building_System SHALL toggle Build_Mode on or off
2. WHILE Build_Mode is active, THE Building_System SHALL disable player attack and chrono rift abilities
3. WHILE Build_Mode is active, THE Build_UI SHALL display available structures with resource costs
4. WHEN Build_Mode is deactivated, THE Building_System SHALL hide the Placement_Preview and restore normal player controls
5. THE Building_System SHALL emit EventBus.build_mode_changed signal with the current Build_Mode state

### Requirement 2: Structure Selection

**User Story:** As a player, I want to select which structure to build, so that I can choose the appropriate building for my strategy.

#### Acceptance Criteria

1. WHILE Build_Mode is active, WHEN the player clicks on a structure button in Build_UI, THE Building_System SHALL set the selected structure type
2. WHILE Build_Mode is active, WHEN the player presses number keys 1-4, THE Building_System SHALL select the corresponding structure type (1=Wall, 2=Turret, 3=Crafting_Station, 4=Storage_Chest)
3. WHEN a structure type is selected, THE Building_System SHALL display the Placement_Preview at the mouse cursor position
4. WHEN a structure type is selected, THE Build_UI SHALL highlight the selected structure button
5. THE Placement_Preview SHALL display the structure sprite at 50% opacity

### Requirement 3: Placement Preview and Grid Snapping

**User Story:** As a player, I want to see where my structure will be placed, so that I can position it accurately on the grid.

#### Acceptance Criteria

1. WHILE a structure type is selected, THE Placement_Preview SHALL follow the mouse cursor position
2. THE Placement_Preview SHALL snap to Grid_Cell boundaries (16x16 pixels)
3. WHEN the Placement_Preview position is valid for placement, THE Placement_Preview SHALL display in green color
4. WHEN the Placement_Preview position is invalid for placement, THE Placement_Preview SHALL display in red color
5. THE Placement_Preview SHALL display the structure dimensions in Grid_Cells (Wall=1x1, Turret=1x1, Crafting_Station=2x2, Storage_Chest=2x2)

### Requirement 4: Placement Validation

**User Story:** As a player, I want the system to prevent invalid placements, so that structures do not overlap or appear in illegal positions.

#### Acceptance Criteria

1. WHEN validating placement, THE Building_System SHALL check that all Grid_Cells occupied by the structure are within map bounds (0-29 x, 0-29 y)
2. WHEN validating placement, THE Building_System SHALL check that no Grid_Cells occupied by the structure overlap with existing structures
3. WHEN validating placement, THE Building_System SHALL check that no Grid_Cells occupied by the structure overlap with harvestable objects (trees, rocks, bushes)
4. WHEN validating placement, THE Building_System SHALL check that the player has sufficient resources for the structure cost
5. THE Building_System SHALL return a boolean validation result and an error message string for invalid placements

### Requirement 5: Structure Placement and Resource Deduction

**User Story:** As a player, I want to place structures by spending resources, so that I can build my base using gathered materials.

#### Acceptance Criteria

1. WHILE a structure type is selected and the Placement_Preview is valid, WHEN the player clicks the left mouse button, THE Building_System SHALL instantiate the structure at the preview position
2. WHEN a structure is placed, THE Building_System SHALL deduct the structure cost from ResourceManager (Wall=10 wood, Turret=15 wood + 10 stone, Crafting_Station=20 wood + 15 stone, Storage_Chest=25 wood)
3. WHEN a structure is placed, THE Building_System SHALL add the structure to YSortRoot for proper rendering order
4. WHEN a structure is placed, THE Building_System SHALL register the structure in the Building_System structures dictionary with grid position as key
5. WHEN a structure is placed, THE Building_System SHALL emit EventBus.structure_placed signal with structure type and position

### Requirement 6: Structure Cancellation

**User Story:** As a player, I want to cancel structure placement, so that I can change my mind without placing a building.

#### Acceptance Criteria

1. WHILE a structure type is selected, WHEN the player presses the Escape key, THE Building_System SHALL deselect the structure and hide the Placement_Preview
2. WHILE a structure type is selected, WHEN the player presses the right mouse button, THE Building_System SHALL deselect the structure and hide the Placement_Preview
3. WHEN structure selection is cancelled, THE Build_UI SHALL remove the highlight from structure buttons
4. WHEN Build_Mode is deactivated while a structure is selected, THE Building_System SHALL deselect the structure and hide the Placement_Preview

### Requirement 7: Structure Health System

**User Story:** As a player, I want structures to have health points, so that they can be damaged and destroyed by enemies.

#### Acceptance Criteria

1. WHEN a structure is instantiated, THE Structure SHALL initialize with maximum health points (Wall=100, Turret=150, Crafting_Station=200, Storage_Chest=150)
2. WHEN a structure receives damage, THE Structure_Health_System SHALL reduce current health by the damage amount
3. WHEN a structure current health reaches zero, THE Structure SHALL transition to destroyed state and remove itself from the scene
4. WHEN a structure is destroyed, THE Building_System SHALL remove the structure from the structures dictionary
5. WHEN a structure is destroyed, THE Building_System SHALL emit EventBus.structure_destroyed signal with structure type and position
6. WHILE a structure exists, THE Structure SHALL display a health bar above the structure showing current health percentage

### Requirement 8: Enemy Structure Targeting

**User Story:** As a player, I want enemies to attack my structures, so that I must defend my base from threats.

#### Acceptance Criteria

1. WHEN an enemy is in Chase state and detects a structure within 100 pixels, THE Enemy_AI SHALL add the structure to potential targets
2. WHEN an enemy has both player and structure targets available, THE Enemy_AI SHALL prioritize the closer target
3. WHEN an enemy is in Attack state targeting a structure, THE Enemy_AI SHALL deal damage to the structure health
4. WHEN a structure is destroyed while an enemy is targeting it, THE Enemy_AI SHALL remove the structure from targets and search for new targets
5. THE Enemy_AI SHALL use the same attack cooldown and damage values for structure attacks as player attacks

### Requirement 9: Turret Automated Targeting

**User Story:** As a player, I want turrets to automatically attack nearby enemies, so that they provide defensive support.

#### Acceptance Criteria

1. WHILE a Turret exists, THE Turret_AI SHALL scan for enemies within 150 pixel range every 0.5 seconds
2. WHEN the Turret_AI detects one or more enemies in range, THE Turret_AI SHALL select the closest enemy as the target
3. WHILE a Turret has a valid target, THE Turret_AI SHALL rotate to face the target position
4. WHILE a Turret has a valid target and attack cooldown is ready, THE Turret_AI SHALL fire a projectile toward the target
5. WHEN a Turret projectile hits an enemy, THE Turret_AI SHALL deal 15 damage to the enemy
6. THE Turret_AI SHALL use a 1.5 second attack cooldown between shots
7. WHEN a Turret target moves out of range or is destroyed, THE Turret_AI SHALL clear the target and resume scanning

### Requirement 10: Turret Projectile System

**User Story:** As a player, I want turret projectiles to be visible and accurate, so that I can see the turret defending my base.

#### Acceptance Criteria

1. WHEN a Turret fires, THE Turret_AI SHALL instantiate a projectile at the Turret position
2. THE projectile SHALL move toward the target position at 200 pixels per second
3. WHEN a projectile enters an enemy Area2D, THE projectile SHALL deal damage to the enemy and remove itself from the scene
4. WHEN a projectile travels more than 200 pixels without hitting a target, THE projectile SHALL remove itself from the scene
5. THE projectile SHALL be rendered as a 4x4 pixel yellow ColorRect
6. THE projectile SHALL be added to YSortRoot for proper rendering order

### Requirement 11: Crafting Station Interaction

**User Story:** As a player, I want to interact with crafting stations, so that I can access crafting recipes.

#### Acceptance Criteria

1. WHEN the player is within 50 pixels of a Crafting_Station, THE Crafting_Station SHALL display an interaction indicator above the structure
2. WHILE the player is within 50 pixels of a Crafting_Station, WHEN the player presses the interact key (E), THE Crafting_Station SHALL emit EventBus.crafting_station_opened signal
3. WHEN EventBus.crafting_station_opened is emitted, THE game SHALL display a placeholder message "Crafting UI - Coming Soon"
4. WHEN the player moves more than 50 pixels away from a Crafting_Station, THE Crafting_Station SHALL hide the interaction indicator

### Requirement 12: Storage Chest Interaction

**User Story:** As a player, I want to interact with storage chests, so that I can transfer items between my inventory and the chest.

#### Acceptance Criteria

1. WHEN the player is within 50 pixels of a Storage_Chest, THE Storage_Chest SHALL display an interaction indicator above the structure
2. WHILE the player is within 50 pixels of a Storage_Chest, WHEN the player presses the interact key (E), THE Storage_Chest SHALL open the chest inventory UI
3. WHEN a Storage_Chest is opened, THE Storage_Chest SHALL display a 20-slot inventory grid separate from the player inventory
4. WHILE a Storage_Chest inventory UI is open, THE player SHALL be able to drag items from player inventory to chest inventory
5. WHILE a Storage_Chest inventory UI is open, THE player SHALL be able to drag items from chest inventory to player inventory
6. WHEN the player moves more than 50 pixels away from a Storage_Chest or presses Escape, THE Storage_Chest SHALL close the chest inventory UI
7. WHEN a Storage_Chest is destroyed, THE Storage_Chest SHALL drop all contained items as PickupItems at the chest position

### Requirement 13: Structure Save and Load

**User Story:** As a player, I want my placed structures to persist between game sessions, so that I do not lose my base progress.

#### Acceptance Criteria

1. WHEN the game saves, THE Save_System SHALL serialize all placed structures including type, grid position, current health, and rotation
2. WHEN a Storage_Chest is saved, THE Save_System SHALL serialize the chest inventory contents including item IDs and quantities
3. WHEN the game loads, THE Save_System SHALL deserialize structure data and instantiate structures at saved positions
4. WHEN a Storage_Chest is loaded, THE Save_System SHALL restore the chest inventory contents from saved data
5. THE Save_System SHALL validate loaded structure positions to ensure they remain within map bounds and do not overlap

### Requirement 14: Build UI Display

**User Story:** As a player, I want to see available structures and their costs, so that I can make informed building decisions.

#### Acceptance Criteria

1. WHILE Build_Mode is active, THE Build_UI SHALL display four structure buttons (Wall, Turret, Crafting_Station, Storage_Chest)
2. FOR ALL structure buttons, THE Build_UI SHALL display the structure name, icon, and resource costs
3. WHEN the player has insufficient resources for a structure, THE Build_UI SHALL display the structure button with 50% opacity and disable clicking
4. WHEN the player has sufficient resources for a structure, THE Build_UI SHALL display the structure button at 100% opacity and enable clicking
5. THE Build_UI SHALL display current player resource counts (wood, stone) at the top of the UI panel
6. THE Build_UI SHALL be positioned in the bottom-right corner of the screen and remain visible during Build_Mode

### Requirement 15: Structure Demolition

**User Story:** As a player, I want to demolish structures I have placed, so that I can reclaim space and recover some resources.

#### Acceptance Criteria

1. WHILE Build_Mode is active, WHEN the player holds the demolish key (X) and clicks on a structure, THE Building_System SHALL remove the structure from the scene
2. WHEN a structure is demolished, THE Building_System SHALL refund 50% of the structure resource cost to ResourceManager (rounded down)
3. WHEN a structure is demolished, THE Building_System SHALL remove the structure from the structures dictionary
4. WHEN a structure is demolished, THE Building_System SHALL emit EventBus.structure_demolished signal with structure type and position
5. WHEN a Storage_Chest is demolished, THE Storage_Chest SHALL drop all contained items as PickupItems at the chest position before removal

### Requirement 16: Structure Visual Feedback

**User Story:** As a player, I want visual feedback on structure states, so that I can quickly assess structure health and status.

#### Acceptance Criteria

1. WHEN a structure health is above 66%, THE Structure SHALL display with normal color (white modulation)
2. WHEN a structure health is between 33% and 66%, THE Structure SHALL display with yellow color modulation
3. WHEN a structure health is below 33%, THE Structure SHALL display with red color modulation
4. WHEN a structure receives damage, THE Structure SHALL flash white for 0.1 seconds
5. WHEN a Turret is firing, THE Turret SHALL play a muzzle flash animation for 0.2 seconds
6. WHEN a structure is destroyed, THE Structure SHALL play a destruction particle effect before removal

### Requirement 17: Build Mode Input Handling

**User Story:** As a player, I want intuitive controls for build mode, so that I can efficiently place and manage structures.

#### Acceptance Criteria

1. WHILE Build_Mode is active, THE Building_System SHALL capture mouse position and convert it to grid coordinates
2. WHILE Build_Mode is active, THE Building_System SHALL prevent player movement input (WASD keys)
3. WHILE Build_Mode is active, THE Building_System SHALL allow camera panning with middle mouse button drag
4. WHEN the player presses the rotate key (R) while a structure is selected, THE Placement_Preview SHALL rotate 90 degrees clockwise
5. THE Building_System SHALL support rotation for Turret structures (affects firing direction) but not for Wall, Crafting_Station, or Storage_Chest structures

### Requirement 18: Structure Collision Layers

**User Story:** As a developer, I want structures to use proper collision layers, so that they integrate correctly with existing game systems.

#### Acceptance Criteria

1. WHEN a structure is instantiated, THE Structure SHALL set collision layer to 4 (structures layer)
2. WHEN a structure is instantiated, THE Structure SHALL set collision mask to 3 (player layer + enemy layer)
3. THE Structure collision shape SHALL match the structure Grid_Cell dimensions (1x1 = 16x16 pixels, 2x2 = 32x32 pixels)
4. WHEN validating placement, THE Building_System SHALL use Area2D overlap detection on collision layer 4 to detect existing structures
5. THE Turret projectile SHALL use collision mask 2 (enemy layer) to detect enemy hits

### Requirement 19: Structure Data Definition

**User Story:** As a developer, I want structure definitions in a data file, so that structure properties can be easily modified and extended.

#### Acceptance Criteria

1. THE Building_System SHALL load structure definitions from data/structures.json at initialization
2. FOR ALL structure types, THE structures.json file SHALL define name, max_health, resource_costs, grid_size, and scene_path
3. WHEN a structure type is not found in structures.json, THE Building_System SHALL log an error and prevent placement
4. THE Building_System SHALL validate that all required fields exist in structures.json for each structure type
5. THE structures.json file SHALL use the following format: {"structure_id": {"name": "string", "max_health": int, "costs": {"wood": int, "stone": int}, "grid_size": {"x": int, "y": int}, "scene_path": "string"}}

### Requirement 20: Performance and Limits

**User Story:** As a player, I want the building system to perform well, so that the game remains responsive with many structures.

#### Acceptance Criteria

1. THE Building_System SHALL support a maximum of 100 placed structures simultaneously
2. WHEN the player attempts to place a structure and the structure limit is reached, THE Building_System SHALL display an error message "Structure limit reached (100/100)"
3. THE Turret_AI SHALL limit enemy scanning to a maximum of 10 turrets processing per frame (staggered updates)
4. THE Building_System SHALL use spatial partitioning to optimize collision detection for placement validation
5. WHEN more than 50 structures exist, THE Building_System SHALL display a warning message "Approaching structure limit (X/100)"

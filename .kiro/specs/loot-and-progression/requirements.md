# Requirements Document

## Introduction

The Loot & Progression System enables enemies to drop items when defeated and allows players to collect these items through a pickup mechanic. This system integrates with the existing inventory system to provide the core gameplay loop of combat → loot → collection → progression. The system is designed for a 2.5D isometric Godot game with placeholder visuals for MVP.

## Glossary

- **Loot_System**: The system responsible for spawning items when enemies are killed
- **Pickup_Item**: A scene instance representing a collectible item in the game world
- **Player_Inventory**: The existing inventory management system that stores collected items
- **Inventory_UI**: The user interface that displays collected items and their quantities
- **Enemy**: Any entity in the "enemies" group that can be killed and drop loot
- **Drop_Table**: A data structure defining which items an enemy type can drop and their probabilities
- **Interact_Area**: A collision detection area around the player for item pickup
- **Item_Data**: JSON data defining item properties (id, name, description, type)

## Requirements

### Requirement 1: Enemy Loot Drop System

**User Story:** As a player, I want enemies to drop items when I defeat them, so that I am rewarded for combat and can collect resources.

#### Acceptance Criteria

1. WHEN an enemy is killed, THE Loot_System SHALL receive the enemy_killed signal with enemy type and position
2. WHEN the Loot_System receives an enemy_killed signal, THE Loot_System SHALL query the Drop_Table for that enemy type
3. WHEN the Drop_Table is queried, THE Loot_System SHALL determine which items to drop based on configured drop rates
4. WHEN items are determined to drop, THE Loot_System SHALL spawn Pickup_Item instances at the enemy death position
5. WHEN multiple items drop from one enemy, THE Pickup_Item instances SHALL be offset from each other to prevent overlap
6. THE Loot_System SHALL support configurable drop rates per enemy type (0.0 to 1.0 probability)
7. THE Loot_System SHALL support multiple item drops per enemy (e.g., 1-3 chrono dust)

### Requirement 2: Drop Table Configuration

**User Story:** As a developer, I want to configure different loot tables for different enemy types, so that gameplay variety and balance can be achieved.

#### Acceptance Criteria

1. THE Drop_Table SHALL be loaded from JSON data files by the DataManager
2. THE Drop_Table SHALL define item_id, drop_rate, min_quantity, and max_quantity for each enemy type
3. WHEN an enemy type has no Drop_Table entry, THE Loot_System SHALL drop no items
4. THE Drop_Table SHALL support at least two enemy types (SlimeBasic and EarthGolem)
5. THE Drop_Table SHALL support at least two item types (chrono_dust and health_potion)

### Requirement 3: Pickup Item Scene

**User Story:** As a player, I want to see dropped items in the game world, so that I know what loot is available to collect.

#### Acceptance Criteria

1. THE Pickup_Item SHALL be a scene with a ColorRect visual representation
2. THE Pickup_Item SHALL have an Area2D for collision detection with the player
3. THE Pickup_Item SHALL store item_id and quantity as properties
4. WHEN spawned, THE Pickup_Item SHALL position itself at the specified world coordinates
5. THE Pickup_Item SHALL integrate with the Y-Sort system for proper depth rendering
6. THE Pickup_Item SHALL use collision layer 3 for pickup detection

### Requirement 4: Visual Feedback for Pickable Items

**User Story:** As a player, I want visual feedback when I'm near a pickable item, so that I know I can collect it.

#### Acceptance Criteria

1. WHEN the player enters the Pickup_Item's Area2D, THE Pickup_Item SHALL display a highlight effect
2. THE highlight effect SHALL be a color modulation or scale pulse animation
3. WHEN the player exits the Pickup_Item's Area2D, THE Pickup_Item SHALL remove the highlight effect
4. THE Pickup_Item SHALL animate continuously with a subtle float or pulse effect to draw attention

### Requirement 5: Automatic Pickup System

**User Story:** As a player, I want to automatically pick up items when I walk over them, so that collection feels smooth and doesn't interrupt gameplay.

#### Acceptance Criteria

1. WHEN the player's collision area overlaps with a Pickup_Item's Area2D, THE Pickup_Item SHALL be collected automatically
2. WHEN a Pickup_Item is collected, THE Pickup_Item SHALL emit the item_picked_up signal with item_id
3. WHEN a Pickup_Item is collected, THE Pickup_Item SHALL remove itself from the scene tree
4. WHEN a Pickup_Item is collected, THE Player_Inventory SHALL add the item with the specified quantity
5. WHEN a Pickup_Item is collected, THE Pickup_Item SHALL play a placeholder pickup sound effect

### Requirement 6: Manual Pickup System

**User Story:** As a player, I want to press the interact key (E) to pick up items, so that I have control over what I collect.

#### Acceptance Criteria

1. WHERE manual pickup is enabled, WHEN the player presses the interact key AND is within a Pickup_Item's Area2D, THE Pickup_Item SHALL be collected
2. WHERE manual pickup is enabled, WHEN multiple Pickup_Items are in range, THE Pickup_Item SHALL collect the closest item to the player
3. WHERE manual pickup is enabled, THE Pickup_Item SHALL display an interact prompt (e.g., "Press E") when in range
4. THE Loot_System SHALL support a configuration flag to toggle between automatic and manual pickup modes

### Requirement 7: Inventory Integration

**User Story:** As a player, I want collected items to be added to my inventory automatically, so that I can access them later.

#### Acceptance Criteria

1. WHEN the Player_Inventory receives an item_picked_up signal, THE Player_Inventory SHALL call add_item with the item_id
2. WHEN an item is added to inventory, THE Player_Inventory SHALL check if the item already exists
3. WHEN an item already exists in inventory, THE Player_Inventory SHALL increment the quantity
4. WHEN an item does not exist in inventory, THE Player_Inventory SHALL create a new inventory entry
5. WHEN inventory is full, THE Player_Inventory SHALL return false and the Pickup_Item SHALL remain in the world
6. WHEN an item is successfully added, THE Player_Inventory SHALL emit the inventory_changed signal

### Requirement 8: Inventory UI Display

**User Story:** As a player, I want to see my collected items in the inventory UI, so that I know what resources I have.

#### Acceptance Criteria

1. WHEN the Inventory_UI receives an inventory_changed signal, THE Inventory_UI SHALL refresh the displayed items
2. THE Inventory_UI SHALL display each item with its name and quantity (e.g., "Chrono Dust x5")
3. THE Inventory_UI SHALL use a grid layout to organize items visually
4. THE Inventory_UI SHALL display items using placeholder ColorRect icons with distinct colors per item type
5. WHEN the player hovers over an item, THE Inventory_UI SHALL display a tooltip with item name and description
6. THE Inventory_UI SHALL load item names and descriptions from Item_Data via DataManager

### Requirement 9: Item Data Management

**User Story:** As a developer, I want item data to be loaded from JSON files, so that items can be easily configured and expanded.

#### Acceptance Criteria

1. THE DataManager SHALL load item data from data/items.json on game start
2. THE Item_Data SHALL define id, name, description, type, and icon_color for each item
3. WHEN the Loot_System or Inventory_UI requests item data, THE DataManager SHALL return the Item_Data for the specified item_id
4. WHEN an item_id does not exist in Item_Data, THE DataManager SHALL return null or a default placeholder
5. THE Item_Data SHALL support at least two item types: chrono_dust and health_potion

### Requirement 10: Pickup Sound and Visual Effects

**User Story:** As a player, I want audio and visual feedback when I pick up items, so that the action feels satisfying.

#### Acceptance Criteria

1. WHEN a Pickup_Item is collected, THE Pickup_Item SHALL play a pickup sound effect (placeholder audio)
2. WHEN a Pickup_Item is collected, THE Pickup_Item SHALL spawn a particle effect at the pickup location
3. THE particle effect SHALL use the EffectManager to spawn a pickup_effect scene
4. THE pickup sound SHALL be a short, positive audio cue (e.g., coin pickup sound)
5. WHERE no audio file exists, THE Pickup_Item SHALL skip playing the sound without causing errors

### Requirement 11: Loot Spawn Positioning

**User Story:** As a player, I want dropped items to spawn in accessible locations, so that I can always collect them.

#### Acceptance Criteria

1. WHEN items are spawned, THE Loot_System SHALL position them at the enemy death position
2. WHEN multiple items drop, THE Loot_System SHALL offset each item by a random distance (10-30 pixels) from the center
3. THE Loot_System SHALL ensure spawned items do not overlap with impassable terrain
4. WHERE terrain collision is detected, THE Loot_System SHALL adjust the spawn position to the nearest valid location
5. THE Loot_System SHALL spawn items with a slight upward velocity or bounce animation for visual appeal

### Requirement 12: Performance and Cleanup

**User Story:** As a developer, I want the loot system to perform efficiently, so that the game runs smoothly even with many items.

#### Acceptance Criteria

1. WHEN a Pickup_Item is not collected within 60 seconds, THE Pickup_Item SHALL fade out and remove itself from the scene
2. THE Loot_System SHALL limit the maximum number of active Pickup_Items to 50 instances
3. WHEN the maximum is reached, THE Loot_System SHALL not spawn new items until existing items are collected or despawn
4. THE Pickup_Item SHALL use object pooling WHERE performance optimization is needed
5. THE Loot_System SHALL emit a warning to the console WHEN the maximum item limit is reached

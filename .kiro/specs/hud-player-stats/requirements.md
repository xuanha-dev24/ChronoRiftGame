# Requirements Document: HUD & Player Stats Display

## Introduction

The HUD & Player Stats Display system provides real-time visual feedback to the player about their character's status, resources, and available abilities. This system displays critical information including health, mana/stamina, Chrono Rift cooldown status, inventory capacity, and quick-access item slots. The HUD uses screen-space rendering to remain visible at all times and updates efficiently through event-driven signals.

## Glossary

- **HUD_System**: The heads-up display system that renders player stats and game information on screen
- **HP_Bar**: Visual bar displaying current and maximum health points
- **Mana_Bar**: Visual bar displaying current and maximum mana/stamina for abilities
- **Chrono_Rift_Indicator**: Visual element showing cooldown state of the Chrono Rift ability
- **Hotbar**: Quick-access slots for items mapped to keys 1-5
- **Inventory_Counter**: Text display showing current item count versus maximum capacity
- **Resource_Placeholder**: Reserved UI space for future resource display (gold, wood, stone)
- **Resource_Display**: UI element showing player's current resources (Fire Element Shard, Gold, Stone, Wood, Meat)
- **Player_Stats**: Player character data including HP, mana, and ability states
- **EventBus**: Global signal system for event-driven communication
- **CanvasLayer**: Godot node type for screen-space UI rendering

## Requirements

### Requirement 1: HP Bar Display

**User Story:** As a player, I want to see my current HP, so that I know when I'm in danger and need to heal or retreat.

#### Acceptance Criteria

1. THE HUD_System SHALL display a visual bar representing current HP versus maximum HP
2. WHEN Player_Stats HP value changes, THE HP_Bar SHALL update within 100ms
3. THE HP_Bar SHALL display numerical text showing current HP and maximum HP in format "X/Y"
4. WHEN current HP is below 30% of maximum HP, THE HP_Bar SHALL change color to red
5. WHEN current HP is between 30% and 60% of maximum HP, THE HP_Bar SHALL change color to yellow
6. WHEN current HP is above 60% of maximum HP, THE HP_Bar SHALL display green color

### Requirement 2: Mana/Stamina Bar Display

**User Story:** As a player, I want to see my mana/stamina level, so that I know when I can use abilities like Chrono Rift.

#### Acceptance Criteria

1. THE HUD_System SHALL display a visual bar representing current mana versus maximum mana
2. WHEN Player_Stats mana value changes, THE Mana_Bar SHALL update within 100ms
3. THE Mana_Bar SHALL display numerical text showing current mana and maximum mana in format "X/Y"
4. THE Mana_Bar SHALL use a distinct color from HP_Bar to differentiate resource types
5. WHEN current mana is zero, THE Mana_Bar SHALL display empty state visually

### Requirement 3: Chrono Rift Cooldown Indicator

**User Story:** As a player, I want to see when Chrono Rift is ready to use again, so that I can plan my combat strategy effectively.

#### Acceptance Criteria

1. THE HUD_System SHALL display a visual indicator for Chrono Rift cooldown state
2. WHEN Chrono Rift is on cooldown, THE Chrono_Rift_Indicator SHALL display remaining cooldown time in seconds
3. WHEN Chrono Rift is ready to use, THE Chrono_Rift_Indicator SHALL display "READY" state with distinct visual feedback
4. THE Chrono_Rift_Indicator SHALL update cooldown display every 100ms during cooldown period
5. WHEN Chrono Rift cooldown completes, THE Chrono_Rift_Indicator SHALL emit a visual pulse or flash effect

### Requirement 4: Hotbar Quick Slots

**User Story:** As a player, I want quick access to items via hotbar slots, so that I can use items during combat without opening the full inventory.

#### Acceptance Criteria

1. THE HUD_System SHALL display 5 hotbar slots corresponding to keys 1-5
2. WHEN an item is assigned to a hotbar slot, THE Hotbar SHALL display the item icon or name
3. WHEN a hotbar slot is empty, THE Hotbar SHALL display an empty slot indicator
4. WHEN a hotbar item quantity changes, THE Hotbar SHALL update the displayed quantity within 100ms
5. THE Hotbar SHALL display the key binding (1-5) for each slot
6. WHEN a hotbar item is used and depleted, THE Hotbar SHALL clear that slot and display empty state

### Requirement 5: Inventory Capacity Counter

**User Story:** As a player, I want to see how full my inventory is, so that I know when I need to manage my items or when I'm approaching capacity.

#### Acceptance Criteria

1. THE HUD_System SHALL display inventory item count in format "X/Y" where X is current count and Y is maximum capacity
2. WHEN Player_Inventory item count changes, THE Inventory_Counter SHALL update within 100ms
3. WHEN inventory is at 90% capacity or higher, THE Inventory_Counter SHALL change color to orange as a warning
4. WHEN inventory is at 100% capacity, THE Inventory_Counter SHALL change color to red
5. THE Inventory_Counter SHALL display the text "Inventory:" as a label

### Requirement 6: Resource Display

**User Story:** As a player, I want to see my current resources, so that I know what materials I have available for crafting and building.

#### Acceptance Criteria

1. THE HUD_System SHALL display the following resources with icons and quantities:
   - Fire Element Shard (mảnh nguyên tố lửa)
   - Gold (vàng)
   - Stone (đá)
   - Wood (gỗ)
   - Meat (thịt)
2. WHEN a resource quantity changes, THE Resource_Display SHALL update within 100ms
3. THE Resource_Display SHALL show resource icon or color-coded indicator and numerical quantity
4. THE Resource_Display SHALL display resources in a compact list or grid format
5. WHEN a resource quantity is zero, THE Resource_Display SHALL still show the resource with "0" quantity
6. THE Resource_Display SHALL maintain consistent positioning in the top-right area below Inventory_Counter

### Requirement 7: Screen-Space Rendering

**User Story:** As a player, I want the HUD to always be visible on screen, so that I can monitor my stats regardless of camera position or world state.

#### Acceptance Criteria

1. THE HUD_System SHALL use CanvasLayer for screen-space rendering
2. THE HUD_System SHALL remain visible at all times during gameplay
3. WHEN the game window is resized, THE HUD_System SHALL maintain proper positioning and scaling within 200ms
4. THE HUD_System SHALL render above all world elements and game objects
5. THE HUD_System SHALL not be affected by camera movement or world transformations

### Requirement 8: Event-Driven Updates

**User Story:** As a developer, I want the HUD to update only when values change, so that the system performs efficiently without unnecessary processing.

#### Acceptance Criteria

1. THE HUD_System SHALL connect to EventBus signals for stat change notifications
2. WHEN a stat change signal is received, THE HUD_System SHALL update only the affected display element
3. THE HUD_System SHALL NOT poll for stat changes every frame
4. WHEN Player_Stats emits hp_changed signal, THE HP_Bar SHALL update its display
5. WHEN Player_Stats emits mana_changed signal, THE Mana_Bar SHALL update its display
6. WHEN Player_Inventory emits inventory_changed signal, THE Inventory_Counter SHALL update its display
7. WHEN chrono_rift_system emits cooldown_changed signal, THE Chrono_Rift_Indicator SHALL update its display

### Requirement 9: Visual Style Consistency

**User Story:** As a player, I want the HUD to match the game's pixel art style, so that the interface feels cohesive with the game world.

#### Acceptance Criteria

1. THE HUD_System SHALL use pixel art style visual elements
2. THE HUD_System SHALL use nearest-neighbor texture filtering for all UI elements
3. THE HUD_System SHALL use readable fonts appropriate for pixel art style
4. THE HUD_System SHALL maintain consistent spacing and alignment between all elements
5. THE HUD_System SHALL use a color palette consistent with the game's art direction

### Requirement 10: HUD Layout and Positioning

**User Story:** As a player, I want the HUD elements organized logically on screen, so that I can quickly find the information I need during gameplay.

#### Acceptance Criteria

1. THE HUD_System SHALL position HP_Bar and Mana_Bar in the top-left corner of the screen
2. THE HUD_System SHALL position Chrono_Rift_Indicator near the ability bars for visual grouping
3. THE HUD_System SHALL position Hotbar at the bottom-center of the screen
4. THE HUD_System SHALL position Inventory_Counter in the top-right corner of the screen
5. THE HUD_System SHALL position Resource_Display below the Inventory_Counter in the top-right area
6. THE HUD_System SHALL maintain minimum 10-pixel padding from screen edges for all elements

# Design Document: Loot & Progression System

## Overview

The Loot & Progression System implements a complete item drop and collection mechanic for ChronoRift. When enemies are defeated, they spawn collectible items in the game world based on configurable drop tables. Players can collect these items either automatically (by walking over them) or manually (by pressing the interact key), and collected items are added to their inventory with visual and audio feedback.

This system integrates with existing game systems:
- **EventBus**: For enemy death notifications and item pickup events
- **DataManager**: For loading item and enemy data from JSON
- **Player_Inventory**: For storing collected items
- **Inventory_UI**: For displaying collected items
- **EffectManager**: For spawning pickup visual effects

The design prioritizes:
1. **Modularity**: Loot system is decoupled from enemy and inventory systems via signals
2. **Data-driven configuration**: Drop tables and item properties defined in JSON
3. **Performance**: Object pooling and automatic cleanup for dropped items
4. **Player experience**: Smooth pickup mechanics with satisfying feedback

## Architecture

### System Components

```
┌─────────────────────────────────────────────────────────────┐
│                         EventBus                             │
│  (enemy_killed, item_picked_up, inventory_changed signals)  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                       LootSystem                             │
│  - Listens to enemy_killed signal                           │
│  - Queries drop tables from DataManager                     │
│  - Spawns PickupItem instances                              │
│  - Manages active pickup count (max 50)                     │
│  - Handles spawn positioning with offset                    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      PickupItem (Scene)                      │
│  - Area2D for collision detection                           │
│  - ColorRect visual (placeholder)                           │
│  - Properties: item_id, quantity                            │
│  - Highlight effect when player nearby                      │
│  - Auto-despawn after 60 seconds                            │
│  - Emits item_picked_up signal on collection                │
└─────────────────────────────────────────────────────────────┐
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     Player_Inventory                         │
│  - Listens to item_picked_up signal                         │
│  - Adds items (stacking or new entry)                       │
│  - Checks inventory capacity (max 30 slots)                 │
│  - Emits inventory_changed signal                           │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      Inventory_UI                            │
│  - Listens to inventory_changed signal                      │
│  - Displays items in grid layout                            │
│  - Shows item name, quantity, icon (ColorRect)              │
│  - Tooltip on hover with description                        │
└─────────────────────────────────────────────────────────────┘
```

### Signal Flow

**Enemy Death → Item Drop:**
```
Enemy dies → EventBus.enemy_killed(enemy_type, position)
           → LootSystem receives signal
           → LootSystem queries DataManager for drop_table
           → LootSystem rolls for each item (RNG vs drop_rate)
           → LootSystem spawns PickupItem instances at position
```

**Item Pickup → Inventory:**
```
Player overlaps PickupItem Area2D → PickupItem detects collision
                                  → PickupItem plays sound/effect
                                  → EventBus.item_picked_up(item_id)
                                  → Player_Inventory.add_item(item_id, quantity)
                                  → EventBus.inventory_changed()
                                  → Inventory_UI refreshes display
                                  → PickupItem.queue_free()
```

### Collision Layers

- **Layer 1**: Player (existing)
- **Layer 2**: Enemies (existing)
- **Layer 3**: Pickups (new)
  - PickupItem Area2D uses layer 3
  - Player collision area monitors layer 3

## Components and Interfaces

### 1. LootSystem (Autoload)

**Responsibilities:**
- Listen to `enemy_killed` signal
- Query drop tables from DataManager
- Determine which items to drop (RNG)
- Spawn PickupItem instances
- Manage active pickup count
- Handle spawn positioning with offset

**Public Interface:**
```gdscript
class_name LootSystem
extends Node

const MAX_ACTIVE_PICKUPS: int = 50
const PICKUP_ITEM_SCENE = preload("res://scenes/items/PickupItem.tscn")

var active_pickups: int = 0
var pickup_mode: String = "automatic"  # or "manual"

func _ready() -> void
func _on_enemy_killed(enemy_type: String, position: Vector2) -> void
func spawn_loot(enemy_type: String, position: Vector2) -> void
func get_drop_table(enemy_type: String) -> Array
func roll_for_drops(drop_table: Array) -> Array
func spawn_pickup_item(item_id: String, quantity: int, position: Vector2) -> void
func get_offset_position(base_position: Vector2, index: int) -> Vector2
func _on_pickup_collected() -> void
func _on_pickup_despawned() -> void
```

**Key Methods:**

- `spawn_loot(enemy_type, position)`: Main entry point for spawning loot
  - Queries drop table from DataManager
  - Rolls for each item in drop table
  - Spawns PickupItem for successful rolls
  - Applies offset to prevent overlap

- `roll_for_drops(drop_table)`: Determines which items drop
  - For each entry in drop_table:
    - Roll random float 0.0-1.0
    - If roll <= drop_rate, item drops
    - Roll quantity between min_quantity and max_quantity
  - Returns array of {item_id, quantity} dictionaries

- `get_offset_position(base_position, index)`: Calculates spawn position
  - Uses circular offset pattern
  - Radius: 10-30 pixels from center
  - Angle: evenly distributed based on index

### 2. PickupItem (Scene)

**Scene Structure:**
```
PickupItem (Node2D)
├── Area2D (collision detection)
│   └── CollisionShape2D (CircleShape2D, radius 16)
├── Visual (ColorRect, size 16x16)
└── DespawnTimer (Timer, 60 seconds)
```

**Script Interface:**
```gdscript
class_name PickupItem
extends Node2D

@export var item_id: String = ""
@export var quantity: int = 1

@onready var area: Area2D = $Area2D
@onready var visual: ColorRect = $Visual
@onready var despawn_timer: Timer = $DespawnTimer

var is_highlighted: bool = false
var player_in_range: bool = false

func _ready() -> void
func setup(p_item_id: String, p_quantity: int) -> void
func _on_area_entered(body: Node2D) -> void
func _on_area_exited(body: Node2D) -> void
func collect() -> void
func play_pickup_effect() -> void
func _on_despawn_timer_timeout() -> void
func highlight() -> void
func unhighlight() -> void
```

**Key Behaviors:**

- **Automatic Pickup Mode**: Collects immediately when player enters Area2D
- **Manual Pickup Mode**: Shows prompt, waits for interact key press
- **Highlight Effect**: Color modulation (1.2x brightness) when player nearby
- **Idle Animation**: Subtle float/pulse using Tween
- **Despawn**: Fades out and removes self after 60 seconds

### 3. Player_Inventory (Existing, Enhanced)

**Enhanced Methods:**
```gdscript
func add_item(item_id: String, quantity: int = 1) -> bool:
    # Check if item exists in inventory
    # If exists: increment quantity
    # If not exists and space available: add new entry
    # If inventory full: return false
    # Emit inventory_changed signal
    # Return true on success
```

**Inventory Data Structure:**
```gdscript
var inventory: Array[Dictionary] = [
    {"id": "chrono_dust", "quantity": 5},
    {"id": "health_potion", "quantity": 2}
]
```

### 4. Inventory_UI (Existing, Enhanced)

**Enhanced Methods:**
```gdscript
func _on_inventory_changed() -> void:
    # Clear existing item displays
    # For each item in Player_Inventory.inventory:
    #   - Get item data from DataManager
    #   - Create item display (ColorRect + Label)
    #   - Add to grid container
    #   - Connect hover signals for tooltip

func show_tooltip(item_id: String) -> void:
    # Get item data from DataManager
    # Display tooltip with name and description

func hide_tooltip() -> void:
    # Hide tooltip panel
```

**UI Layout:**
```
Inventory Panel (Control)
├── Background (ColorRect)
├── Title (Label: "Inventory")
├── GridContainer (columns: 6)
│   ├── ItemSlot (Panel) x N
│   │   ├── Icon (ColorRect)
│   │   └── Quantity (Label)
└── Tooltip (Panel, initially hidden)
    ├── ItemName (Label)
    └── ItemDescription (Label)
```

### 5. DataManager (Existing, Enhanced)

**Enhanced Methods:**
```gdscript
func get_drop_table(enemy_id: String) -> Array:
    # Get enemy data
    # Return loot_table array
    # Return empty array if enemy not found

func get_item_data(item_id: String) -> Dictionary:
    # Already implemented
    # Returns item properties from items.json
```

## Data Models

### Drop Table Structure (in enemies.json)

```json
{
  "slime_basic": {
    "id": "slime_basic",
    "name": "Basic Slime",
    "max_hp": 50,
    "loot_table": [
      {
        "item_id": "chrono_dust",
        "chance": 0.3,
        "quantity": [1, 3]
      },
      {
        "item_id": "health_potion",
        "chance": 0.1,
        "quantity": [1, 1]
      }
    ]
  }
}
```

**Drop Table Entry:**
- `item_id` (String): Item identifier matching items.json
- `chance` (Float): Drop probability (0.0 to 1.0)
- `quantity` (Array[int, int]): [min, max] quantity range

### Item Data Structure (in items.json)

```json
{
  "chrono_dust": {
    "id": "chrono_dust",
    "name": "Chrono Dust",
    "type": "material",
    "description": "Mysterious dust that bends time. Used for crafting.",
    "icon_path": "res://assets/sprites/ui/item_chrono_dust.png",
    "icon_color": "#00FFFF",
    "stack_size": 99,
    "rarity": "uncommon"
  }
}
```

**Item Properties:**
- `id` (String): Unique identifier
- `name` (String): Display name
- `type` (String): Item category (material, consumable, etc.)
- `description` (String): Tooltip text
- `icon_path` (String): Path to sprite (future)
- `icon_color` (String): Hex color for ColorRect placeholder
- `stack_size` (int): Maximum stack quantity
- `rarity` (String): Common, uncommon, rare, etc.

### Inventory Data Structure

```gdscript
# Player_Inventory.inventory
var inventory: Array[Dictionary] = [
    {
        "id": "chrono_dust",
        "quantity": 5
    },
    {
        "id": "health_potion",
        "quantity": 2
    }
]
```

## Correctness Properties


*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property Reflection

After analyzing all acceptance criteria, I identified the following testable properties. Many criteria are integration tests, smoke tests, or examples rather than universal properties. The properties below represent the core universal behaviors that should hold across all valid inputs.

**Redundancy Analysis:**
- Properties 1.4 and 11.1 both test item positioning - combined into Property 1
- Properties 5.2, 5.3, 5.4 all test pickup behavior - combined into Property 4
- Properties 7.3 and 7.4 both test inventory addition - combined into Property 6
- Properties 3.3 and 3.4 both test PickupItem data storage - combined into Property 2

### Property 1: Drop Rate Convergence

*For any* drop table configuration with drop rates between 0.0 and 1.0, when rolling for drops across many iterations (n ≥ 1000), the actual drop frequency SHALL converge to the configured drop rate within statistical bounds (±5%).

**Validates: Requirements 1.3, 1.6**

### Property 2: Item Spawn Positioning

*For any* enemy death position and list of items to drop, all spawned PickupItem instances SHALL appear at positions within 30 pixels of the death position, and each PickupItem SHALL correctly store its assigned item_id and quantity.

**Validates: Requirements 1.4, 3.3, 3.4, 11.1**

### Property 3: Multiple Item Offset

*For any* set of multiple items dropped from a single enemy (n > 1), all spawned PickupItem instances SHALL have unique positions with minimum separation of 10 pixels to prevent overlap.

**Validates: Requirements 1.5, 11.2**

### Property 4: Quantity Range Compliance

*For any* drop table entry with min_quantity and max_quantity values, the dropped item quantity SHALL always be within the inclusive range [min_quantity, max_quantity].

**Validates: Requirements 1.7**

### Property 5: Empty Drop Table Handling

*For any* enemy type that does not exist in the drop table configuration, the Loot_System SHALL spawn zero PickupItem instances when that enemy is killed.

**Validates: Requirements 2.3**

### Property 6: Pickup Collection Behavior

*For any* PickupItem with item_id and quantity, when collected by the player, the system SHALL emit the item_picked_up signal with the correct item_id, remove the PickupItem from the scene tree, and add the item to Player_Inventory with the specified quantity.

**Validates: Requirements 5.1, 5.2, 5.3, 5.4**

### Property 7: Highlight State Transitions

*For any* PickupItem, when the player enters its Area2D the highlight state SHALL become true, and when the player exits its Area2D the highlight state SHALL become false.

**Validates: Requirements 4.1, 4.3**

### Property 8: Manual Pickup Proximity Selection

*For any* set of PickupItems within interaction range when manual pickup mode is enabled, pressing the interact key SHALL collect the PickupItem with the minimum distance to the player.

**Validates: Requirements 6.2**

### Property 9: Inventory Stacking

*For any* item_id that already exists in the Player_Inventory, adding additional quantity of that item SHALL increment the existing entry's quantity rather than creating a new entry.

**Validates: Requirements 7.3**

### Property 10: Inventory New Entry Creation

*For any* item_id that does not exist in the Player_Inventory and when inventory size is below MAX_INVENTORY_SIZE, adding that item SHALL create a new inventory entry with the specified quantity.

**Validates: Requirements 7.4**

### Property 11: Inventory Capacity Enforcement

*For any* Player_Inventory at maximum capacity (30 unique items), attempting to add a new unique item SHALL return false, and the corresponding PickupItem SHALL remain in the game world.

**Validates: Requirements 7.5**

### Property 12: Inventory Change Signal

*For any* successful item addition to Player_Inventory (either stacking or new entry), the inventory_changed signal SHALL be emitted exactly once.

**Validates: Requirements 7.6**

### Property 13: Item Data Retrieval

*For any* valid item_id that exists in the loaded Item_Data, requesting item data from DataManager SHALL return a Dictionary containing at minimum the fields: id, name, description, type, and icon_color.

**Validates: Requirements 9.3**

### Property 14: Invalid Item Handling

*For any* item_id that does not exist in the loaded Item_Data, requesting item data from DataManager SHALL return an empty Dictionary or null without causing errors.

**Validates: Requirements 9.4**

### Property 15: Pickup Effect Spawning

*For any* PickupItem collection event at position P, a pickup effect SHALL be spawned at position P (within 5 pixels tolerance).

**Validates: Requirements 10.2**

### Property 16: Missing Audio Graceful Handling

*For any* PickupItem collection when the audio file does not exist, the collection SHALL complete successfully without throwing errors or exceptions.

**Validates: Requirements 10.5**

### Property 17: Despawn Timer

*For any* PickupItem that remains uncollected, the item SHALL automatically remove itself from the scene tree after 60 seconds (±1 second tolerance).

**Validates: Requirements 12.1**

### Property 18: Maximum Pickup Limit

*For any* game state where 50 PickupItem instances are active, attempting to spawn additional PickupItems SHALL not create new instances until the active count drops below 50.

**Validates: Requirements 12.2, 12.3**

### Property 19: Limit Warning Emission

*For any* spawn attempt when the active PickupItem count is at maximum (50), a warning message SHALL be logged to the console.

**Validates: Requirements 12.5**

### Property 20: UI Display Text Format

*For any* item in the inventory with item_id and quantity Q, the Inventory_UI display text SHALL contain both the item name (from Item_Data) and the quantity in the format "Name xQ".

**Validates: Requirements 8.2**

### Property 21: Tooltip Data Accuracy

*For any* item displayed in Inventory_UI, hovering over the item SHALL display a tooltip containing the item's name and description as retrieved from DataManager.

**Validates: Requirements 8.5**

### Property 22: Distinct Item Colors

*For any* two different item types (item_id1 ≠ item_id2), their icon_color values in Item_Data SHALL be different to ensure visual distinction.

**Validates: Requirements 8.4**

## Error Handling

### Loot System Errors

**Missing Drop Table:**
- **Scenario**: Enemy type not found in drop table
- **Handling**: Log warning, spawn no items, continue execution
- **User Impact**: No loot drops, but game continues normally

**Invalid Drop Rate:**
- **Scenario**: Drop rate < 0.0 or > 1.0 in JSON
- **Handling**: Clamp to valid range [0.0, 1.0], log warning
- **User Impact**: Drop rate adjusted to valid value

**Maximum Pickup Limit Reached:**
- **Scenario**: 50 active pickups already exist
- **Handling**: Skip spawning new items, log warning to console
- **User Impact**: No new loot appears until existing items are collected/despawn

**Invalid Spawn Position:**
- **Scenario**: Spawn position is in impassable terrain
- **Handling**: Attempt to find nearest valid position within 50 pixels
- **Fallback**: If no valid position found, spawn at enemy position anyway
- **User Impact**: Item may spawn in wall (rare edge case)

### Pickup Item Errors

**Missing Item Data:**
- **Scenario**: item_id not found in items.json
- **Handling**: Use default placeholder (gray ColorRect, "Unknown Item")
- **User Impact**: Item appears but with generic appearance

**Missing Audio File:**
- **Scenario**: Pickup sound file doesn't exist
- **Handling**: Skip audio playback, continue with collection
- **User Impact**: No sound, but pickup works normally

**Collision Detection Failure:**
- **Scenario**: Area2D not properly configured
- **Handling**: Log error, item becomes uncollectable
- **User Impact**: Item visible but cannot be picked up (requires fix)

### Inventory Errors

**Inventory Full:**
- **Scenario**: 30 unique items already in inventory, new item type drops
- **Handling**: Return false from add_item(), PickupItem remains in world
- **User Impact**: Player must collect or use items to make space

**Invalid Item ID:**
- **Scenario**: Attempting to add item with empty or null item_id
- **Handling**: Log error, reject addition, return false
- **User Impact**: Item not added to inventory

**Quantity Overflow:**
- **Scenario**: Adding items would exceed stack_size limit
- **Handling**: Cap quantity at stack_size, log warning
- **User Impact**: Excess items not added (future: could spawn remainder)

### UI Errors

**Missing Item Data for Display:**
- **Scenario**: Inventory contains item_id not in items.json
- **Handling**: Display "Unknown Item" with quantity
- **User Impact**: Item shows but with generic name

**Tooltip Data Missing:**
- **Scenario**: Item has no description in items.json
- **Handling**: Display name only, skip description
- **User Impact**: Tooltip shows but with less information

## Testing Strategy

### Unit Tests

Unit tests will focus on specific examples, edge cases, and error conditions:

**LootSystem Tests:**
- Test drop table lookup for known enemy types (slime_basic, fire_imp)
- Test empty drop table handling (unknown enemy type)
- Test maximum pickup limit enforcement (spawn 50, verify 51st fails)
- Test spawn position offset calculation (verify 10-30 pixel range)
- Test invalid drop rate clamping (negative, >1.0)

**PickupItem Tests:**
- Test item_id and quantity storage
- Test highlight state changes (player enter/exit)
- Test despawn timer (verify removal after 60 seconds)
- Test collection signal emission
- Test missing audio handling

**Player_Inventory Tests:**
- Test item stacking (add same item twice)
- Test new entry creation (add different items)
- Test inventory full rejection (30 unique items)
- Test invalid item_id rejection
- Test quantity overflow capping

**Inventory_UI Tests:**
- Test display text format ("Chrono Dust x5")
- Test tooltip display (name + description)
- Test grid layout population
- Test missing item data handling

**DataManager Tests:**
- Test item data retrieval (valid item_ids)
- Test invalid item_id handling (return empty dict)
- Test drop table retrieval (valid enemy types)

### Property-Based Tests

Property-based tests will verify universal properties across randomized inputs using **GdUnit4** (Godot's property-based testing framework):

**Configuration:**
- Minimum 100 iterations per property test
- Each test tagged with: `# Feature: loot-and-progression, Property N: [property text]`

**Property Test Suite:**

1. **Drop Rate Convergence** (Property 1)
   - Generate random drop tables with rates 0.0-1.0
   - Run 1000 iterations per configuration
   - Verify actual drop frequency within ±5% of configured rate

2. **Item Spawn Positioning** (Property 2)
   - Generate random death positions
   - Generate random item lists (1-5 items)
   - Verify all spawned items within 30 pixels of death position
   - Verify item_id and quantity stored correctly

3. **Multiple Item Offset** (Property 3)
   - Generate random item counts (2-10 items)
   - Verify all items have unique positions
   - Verify minimum 10 pixel separation between any two items

4. **Quantity Range Compliance** (Property 4)
   - Generate random min/max quantity ranges
   - Roll for drops 100 times
   - Verify all quantities within [min, max]

5. **Empty Drop Table Handling** (Property 5)
   - Generate random non-existent enemy types
   - Verify zero items spawned

6. **Pickup Collection Behavior** (Property 6)
   - Generate random item_id and quantity
   - Simulate collection
   - Verify signal emission, scene removal, inventory addition

7. **Highlight State Transitions** (Property 7)
   - Generate random PickupItems
   - Simulate player enter/exit
   - Verify highlight state changes

8. **Manual Pickup Proximity Selection** (Property 8)
   - Generate random item positions (3-5 items)
   - Verify closest item selected

9-12. **Inventory Properties** (Properties 9-12)
   - Test stacking, new entries, capacity, signals
   - Generate random item sequences
   - Verify correct behavior

13-14. **Data Retrieval Properties** (Properties 13-14)
   - Test valid and invalid item_ids
   - Verify correct data returned or graceful failure

15-19. **Pickup System Properties** (Properties 15-19)
   - Test effect spawning, audio handling, despawn, limits
   - Generate random scenarios
   - Verify correct behavior

20-22. **UI Properties** (Properties 20-22)
   - Test display text, tooltips, colors
   - Generate random inventory states
   - Verify correct UI rendering

### Integration Tests

Integration tests will verify system interactions:

- **Enemy Death → Loot Drop**: Kill enemy, verify items spawn
- **Pickup → Inventory → UI**: Collect item, verify inventory updates, verify UI refreshes
- **Manual Pickup Mode**: Enable manual mode, verify interact key works
- **Automatic Pickup Mode**: Enable auto mode, verify walk-over collection
- **Terrain Collision**: Spawn items near walls, verify position adjustment
- **Y-Sort Rendering**: Spawn items at different Y positions, verify depth sorting
- **Effect Manager Integration**: Collect items, verify effects spawn via EffectManager
- **Audio Integration**: Collect items, verify sounds play (or handle missing audio)

### Performance Tests

- **50 Active Pickups**: Spawn 50 items, verify no performance degradation
- **Rapid Spawning**: Kill 10 enemies quickly, verify all loot spawns correctly
- **Despawn Cleanup**: Spawn 50 items, wait 60 seconds, verify all despawn
- **Inventory Full Scenario**: Fill inventory, collect 10 more items, verify items remain in world

### Test Execution

**Unit Tests:**
- Run via GdUnit4 test runner
- Target: 100% coverage of public methods
- Execution time: < 5 seconds

**Property Tests:**
- Run via GdUnit4 with property-based testing addon
- 100 iterations minimum per property
- Execution time: < 30 seconds

**Integration Tests:**
- Run in test scenes with mock player/enemies
- Manual verification for visual/audio elements
- Execution time: < 2 minutes

**Performance Tests:**
- Run in full game scene
- Monitor FPS and memory usage
- Target: 60 FPS with 50 active pickups

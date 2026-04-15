# Task 1: EventBus Signals & ResourceManager Autoload

## Overview
Set up the foundation for HUD system by adding new signals to EventBus and creating ResourceManager autoload to track player resources.

---

## Task 1.1: Add New Signals to EventBus

### What Was Done
Added 5 new signals to `autoloads/EventBus.gd`:

1. **player_mana_changed(current_mana: int, max_mana: int)**
   - Emitted when player mana/stamina changes
   - Used by ManaBar component to update display

2. **chrono_rift_cooldown_started(duration: float)**
   - Emitted when Chrono Rift ability is used
   - Passes cooldown duration in seconds
   - Used by ChronoRiftIndicator to start countdown

3. **chrono_rift_ready()**
   - Emitted when Chrono Rift cooldown completes
   - Used by ChronoRiftIndicator to show "READY" state

4. **resource_changed(resource_type: String, amount: int)**
   - Emitted when any resource changes (gold, wood, stone, etc.)
   - Passes resource type and new amount
   - Used by ResourceDisplay component

5. **hotbar_slot_changed(slot_index: int, item_data: Dictionary)**
   - Emitted when hotbar slot is assigned/cleared
   - Passes slot index (0-4) and item data
   - Used by Hotbar component

### File Modified
- `ChronoRiftGame/autoloads/EventBus.gd`

### Code Added
```gdscript
# Player signals
signal player_mana_changed(current_mana: int, max_mana: int)

# Chrono Rift signals
signal chrono_rift_cooldown_started(duration: float)
signal chrono_rift_ready()

# Resource signals
signal resource_changed(resource_type: String, amount: int)

# Item/Inventory signals
signal hotbar_slot_changed(slot_index: int, item_data: Dictionary)
```

### Testing
1. Open `autoloads/EventBus.gd` in Godot
2. Verify all 5 signals are present
3. Test signal emission:
```gdscript
# In any script
func test_signals():
    EventBus.player_mana_changed.emit(50, 100)
    EventBus.resource_changed.emit("gold", 100)
    print("Signals emitted successfully")
```

---

## Task 1.2: Create ResourceManager Autoload

### What Was Done
Created a new autoload singleton to manage player resources (fire_shard, gold, stone, wood, meat).

### Features
- **Resource Tracking**: Dictionary storing 5 resource types
- **Get Resource**: `get_resource(type: String) -> int`
- **Add Resource**: `add_resource(type: String, amount: int)` - can be negative to subtract
- **Set Resource**: `set_resource(type: String, amount: int)` - set exact amount
- **Has Resource**: `has_resource(type: String, amount: int) -> bool` - check if enough
- **Spend Resource**: `spend_resource(type: String, amount: int) -> bool` - returns success
- **Signal Emission**: Emits `EventBus.resource_changed` on every change
- **Clamping**: Resources cannot go below 0

### Files Created
- `ChronoRiftGame/scripts/autoloads/resource_manager.gd`

### Autoload Registration
Added to `project.godot`:
```ini
[autoload]
ResourceManager="*res://scripts/autoloads/resource_manager.gd"
```

### Usage Examples

**Add resources:**
```gdscript
ResourceManager.add_resource("gold", 50)
ResourceManager.add_resource("fire_shard", 3)
```

**Get resource amount:**
```gdscript
var gold = ResourceManager.get_resource("gold")
print("Current gold: ", gold)
```

**Check if has enough:**
```gdscript
if ResourceManager.has_resource("wood", 10):
    print("Enough wood to craft!")
```

**Spend resources:**
```gdscript
if ResourceManager.spend_resource("gold", 30):
    print("Purchase successful!")
else:
    print("Not enough gold!")
```

**Set exact amount:**
```gdscript
ResourceManager.set_resource("stone", 100)
```

### Testing in Godot

**Step 1: Verify Autoload Registration**
1. Open Godot Editor
2. Go to **Project → Project Settings → Autoload**
3. Verify **ResourceManager** is in the list
4. If not, click **Add** and browse to `res://scripts/autoloads/resource_manager.gd`

**Step 2: Test Resource Operations**
1. Open any scene (e.g., `Prototype_World.tscn`)
2. Add test script to any node:
```gdscript
extends Node

func _ready():
    # Wait for autoloads to initialize
    await get_tree().create_timer(0.5).timeout
    
    # Test add resource
    ResourceManager.add_resource("gold", 100)
    ResourceManager.add_resource("fire_shard", 5)
    
    # Test get resource
    print("Gold: ", ResourceManager.get_resource("gold"))
    print("Fire Shard: ", ResourceManager.get_resource("fire_shard"))
    
    # Test spend resource
    if ResourceManager.spend_resource("gold", 30):
        print("Spent 30 gold, remaining: ", ResourceManager.get_resource("gold"))
    
    # Test has resource
    if ResourceManager.has_resource("fire_shard", 3):
        print("Has at least 3 fire shards!")
```

3. Run scene (F6)
4. Check **Output** console

**Expected Output:**
```
[ResourceManager] Initialized with resources: {fire_shard:0, gold:0, stone:0, wood:0, meat:0}
[ResourceManager] gold changed: 100 (delta: +100)
[ResourceManager] fire_shard changed: 5 (delta: +5)
Gold: 100
Fire Shard: 5
[ResourceManager] gold changed: 70 (delta: -30)
Spent 30 gold, remaining: 70
Has at least 3 fire shards!
```

**Step 3: Test Signal Emission**
```gdscript
extends Node

func _ready():
    # Connect to signal
    EventBus.resource_changed.connect(_on_resource_changed)
    
    await get_tree().create_timer(0.5).timeout
    
    # Add resource (should trigger signal)
    ResourceManager.add_resource("gold", 50)

func _on_resource_changed(resource_type: String, amount: int):
    print("Signal received: %s = %d" % [resource_type, amount])
```

**Expected Output:**
```
[ResourceManager] gold changed: 50 (delta: +50)
Signal received: gold = 50
```

---

## Integration Points

### Future Tasks Using These Systems

**EventBus Signals:**
- Task 4: ManaBar listens to `player_mana_changed`
- Task 5: ChronoRiftIndicator listens to `chrono_rift_cooldown_started` and `chrono_rift_ready`
- Task 6: Hotbar listens to `hotbar_slot_changed`
- Task 8: ResourceDisplay listens to `resource_changed`

**ResourceManager:**
- Task 8: ResourceDisplay queries `ResourceManager.get_resource()` for all 5 resources
- Task 10: HUD controller connects to `EventBus.resource_changed` signal
- Future: Crafting system, shop system, building system will use ResourceManager

---

## Common Issues

### Issue 1: ResourceManager not found
**Symptom:** `Invalid get index 'ResourceManager' (on base: 'SceneTree')`
**Solution:**
- Restart Godot Editor after adding autoload
- Verify autoload path: `res://scripts/autoloads/resource_manager.gd`
- Check autoload is enabled (checkbox checked)

### Issue 2: Signals not emitting
**Symptom:** `resource_changed` signal not received
**Solution:**
- Verify EventBus has the signal defined
- Check signal connection: `EventBus.resource_changed.connect(callback)`
- Ensure callback function signature matches: `func callback(type: String, amount: int)`

### Issue 3: Negative resources
**Symptom:** Resources go below 0
**Solution:**
- ResourceManager automatically clamps to 0
- If seeing negative values, check if using `resources` dictionary directly (don't do this)
- Always use `add_resource()` or `set_resource()` methods

---

## Verification Checklist

- [ ] EventBus.gd has 5 new signals
- [ ] ResourceManager.gd file exists
- [ ] ResourceManager registered in project.godot autoload section
- [ ] ResourceManager initializes on game start (check Output console)
- [ ] Can add resources via `add_resource()`
- [ ] Can get resources via `get_resource()`
- [ ] Can spend resources via `spend_resource()`
- [ ] Resources clamp to minimum 0
- [ ] `EventBus.resource_changed` signal emits on resource changes
- [ ] No errors in Output console

---

## Next Task
**Task 2:** Update HUD scene structure with StatsPanel, Hotbar, and InfoPanel containers.

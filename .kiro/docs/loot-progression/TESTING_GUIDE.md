# Loot & Progression System - Testing Guide

## 🎯 Testing Overview

This guide will walk you through testing the Loot & Progression System step by step. We'll start with the simplest tests and gradually build up to the full system.

## ⚠️ Prerequisites

Before testing, you MUST complete these manual setup steps in Godot Editor:

### 1. Register LootSystem as Autoload (REQUIRED)

1. Open Godot Editor
2. Go to **Project → Project Settings → Autoload**
3. Click folder icon, navigate to `res://scripts/systems/loot_system.gd`
4. Node Name: `LootSystem`
5. Click **Add**
6. Verify order: EventBus → GameManager → DataManager → **LootSystem**

### 2. Create PickupItem Scene (REQUIRED)

Follow `PICKUP_ITEM_SETUP.md` to create the scene. Quick version:

1. New Scene → Node2D root → name "PickupItem"
2. Attach script: `res://scripts/items/pickup_item.gd`
3. Add Area2D child (collision layer 3)
4. Add CollisionShape2D → CircleShape2D (radius 16)
5. Add ColorRect child → name "Visual" → size 16x16, position (-8, -8)
6. Add Timer child → name "DespawnTimer" → wait_time 60, one_shot
7. Add Label child → name "InteractPrompt" → text "Press E", position (0, -20), visible off
8. Save as: `res://scenes/items/PickupItem.tscn`

### 3. Update Enemy to Emit Signal (REQUIRED)

Open `scripts/enemies/base_enemy.gd` and add:

```gdscript
# At top of file
@export var enemy_type: String = "slime_basic"  # or "earth_golem"

# In take_damage() or DeadState, when HP reaches 0:
EventBus.enemy_killed.emit(enemy_type, global_position)
```

---

## 🧪 Test Phase 1: LootSystem Initialization

### Test 1.1: Verify Autoload

1. Open Godot Editor
2. Open any script
3. Add this test code:

```gdscript
func _ready():
    print("LootSystem exists: ", LootSystem != null)
    print("Pickup mode: ", LootSystem.pickup_mode)
```

4. Run the scene (F5)
5. **Expected Output**:
   ```
   LootSystem initialized - Pickup mode: automatic
   LootSystem exists: true
   Pickup mode: automatic
   ```

✅ **Pass Criteria**: No errors, LootSystem accessible

---

## 🧪 Test Phase 2: Data Loading

### Test 2.1: Verify Item Data

1. Open Godot Script Editor
2. Create test script:

```gdscript
func _ready():
    var chrono_dust = DataManager.get_item_data("chrono_dust")
    print("Chrono Dust: ", chrono_dust)
    print("Color: ", chrono_dust.get("icon_color", "MISSING"))
```

3. **Expected Output**:
   ```
   Chrono Dust: {id: chrono_dust, name: Chrono Dust, ...}
   Color: #00FFFF
   ```

### Test 2.2: Verify Drop Tables

```gdscript
func _ready():
    var slime_drops = DataManager.get_drop_table("slime_basic")
    print("Slime drops: ", slime_drops)
    print("Drop count: ", slime_drops.size())
```

3. **Expected Output**:
   ```
   Slime drops: [{item_id: chrono_dust, chance: 0.3, ...}, ...]
   Drop count: 2
   ```

✅ **Pass Criteria**: Data loads correctly, no errors

---

## 🧪 Test Phase 3: Manual Loot Spawning

### Test 3.1: Spawn Single Item

1. Open `Prototype_World.tscn`
2. Add test script to world:

```gdscript
func _ready():
    await get_tree().create_timer(2.0).timeout
    print("Spawning test item...")
    LootSystem.spawn_pickup_item("chrono_dust", 3, Vector2(400, 300))
```

3. Run scene (F5)
4. **Expected**:
   - After 2 seconds, cyan square appears at (400, 300)
   - Item floats/pulses
   - Console shows: "Spawning test item..."

### Test 3.2: Spawn Multiple Items

```gdscript
func _ready():
    await get_tree().create_timer(2.0).timeout
    for i in range(5):
        var pos = Vector2(400 + i * 30, 300)
        LootSystem.spawn_pickup_item("health_potion", 1, pos)
```

4. **Expected**:
   - 5 red squares appear in a line
   - All items animate independently

✅ **Pass Criteria**: Items spawn, animate, have correct colors

---

## 🧪 Test Phase 4: Enemy Death → Loot Drop

### Test 4.1: Kill Enemy and Check Loot

1. Make sure enemy has `enemy_type` variable set
2. Make sure enemy emits `EventBus.enemy_killed` on death
3. Open `Prototype_World.tscn`
4. Add SlimeBasic enemy to scene
5. Run scene (F5)
6. Kill the enemy

7. **Expected**:
   - Items spawn at enemy death position
   - 30% chance for chrono_dust (cyan)
   - 10% chance for health_potion (red)
   - Items offset from each other if multiple drop
   - Console shows LootSystem activity

### Test 4.2: Kill Multiple Enemies

1. Add 5 enemies to scene
2. Kill them all
3. **Expected**:
   - Each enemy drops items independently
   - Items don't overlap (circular offset)
   - Maximum 50 items enforced

✅ **Pass Criteria**: Loot spawns on enemy death, drop rates work

---

## 🧪 Test Phase 5: Pickup (Automatic Mode)

### Test 5.1: Walk Over Item

1. Spawn an item manually or kill an enemy
2. Walk player over the item
3. **Expected**:
   - Item highlights when player gets close (brighter)
   - Item disappears when touched
   - Console shows: "Picked up X x item_name"
   - Pickup effect plays (if created)

### Test 5.2: Multiple Items

1. Spawn 5 items in a cluster
2. Walk through them
3. **Expected**:
   - All items collected as player touches them
   - Each pickup logged to console
   - Inventory updates for each item

✅ **Pass Criteria**: Items collected automatically, inventory updates

---

## 🧪 Test Phase 6: Inventory System

### Test 6.1: Check Inventory After Pickup

1. Pick up 3 chrono_dust
2. Pick up 2 health_potion
3. Add debug code:

```gdscript
func _input(event):
    if event.is_action_pressed("ui_accept"):  # Space key
        var inv = get_node("/root/PlayerInventory")
        print("Inventory: ", inv.inventory)
```

4. Press Space after picking up items
5. **Expected Output**:
   ```
   Inventory: [{id: chrono_dust, quantity: 3}, {id: health_potion, quantity: 2}]
   ```

### Test 6.2: Item Stacking

1. Pick up 2 chrono_dust
2. Pick up 3 more chrono_dust
3. Check inventory
4. **Expected**:
   - Only ONE entry for chrono_dust
   - Quantity: 5

✅ **Pass Criteria**: Inventory tracks items, stacking works

---

## 🧪 Test Phase 7: Inventory UI (If Created)

### Test 7.1: Open Inventory

1. Pick up some items
2. Press **I** or **Tab**
3. **Expected**:
   - Inventory panel appears
   - Items shown in grid
   - Colors match items.json
   - Quantities shown as "xN"

### Test 7.2: Tooltips

1. Open inventory
2. Hover mouse over an item
3. **Expected**:
   - Tooltip appears near mouse
   - Shows item name and description
   - Tooltip follows mouse

✅ **Pass Criteria**: UI displays items, tooltips work

---

## 🧪 Test Phase 8: Manual Pickup Mode

### Test 8.1: Switch to Manual Mode

1. Add to world script:

```gdscript
func _ready():
    LootSystem.set_pickup_mode("manual")
```

2. Run scene, kill enemy
3. Walk near item
4. **Expected**:
   - Item highlights
   - "Press E" prompt appears
   - Item does NOT auto-collect

### Test 8.2: Press E to Collect

1. Walk near item
2. Press **E** key
3. **Expected**:
   - Item collected
   - Prompt disappears
   - Inventory updates

✅ **Pass Criteria**: Manual mode works, E key collects

---

## 🧪 Test Phase 9: Despawn Timer

### Test 9.1: Wait for Despawn

1. Spawn an item
2. Don't pick it up
3. Wait 60 seconds
4. **Expected**:
   - Item fades out after 60 seconds
   - Item disappears
   - No errors in console

✅ **Pass Criteria**: Items despawn after 60s

---

## 🧪 Test Phase 10: Performance & Limits

### Test 10.1: Spawn Many Items

1. Add test code:

```gdscript
func _ready():
    await get_tree().create_timer(2.0).timeout
    for i in range(60):
        var pos = Vector2(randf_range(200, 600), randf_range(200, 400))
        LootSystem.spawn_pickup_item("chrono_dust", 1, pos)
```

2. Run scene
3. **Expected**:
   - Only 50 items spawn
   - Console warning: "Maximum pickup limit reached"
   - No lag or errors

✅ **Pass Criteria**: Limit enforced, no performance issues

---

## 🎯 Full Integration Test

### Complete Gameplay Loop

1. Open `Prototype_World.tscn`
2. Add 5 enemies (mix of SlimeBasic and EarthGolem)
3. Run scene (F5)
4. **Test Sequence**:
   - Kill all enemies
   - Observe loot drops
   - Walk around collecting items
   - Open inventory (I key)
   - Check items are displayed
   - Hover for tooltips
   - Wait for some items to despawn
   - Kill more enemies
   - Collect more loot

5. **Expected Results**:
   - ✅ Enemies drop items on death
   - ✅ Items spawn with correct colors
   - ✅ Items animate (float/pulse)
   - ✅ Items highlight when player nearby
   - ✅ Items collected automatically
   - ✅ Inventory updates correctly
   - ✅ UI shows items with colors and quantities
   - ✅ Tooltips display item info
   - ✅ Items despawn after 60s
   - ✅ No errors in console
   - ✅ 60 FPS maintained

---

## 🐛 Common Issues & Solutions

### Issue: LootSystem not found
**Solution**: Register as autoload in Project Settings

### Issue: Items don't spawn
**Solution**: 
- Check enemy emits EventBus.enemy_killed
- Check enemy_type matches enemies.json
- Check console for errors

### Issue: Items spawn but can't pick up
**Solution**:
- Check player is in "player" group
- Check PickupItem Area2D on layer 3
- Check player has Area2D monitoring layer 3

### Issue: Inventory doesn't update
**Solution**:
- Check EventBus.item_picked_up signal
- Check Player_Inventory is autoload
- Check console for errors

### Issue: Wrong item colors
**Solution**:
- Check items.json has icon_color field
- Check DataManager loads items.json
- Check PickupItem setup() method

---

## ✅ Testing Checklist

Complete this checklist to verify full system functionality:

- [ ] LootSystem autoload registered
- [ ] PickupItem scene created
- [ ] Enemy emits enemy_killed signal
- [ ] Items spawn on enemy death
- [ ] Items have correct colors
- [ ] Items animate (float/pulse)
- [ ] Items highlight when player nearby
- [ ] Automatic pickup works
- [ ] Manual pickup works (E key)
- [ ] Inventory tracks items correctly
- [ ] Item stacking works
- [ ] Inventory UI displays items
- [ ] Tooltips show item info
- [ ] Despawn timer works (60s)
- [ ] Maximum pickup limit enforced (50)
- [ ] No errors in console
- [ ] 60 FPS maintained with many items

---

## 🎉 Success Criteria

The Loot & Progression System is fully functional when:

1. ✅ Enemies drop items based on drop tables
2. ✅ Items spawn with animations and correct visuals
3. ✅ Player can collect items (automatic or manual)
4. ✅ Inventory tracks and stacks items correctly
5. ✅ UI displays items with colors and tooltips
6. ✅ System handles 50+ items without performance issues
7. ✅ No errors during normal gameplay

---

**Ready to test!** Start with Phase 1 and work your way through each phase. Good luck! 🚀


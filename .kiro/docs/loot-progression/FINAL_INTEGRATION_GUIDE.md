# Loot & Progression System - Final Integration Guide

## Overview

This guide walks through the final steps to integrate all components of the Loot & Progression System and test the complete flow.

## Prerequisites

Before starting, ensure you have completed:
- [ ] Created PickupItem scene (`scenes/items/PickupItem.tscn`)
- [ ] Registered LootSystem as autoload
- [ ] Created pickup_effect scene (`scenes/effects/pickup_effect.tscn`)
- [ ] Updated Inventory_UI scene (`scenes/ui/Inventory_UI.tscn`)

## Step 1: Verify Autoload Registration

### Check Project Settings

1. Go to **Project → Project Settings → Autoload**
2. Verify this order:
   - EventBus
   - GameManager
   - DataManager
   - **LootSystem** (should be here)

3. If LootSystem is missing:
   - Path: `res://scripts/systems/loot_system.gd`
   - Node Name: `LootSystem`
   - Click **Add**

## Step 2: Update EventBus Signals

EventBus should have these signals (already updated):
```gdscript
signal enemy_killed(enemy_type: String, position: Vector2)
signal item_picked_up(item_id: String, quantity: int)
signal inventory_changed()
signal spawn_effect(effect_name: String, position: Vector2)
```

## Step 3: Update Enemy Death to Emit Signal

### For BaseEnemy

1. Open `scripts/enemies/base_enemy.gd`
2. Find the death handling code (in DeadState or take_damage method)
3. Ensure it emits the signal:

```gdscript
# In DeadState enter() or when HP reaches 0
EventBus.enemy_killed.emit(enemy_type, global_position)
```

4. Make sure each enemy has an `enemy_type` variable:

```gdscript
# In slime_basic.gd
@export var enemy_type: String = "slime_basic"

# In earth_golem.gd
@export var enemy_type: String = "earth_golem"
```

## Step 4: Configure Player for Pickup Detection

### Add Pickup Detection Area

1. Open player scene (`scenes/player/Player.tscn` or similar)
2. If player doesn't have an Area2D for pickup detection:
   - Add **Area2D** child node
   - Add **CollisionShape2D** with CircleShape2D (radius 32)
   - Set Area2D **Collision → Mask** to Layer 3 (pickups)

3. The PickupItem will detect player via `is_in_group("player")`
4. Make sure player is in "player" group:
   - Select player root node
   - **Node → Groups** → Add "player"

## Step 5: Update EffectManager

1. Open `scripts/effects/effect_manager.gd`
2. Add pickup_effect to EFFECTS dictionary:

```gdscript
const EFFECTS = {
	"hit_effect": preload("res://scenes/effects/HitEffect.tscn"),
	"pickup_effect": preload("res://scenes/effects/pickup_effect.tscn")
}
```

3. Ensure EffectManager listens to EventBus.spawn_effect signal:

```gdscript
func _ready():
	EventBus.spawn_effect.connect(_on_spawn_effect)

func _on_spawn_effect(effect_name: String, position: Vector2):
	spawn_effect(effect_name, position)
```

## Step 6: Add Inventory_UI to Main Scene

1. Open `Prototype_World.tscn`
2. Add Inventory_UI as a child:
   - Right-click root → **Instantiate Child Scene**
   - Select `scenes/ui/Inventory_UI.tscn`
3. Make sure it's a child of the root or a CanvasLayer
4. Inventory_UI should be initially hidden (script handles this)

## Step 7: Configure Input Map

1. Go to **Project → Project Settings → Input Map**
2. Verify these actions exist:
   - `open_inventory`: I key, Tab key
   - `interact`: E key
3. If missing, add them

## Step 8: Test Full Flow

### Test 1: Enemy Death → Loot Spawn

1. Run `Prototype_World.tscn` (F5)
2. Kill a SlimeBasic enemy
3. **Expected**:
   - Items spawn at enemy death position
   - Items have colors (cyan for chrono_dust, red for health_potion)
   - Items float/pulse animation
   - Console shows: "LootSystem initialized"

### Test 2: Automatic Pickup

1. Walk player over a spawned item
2. **Expected**:
   - Item highlights when player nearby
   - Item disappears when touched
   - Pickup effect (yellow particles) plays
   - Console shows: "Picked up X x item_name"

### Test 3: Inventory Display

1. Pick up 2-3 items
2. Press **I** to open inventory
3. **Expected**:
   - Inventory panel appears
   - Items shown in grid with colors
   - Quantity shows as "xN"
   - Hover over item shows tooltip with name and description

### Test 4: Manual Pickup Mode

1. In console or script, run: `LootSystem.set_pickup_mode("manual")`
2. Kill an enemy
3. Walk near item
4. **Expected**:
   - "Press E" prompt appears
   - Item doesn't auto-collect
   - Press E to collect
   - Item collected successfully

### Test 5: Multiple Items

1. Kill 3-4 enemies quickly
2. **Expected**:
   - Multiple items spawn
   - Items offset from each other (circular pattern)
   - All items pickable
   - Inventory updates correctly

### Test 6: Despawn Timer

1. Spawn an item (kill enemy)
2. Don't pick it up
3. Wait 60 seconds
4. **Expected**:
   - Item fades out after 60 seconds
   - Item disappears
   - active_pickups counter decrements

## Verification Checklist

- [ ] LootSystem registered as autoload
- [ ] EventBus has all required signals
- [ ] Enemies emit enemy_killed signal on death
- [ ] PickupItem scene created and working
- [ ] Player can detect pickups (Area2D on layer 3)
- [ ] Inventory_UI displays items correctly
- [ ] Pickup effect plays on collection
- [ ] Items spawn with correct colors
- [ ] Tooltips show item info
- [ ] Despawn timer works (60 seconds)
- [ ] Manual pickup mode works (Press E)
- [ ] Automatic pickup mode works (walk over)

## Troubleshooting

### Issue: Items don't spawn when enemy dies
**Solutions**:
- Check that enemy emits EventBus.enemy_killed signal
- Check that enemy_type matches enemies.json keys
- Check console for LootSystem warnings
- Verify drop tables in enemies.json

### Issue: Items spawn but can't be picked up
**Solutions**:
- Check that player is in "player" group
- Check that PickupItem Area2D is on layer 3
- Check that player has Area2D monitoring layer 3
- Check console for errors

### Issue: Inventory doesn't show items
**Solutions**:
- Check that EventBus.inventory_changed is emitted
- Check that Player_Inventory is registered as autoload
- Open inventory (I key) to trigger refresh
- Check console for errors in inventory_ui.gd

### Issue: Pickup effect doesn't play
**Solutions**:
- Check that pickup_effect.tscn exists
- Check that EffectManager has pickup_effect registered
- Check that EventBus.spawn_effect signal is connected
- Check console for missing scene errors

### Issue: Items have wrong colors
**Solutions**:
- Check items.json has icon_color field (hex format)
- Check that DataManager loads items.json correctly
- Check console for item data warnings

### Issue: Too many items spawning
**Solutions**:
- Check drop rates in enemies.json (should be 0.0-1.0)
- Reduce drop rates or quantity ranges
- Check that MAX_ACTIVE_PICKUPS limit is working

## Performance Optimization

### If FPS drops with many items:

1. **Reduce particle count**:
   - Open pickup_effect.tscn
   - Reduce CPUParticles2D Amount to 10-15

2. **Reduce despawn time**:
   - In pickup_item.gd, change despawn_timer to 30 seconds

3. **Lower MAX_ACTIVE_PICKUPS**:
   - In loot_system.gd, change to 30 or 25

4. **Disable idle animations**:
   - Comment out `_start_idle_animation()` in pickup_item.gd

## Next Steps

After successful integration:
1. Balance drop rates in enemies.json
2. Add more item types
3. Implement item usage (health potions, etc.)
4. Add sound effects for pickup
5. Create proper sprites to replace ColorRects
6. Add inventory sorting/filtering
7. Implement item stacking limits

## Success Criteria

The Loot & Progression System is fully integrated when:
- ✅ Enemies drop items on death
- ✅ Items spawn with correct visuals and animations
- ✅ Player can pick up items (automatic or manual)
- ✅ Inventory displays collected items
- ✅ Tooltips show item information
- ✅ Pickup effects play on collection
- ✅ Items despawn after 60 seconds
- ✅ System handles 50+ active pickups without lag
- ✅ No errors in console during normal gameplay

---

**Status**: Integration guide complete  
**Result**: Loot & Progression System ready for testing!  
**Next**: Test in Prototype_World and balance drop rates


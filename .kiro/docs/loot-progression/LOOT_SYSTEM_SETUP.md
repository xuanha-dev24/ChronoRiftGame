# LootSystem Autoload Setup Instructions

## Overview

LootSystem is an autoload (singleton) that manages item drops when enemies are killed. It needs to be registered in Project Settings.

## Register as Autoload

### Step 1: Open Project Settings

1. In Godot Editor, go to **Project → Project Settings**
2. Click on the **Autoload** tab

### Step 2: Add LootSystem

1. Click the folder icon next to **Path**
2. Navigate to `res://scripts/systems/loot_system.gd`
3. Select the file
4. In **Node Name** field, enter: `LootSystem`
5. Click **Add**

### Step 3: Verify Order

The autoload order should be:
1. **EventBus** (must be first)
2. **GameManager**
3. **DataManager**
4. **LootSystem** (add after DataManager)

If order is wrong, use the up/down arrows to reorder.

### Step 4: Save and Close

1. Click **Close** to save settings
2. LootSystem is now available globally as `LootSystem`

## Verification

### Test in Script

Open any script and try:
```gdscript
func _ready():
    print(LootSystem.pickup_mode)  # Should print "automatic"
```

### Test Enemy Kill

1. Open `Prototype_World.tscn`
2. Run the scene (F5)
3. Kill an enemy (SlimeBasic or EarthGolem)
4. Items should spawn at enemy death position
5. Walk over items to collect them

## Configuration

### Change Pickup Mode

In any script:
```gdscript
# Set to automatic (walk over to collect)
LootSystem.set_pickup_mode("automatic")

# Set to manual (press E to collect)
LootSystem.set_pickup_mode("manual")
```

### Check Active Pickups

```gdscript
print("Active pickups: ", LootSystem.active_pickups)
print("Max pickups: ", LootSystem.MAX_ACTIVE_PICKUPS)
```

## Common Issues

### Issue: LootSystem not found
**Solution**: Make sure it's registered as autoload in Project Settings

### Issue: Items don't spawn
**Solution**: 
- Check that EventBus.enemy_killed signal is being emitted
- Check that enemy type exists in enemies.json
- Check console for warnings

### Issue: Too many items spawning
**Solution**: Check drop rates in enemies.json (should be 0.0-1.0)

### Issue: Items spawn at wrong position
**Solution**: Make sure enemy death position is passed correctly to EventBus.enemy_killed

## Next Steps

After setting up LootSystem:
1. Update EventBus to include required signals
2. Update Player_Inventory to handle item_picked_up signal
3. Test full loot flow: enemy death → spawn → pickup → inventory

---

**Status**: LootSystem script created  
**Next**: Register as autoload and update EventBus signals


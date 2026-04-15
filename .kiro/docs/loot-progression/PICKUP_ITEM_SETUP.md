# PickupItem Scene Setup Instructions

## Overview

The PickupItem scene represents a collectible item in the game world. Follow these steps to create the scene in Godot Editor.

## Scene Structure

```
PickupItem (Node2D) - attach pickup_item.gd script
├── Area2D
│   └── CollisionShape2D (CircleShape2D, radius 16)
├── Visual (ColorRect, size 16x16)
├── DespawnTimer (Timer, wait_time 60 seconds)
├── InteractPrompt (Label, text "Press E")
└── ItemLabel (Label, displays item name + quantity)
```

## Step-by-Step Setup

### 1. Create New Scene

1. In Godot Editor, click **Scene → New Scene**
2. Select **Other Node** and choose **Node2D**
3. Rename root node to `PickupItem`
4. Attach script: `res://scripts/items/pickup_item.gd`

### 2. Add Area2D for Collision Detection

1. Right-click `PickupItem` → **Add Child Node**
2. Search for `Area2D` and add it
3. With `Area2D` selected, go to **Inspector → Collision**
4. Set **Layer**: Uncheck all, check only **Layer 3**
5. Set **Mask**: Check **Layer 1** (player layer)

### 3. Add CollisionShape2D

1. Right-click `Area2D` → **Add Child Node**
2. Search for `CollisionShape2D` and add it
3. In **Inspector → Shape**, click dropdown and select **New CircleShape2D**
4. Click the CircleShape2D to edit it
5. Set **Radius** to `16`

### 4. Add Visual (ColorRect)

1. Right-click `PickupItem` → **Add Child Node**
2. Search for `ColorRect` and add it
3. Rename it to `Visual`
4. In **Inspector → Rect**:
   - **Size**: `16 x 16`
   - **Position**: `-8, -8` (to center it)
5. In **Inspector → Color**: Set to white `#FFFFFF` (will be changed by script)

### 5. Add DespawnTimer

1. Right-click `PickupItem` → **Add Child Node**
2. Search for `Timer` and add it
3. Rename it to `DespawnTimer`
4. In **Inspector**:
   - **Wait Time**: `60` seconds
   - **One Shot**: Check this box
   - **Autostart**: Leave unchecked (script will start it)

### 6. Add InteractPrompt Label

1. Right-click `PickupItem` → **Add Child Node**
2. Search for `Label` and add it
3. Rename it to `InteractPrompt`
4. In **Inspector**:
   - **Text**: `Press E`
   - **Position**: `0, -30` (above the item name)
   - **Horizontal Alignment**: Center
   - **Visible**: Uncheck (script will show/hide it)
5. In **Inspector → Theme Overrides → Font Sizes**:
   - **Font Size**: `12`

### 7. Add ItemLabel (Item Name Display)

1. Right-click `PickupItem` → **Add Child Node**
2. Search for `Label` and add it
3. Rename it to `ItemLabel`
4. In **Inspector**:
   - **Text**: `Item Name` (placeholder, script will update)
   - **Position**: `0, -20` (above the item)
   - **Horizontal Alignment**: Center
   - **Visible**: Check (always visible)
5. In **Inspector → Theme Overrides → Font Sizes**:
   - **Font Size**: `10`
6. In **Inspector → Theme Overrides → Colors**:
   - **Font Color**: White `#FFFFFF`
   - **Font Outline Color**: Black `#000000`
7. In **Inspector → Theme Overrides → Constants**:
   - **Outline Size**: `1` (adds black outline for readability)

### 8. Configure Y-Sort (Optional but Recommended)

1. Select root `PickupItem` node
2. In **Inspector → Ordering**:
   - **Y Sort Enabled**: Check this box
3. This ensures items render at correct depth in isometric view

### 9. Save Scene

1. Press **Ctrl+S** or **Scene → Save Scene**
2. Save as: `res://scenes/items/PickupItem.tscn`
3. Create `items` folder if it doesn't exist

## Testing the Scene

### Quick Test in Editor

1. Open `PickupItem.tscn`
2. Click **Play Scene** (F6)
3. You should see:
   - A colored square (16x16)
   - Floating/pulsing animation
   - Item despawns after 60 seconds

### Test with Player

1. Open `Prototype_World.tscn`
2. Add a PickupItem instance to the scene
3. In **Inspector**, set:
   - **Item Id**: `chrono_dust`
   - **Quantity**: `3`
4. Run the scene (F5)
5. Walk player over the item
6. Item should highlight and be collected automatically

## Verification Checklist

- [ ] Scene structure matches the hierarchy above
- [ ] Area2D uses collision layer 3
- [ ] CollisionShape2D has CircleShape2D with radius 16
- [ ] Visual is ColorRect 16x16, centered at (-8, -8)
- [ ] DespawnTimer set to 60 seconds, one-shot
- [ ] InteractPrompt Label positioned at (0, -30), initially hidden
- [ ] ItemLabel positioned at (0, -20), always visible with outline
- [ ] Script attached to root node
- [ ] Scene saved as `res://scenes/items/PickupItem.tscn`
- [ ] Y-Sort enabled on root node

## Common Issues

### Issue: Item doesn't get picked up
**Solution**: Check that Area2D is on layer 3 and monitoring layer 1 (player)

### Issue: Item color is white/gray
**Solution**: Call `setup(item_id, quantity)` after instantiating the scene

### Issue: Animation doesn't play
**Solution**: Ensure the scene is added to the scene tree before animations start

### Issue: Interact prompt doesn't show
**Solution**: Check that LootSystem.pickup_mode is set to "manual"

## Next Steps

After creating the PickupItem scene:
1. Test it in isolation (F6)
2. Test with player in Prototype_World
3. Proceed to implement LootSystem to spawn these items

---

**Status**: Scene setup instructions complete  
**Next**: Create LootSystem autoload to spawn PickupItems


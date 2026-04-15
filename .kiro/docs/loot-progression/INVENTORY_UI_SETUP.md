# Inventory UI Setup Instructions

## Overview

The Inventory UI displays collected items in a grid layout with tooltips. Follow these steps to create or update the scene in Godot Editor.

## Scene Structure

```
Inventory_UI (Control) - attach inventory_ui.gd script
├── Panel (Panel)
│   ├── Title (Label: "Inventory")
│   └── GridContainer (columns: 6)
└── TooltipPanel (Panel, initially hidden)
    └── VBoxContainer
        ├── ItemName (Label)
        └── ItemDescription (Label)
```

## Step-by-Step Setup

### 1. Create or Open Inventory_UI Scene

1. If scene exists: Open `scenes/ui/Inventory_UI.tscn`
2. If not: Create new scene with **Control** root node
3. Rename root to `Inventory_UI`
4. Attach script: `res://scripts/ui/inventory_ui.gd`

### 2. Configure Root Control Node

1. Select `Inventory_UI` root node
2. In **Inspector → Layout**:
   - **Anchors Preset**: Full Rect
   - This makes it cover the full screen

### 3. Add Main Panel

1. Right-click `Inventory_UI` → **Add Child Node** → **Panel**
2. In **Inspector → Layout**:
   - **Anchors Preset**: Center
   - **Size**: `400 x 500`
3. In **Inspector → Theme Overrides → Styles**:
   - Add **StyleBoxFlat** for panel background
   - Set background color to semi-transparent black: `#000000AA`

### 4. Add Title Label

1. Right-click `Panel` → **Add Child Node** → **Label**
2. Rename to `Title`
3. Set **Text**: `Inventory`
4. In **Inspector**:
   - **Position**: `10, 10`
   - **Horizontal Alignment**: Center
5. In **Theme Overrides → Font Sizes**:
   - **Font Size**: `24`

### 5. Add GridContainer

1. Right-click `Panel` → **Add Child Node** → **GridContainer**
2. In **Inspector**:
   - **Position**: `10, 50`
   - **Size**: `380 x 440`
   - **Columns**: `6`
3. In **Theme Overrides → Constants**:
   - **H Separation**: `8`
   - **V Separation**: `8`

### 6. Add Tooltip Panel

1. Right-click `Inventory_UI` → **Add Child Node** → **Panel**
2. Rename to `TooltipPanel`
3. In **Inspector**:
   - **Size**: `200 x 100`
   - **Visible**: Uncheck (script will show/hide it)
4. In **Theme Overrides → Styles**:
   - Add **StyleBoxFlat**
   - Background color: `#222222`
   - Border color: `#FFFFFF`
   - Border width: `2`

### 7. Add VBoxContainer to Tooltip

1. Right-click `TooltipPanel` → **Add Child Node** → **VBoxContainer**
2. In **Inspector → Layout**:
   - **Anchors Preset**: Full Rect
   - **Margins**: `8` on all sides

### 8. Add Tooltip Labels

1. Right-click `VBoxContainer` → **Add Child Node** → **Label**
2. Rename to `ItemName`
3. Set **Text**: `Item Name`
4. **Horizontal Alignment**: Center
5. **Font Size**: `16`

6. Right-click `VBoxContainer` → **Add Child Node** → **Label**
7. Rename to `ItemDescription`
8. Set **Text**: `Item description goes here`
9. **Autowrap Mode**: Word
10. **Font Size**: `12`

### 9. Save Scene

1. Press **Ctrl+S**
2. Save as: `res://scenes/ui/Inventory_UI.tscn`

## Testing

### Test Opening/Closing

1. Add Inventory_UI to Prototype_World scene
2. Run scene (F5)
3. Press **I** or **Tab** to toggle inventory
4. Should show/hide the panel

### Test with Items

1. Pick up some items (chrono_dust, health_potion)
2. Open inventory (I key)
3. Should see items in grid with colors and quantities
4. Hover over items to see tooltips

## Verification Checklist

- [ ] Scene structure matches hierarchy above
- [ ] GridContainer has 6 columns
- [ ] Tooltip panel initially hidden
- [ ] Script attached to root node
- [ ] Panel centered on screen
- [ ] Title label shows "Inventory"
- [ ] Tooltip shows item name and description on hover
- [ ] Items display with correct colors from items.json
- [ ] Quantity shows as "xN" on each item

## Common Issues

### Issue: Inventory doesn't open
**Solution**: Check that "open_inventory" action is mapped to I or Tab key in Input Map

### Issue: Items don't show
**Solution**: 
- Check that EventBus.inventory_changed signal is being emitted
- Check that Player_Inventory is registered as autoload
- Check console for errors

### Issue: Tooltip doesn't show
**Solution**: Check that TooltipPanel node exists and mouse signals are connected

### Issue: Item colors are wrong
**Solution**: Check that items.json has correct icon_color values (hex format like "#00FFFF")

## Next Steps

After setting up Inventory_UI:
1. Test full flow: kill enemy → pick up item → open inventory → see item
2. Test tooltip by hovering over items
3. Add pickup effects (particles, sounds)

---

**Status**: Inventory UI script complete  
**Next**: Create pickup effect scene and integrate with EffectManager


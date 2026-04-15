# Task 2: Update HUD Scene Structure

## Overview
Extend the existing HUD scene with proper container structure for organizing UI components (stats, hotbar, inventory, resources).

---

## Task 2.1: Extend Existing HUD Scene

### What Was Done
Updated `scenes/ui/HUD.tscn` to include 3 main container panels with proper positioning and anchors.

### Scene Structure

**Before:**
```
HUD (CanvasLayer)
└── HPLabel (Label) - Simple text label
```

**After:**
```
HUD (CanvasLayer)
├── StatsPanel (VBoxContainer) - Top-Left
│   ├── HPLabel (Label)
│   ├── ManaLabel (Label)
│   └── ChronoRiftLabel (Label)
├── Hotbar (HBoxContainer) - Bottom-Center
└── InfoPanel (VBoxContainer) - Top-Right
    ├── InventoryLabel (Label)
    └── ResourcesLabel (Label)
```

### Container Details

#### **StatsPanel (VBoxContainer)**
- **Position:** Top-left corner (10, 10)
- **Size:** 200x110 pixels
- **Purpose:** Display player stats (HP, Mana, Chrono Rift)
- **Children:**
  - HPLabel: "HP: 100 / 100"
  - ManaLabel: "Mana: 100 / 100"
  - ChronoRiftLabel: "Chrono Rift: READY"

#### **Hotbar (HBoxContainer)**
- **Position:** Bottom-center
- **Anchors:** 
  - anchor_left = 0.5 (center horizontally)
  - anchor_top = 1.0 (bottom)
  - anchor_right = 0.5
  - anchor_bottom = 1.0
- **Offset:** (-150, -70) to (150, -10)
- **Size:** 300x60 pixels
- **Purpose:** Quick-access item slots (1-5 keys)
- **Alignment:** Center
- **Children:** Will be added in Task 6 (5 slot panels)

#### **InfoPanel (VBoxContainer)**
- **Position:** Top-right corner
- **Anchors:**
  - anchor_left = 1.0 (right edge)
  - anchor_right = 1.0
- **Offset:** (-210, 10) to (-10, 200)
- **Size:** 200x190 pixels
- **Purpose:** Display inventory count and resources
- **Children:**
  - InventoryLabel: "Inventory: 0/20"
  - ResourcesLabel: "Resources:" (header)

### Files Modified
- `ChronoRiftGame/scenes/ui/HUD.tscn`

---

## Setup in Godot Editor

### Step 1: Open HUD Scene
1. Open Godot Editor
2. Navigate to `scenes/ui/HUD.tscn`
3. Double-click to open in Scene editor

### Step 2: Verify Scene Structure
Check that the scene tree matches the structure above:
- HUD (CanvasLayer) - root node
- StatsPanel (VBoxContainer) - top-left
- Hotbar (HBoxContainer) - bottom-center
- InfoPanel (VBoxContainer) - top-right

### Step 3: Verify Positioning

**StatsPanel:**
1. Select **StatsPanel** in Scene tree
2. In Inspector → **Layout**:
   - Position: (10, 10)
   - Size: (200, 110)

**Hotbar:**
1. Select **Hotbar** in Scene tree
2. In Inspector → **Layout**:
   - Anchors Preset: **Bottom Center**
   - Offset Left: -150
   - Offset Top: -70
   - Offset Right: 150
   - Offset Bottom: -10
3. In Inspector → **HBoxContainer**:
   - Alignment: **Center**

**InfoPanel:**
1. Select **InfoPanel** in Scene tree
2. In Inspector → **Layout**:
   - Anchors Preset: **Top Right**
   - Offset Left: -210
   - Offset Top: 10
   - Offset Right: -10
   - Offset Bottom: 200

### Step 4: Test HUD Layout

**Test 1: Visual Inspection**
1. Click **Run Current Scene** (F6) on HUD.tscn
2. **Expected Result:**
   - StatsPanel visible in top-left with 3 labels
   - Hotbar container visible at bottom-center (empty for now)
   - InfoPanel visible in top-right with 2 labels

**Test 2: Window Resize**
1. Run HUD scene (F6)
2. Resize game window (drag corners)
3. **Expected Result:**
   - StatsPanel stays in top-left corner
   - Hotbar stays centered at bottom
   - InfoPanel stays in top-right corner
   - All elements maintain proper spacing from edges

**Test 3: In Game Scene**
1. Open `scenes/world/Prototype_World.tscn`
2. Check if HUD is instanced as child node
3. **If not present:**
   - Right-click root node → **Instance Child Scene**
   - Browse to `scenes/ui/HUD.tscn`
   - Click **Open**
4. Run Prototype_World scene (F6)
5. **Expected Result:**
   - HUD renders above all world elements
   - All 3 panels visible and positioned correctly
   - Can see player, enemies, and HUD simultaneously

---

## Responsive Design

### Anchor System
The HUD uses Godot's anchor system for responsive positioning:

**StatsPanel (Top-Left):**
- Anchors: (0, 0, 0, 0) - anchored to top-left corner
- Offset: (10, 10) - 10px padding from edges

**Hotbar (Bottom-Center):**
- Anchors: (0.5, 1.0, 0.5, 1.0) - anchored to bottom-center
- Offset: (-150, -70, 150, -10) - centered with 300px width

**InfoPanel (Top-Right):**
- Anchors: (1.0, 0, 1.0, 0) - anchored to top-right corner
- Offset: (-210, 10, -10, 200) - 10px padding from right edge

### Testing Different Resolutions

Test HUD at different window sizes:
- **1280x720** (default)
- **1920x1080** (Full HD)
- **800x600** (small window)

All panels should maintain their relative positions.

---

## Integration with Future Tasks

### Task 3: HPBar Component
- Will replace `HPLabel` in StatsPanel
- Instance `HPBar.tscn` as child of StatsPanel

### Task 4: ManaBar Component
- Will replace `ManaLabel` in StatsPanel
- Instance `ManaBar.tscn` as child of StatsPanel

### Task 5: ChronoRiftIndicator Component
- Will replace `ChronoRiftLabel` in StatsPanel
- Instance `ChronoRiftIndicator.tscn` as child of StatsPanel

### Task 6: Hotbar Component
- Will add 5 slot panels to Hotbar container
- Each slot: 50x50px with 10px spacing

### Task 7: InventoryCounter Component
- Will replace `InventoryLabel` in InfoPanel
- Instance `InventoryCounter.tscn` as child of InfoPanel

### Task 8: ResourceDisplay Component
- Will replace `ResourcesLabel` in InfoPanel
- Instance `ResourceDisplay.tscn` as child of InfoPanel

---

## Common Issues

### Issue 1: Hotbar not centered
**Symptom:** Hotbar appears off-center or at wrong position
**Solution:**
- Check anchors: anchor_left = 0.5, anchor_right = 0.5
- Check offset_left = -150, offset_right = 150 (300px total width)
- Verify Alignment = Center in HBoxContainer properties

### Issue 2: InfoPanel not visible
**Symptom:** InfoPanel doesn't appear or is cut off
**Solution:**
- Check anchors: anchor_left = 1.0, anchor_right = 1.0
- Check offset_left = -210 (negative value to move left from right edge)
- Verify window width is at least 220px

### Issue 3: Labels overlapping
**Symptom:** Labels in StatsPanel or InfoPanel overlap each other
**Solution:**
- VBoxContainer should automatically stack children vertically
- Check that container has enough height
- Verify no manual position overrides on child labels

### Issue 4: HUD not visible in game
**Symptom:** HUD doesn't show when running Prototype_World
**Solution:**
- Verify HUD.tscn is instanced in Prototype_World scene tree
- Check CanvasLayer is enabled (eye icon in Scene tree)
- Verify CanvasLayer layer property (should be 0 or higher)
- Check if HUD is behind other CanvasLayers (increase layer number)

---

## Verification Checklist

- [ ] HUD.tscn opens without errors
- [ ] Scene has 3 main containers: StatsPanel, Hotbar, InfoPanel
- [ ] StatsPanel in top-left with 3 labels
- [ ] Hotbar in bottom-center (empty container)
- [ ] InfoPanel in top-right with 2 labels
- [ ] Running HUD scene shows all elements
- [ ] Resizing window maintains proper positioning
- [ ] HUD visible in Prototype_World scene
- [ ] HUD renders above world elements
- [ ] No errors in Output console

---

## Next Task
**Task 3:** Implement HPBar component with progress bar and color-coded health display.

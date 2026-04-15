# Task 3: Implement HPBar Component

## Overview
Create a reusable HPBar component that displays player health with a progress bar and color-coded visual feedback (green/yellow/red based on HP percentage).

---

## Task 3.1: Create HPBar Scene and Script

### What Was Done
Created a standalone HPBar component with:
- Semi-transparent dark panel background
- Progress bar showing HP percentage
- Text label showing "HP: X / Y" format
- Color-coded display (green > 60%, yellow 30-60%, red < 30%)

### Files Created
- `ChronoRiftGame/scenes/ui/components/HPBar.tscn`
- `ChronoRiftGame/scripts/ui/hp_bar.gd`

### Component Structure

```
HPBar (PanelContainer)
└── MarginContainer (2px padding)
    └── VBoxContainer
        ├── ProgressBar (15px height)
        └── Label (text display)
```

### Features
- **Size:** 200x30 pixels (custom_minimum_size)
- **Background:** Semi-transparent dark (Color(0, 0, 0, 0.7))
- **Progress Bar:** Visual fill showing HP percentage
- **Label:** Numerical display "HP: current / max"
- **Color Coding:**
  - **Green (#00FF00):** HP > 60%
  - **Yellow (#FFFF00):** HP 30-60%
  - **Red (#FF0000):** HP < 30%

### Script API

**Properties:**
```gdscript
var current_hp: int = 100
var max_hp: int = 100
```

**Methods:**
```gdscript
func update_hp(current: int, max: int) -> void
    # Updates HP display with new values
    # Automatically updates color based on percentage

func _get_hp_color(percentage: float) -> Color
    # Returns color based on HP percentage
    # Green (>60%), Yellow (30-60%), Red (<30%)
```

---

## Setup in Godot Editor

### Step 1: Open HPBar Scene
1. Navigate to `scenes/ui/components/HPBar.tscn`
2. Double-click to open in Scene editor

### Step 2: Verify Scene Structure
Check the scene tree:
```
HPBar (PanelContainer)
├── MarginContainer
│   └── VBoxContainer
│       ├── ProgressBar
│       └── Label
```

### Step 3: Verify Component Properties

**HPBar (PanelContainer):**
- Script: `res://scripts/ui/hp_bar.gd`
- Custom Minimum Size: (200, 30)

**MarginContainer:**
- Margin Left: 2
- Margin Top: 2
- Margin Right: 2
- Margin Bottom: 2

**ProgressBar:**
- Custom Minimum Size: (0, 15)
- Max Value: 100
- Value: 100
- Show Percentage: OFF

**Label:**
- Text: "HP: 100 / 100"
- Horizontal Alignment: Center

### Step 4: Test HPBar Standalone

**Test 1: Visual Appearance**
1. Open `HPBar.tscn`
2. Click **Run Current Scene** (F6)
3. **Expected Result:**
   - Dark semi-transparent panel (200x30px)
   - Green progress bar (100% filled)
   - Text: "HP: 100 / 100" in center
   - Label text is green

**Test 2: Color Thresholds**
1. Open `scripts/ui/hp_bar.gd`
2. Add test code to `_ready()`:
```gdscript
func _ready() -> void:
	# ... existing code ...
	
	# Test color changes
	print("[HPBar] Testing color thresholds...")
	
	await get_tree().create_timer(1.0).timeout
	update_hp(80, 100)  # 80% - Should be GREEN
	print("[HPBar] 80% HP - Should be GREEN")
	
	await get_tree().create_timer(1.0).timeout
	update_hp(50, 100)  # 50% - Should be YELLOW
	print("[HPBar] 50% HP - Should be YELLOW")
	
	await get_tree().create_timer(1.0).timeout
	update_hp(20, 100)  # 20% - Should be RED
	print("[HPBar] 20% HP - Should be RED")
	
	await get_tree().create_timer(1.0).timeout
	update_hp(100, 100)  # 100% - Back to GREEN
	print("[HPBar] 100% HP - Back to GREEN")
```

3. Run scene (F6)
4. **Expected Result:**
   - Bar starts green (100%)
   - After 1s: Still green (80%)
   - After 2s: Turns yellow (50%)
   - After 3s: Turns red (20%)
   - After 4s: Back to green (100%)
   - Check Output console for print statements

**Remove test code after verification!**

**Test 3: Edge Cases**
Test boundary values:
```gdscript
func test_edge_cases():
	update_hp(0, 100)    # 0% - RED
	await get_tree().create_timer(1.0).timeout
	
	update_hp(30, 100)   # 30% - YELLOW (boundary)
	await get_tree().create_timer(1.0).timeout
	
	update_hp(60, 100)   # 60% - YELLOW (boundary)
	await get_tree().create_timer(1.0).timeout
	
	update_hp(61, 100)   # 61% - GREEN (just above threshold)
```

---

## Integration with HUD Scene

### Step 1: Remove Old HPLabel
1. Open `scenes/ui/HUD.tscn`
2. Select **StatsPanel** in Scene tree
3. Right-click **HPLabel** child → **Delete Node**

### Step 2: Instance HPBar Component
1. Right-click **StatsPanel** → **Instance Child Scene**
2. Browse to `scenes/ui/components/HPBar.tscn`
3. Click **Open**
4. HPBar should now appear as first child of StatsPanel

### Step 3: Verify HUD Structure
```
HUD (CanvasLayer)
├── StatsPanel (VBoxContainer)
│   ├── HPBar (PanelContainer) ← NEW
│   ├── ManaLabel (Label)
│   └── ChronoRiftLabel (Label)
├── Hotbar (HBoxContainer)
└── InfoPanel (VBoxContainer)
```

### Step 4: Test in HUD
1. Open `HUD.tscn`
2. Run scene (F6)
3. **Expected Result:**
   - HPBar visible at top of StatsPanel
   - Green bar with "HP: 100 / 100"
   - ManaLabel and ChronoRiftLabel below it

### Step 5: Test in Game Scene
1. Open `Prototype_World.tscn`
2. Run scene (F6)
3. **Expected Result:**
   - HPBar visible in top-left corner
   - Green bar showing full health
   - HUD renders above world elements

---

## Testing HP Changes

### Manual Test Script
Add this to `scripts/ui/hud.gd` to test HP updates:

```gdscript
func _ready() -> void:
	print("[HUD] Testing HPBar component...")
	
	# Wait for scene to load
	await get_tree().create_timer(0.5).timeout
	
	# Get HPBar reference
	if has_node("StatsPanel/HPBar"):
		var hp_bar = $StatsPanel/HPBar
		
		print("[HUD] Testing HP changes...")
		
		# Test full health
		hp_bar.update_hp(100, 100)
		await get_tree().create_timer(1.0).timeout
		
		# Test high health (green)
		hp_bar.update_hp(80, 100)
		await get_tree().create_timer(1.0).timeout
		
		# Test medium health (yellow)
		hp_bar.update_hp(50, 100)
		await get_tree().create_timer(1.0).timeout
		
		# Test low health (red)
		hp_bar.update_hp(20, 100)
		await get_tree().create_timer(1.0).timeout
		
		# Test critical health (red)
		hp_bar.update_hp(5, 100)
		await get_tree().create_timer(1.0).timeout
		
		# Back to full
		hp_bar.update_hp(100, 100)
		
		print("[HUD] HPBar test complete!")
	else:
		push_error("[HUD] HPBar not found in StatsPanel!")
```

Run Prototype_World and watch the HP bar change colors.

**Remember to remove test code after verification!**

---

## Usage in Game

### Connecting to Player Damage
In future tasks, HPBar will be updated via EventBus signals:

```gdscript
# In hud.gd
func _ready():
	EventBus.player_damaged.connect(_on_player_damaged)

func _on_player_damaged(current_hp: int, max_hp: int):
	if has_node("StatsPanel/HPBar"):
		$StatsPanel/HPBar.update_hp(current_hp, max_hp)
```

### Emitting Player Damage Signal
In player controller or player_stats:

```gdscript
# When player takes damage
func take_damage(amount: int):
	current_hp -= amount
	current_hp = max(0, current_hp)
	
	# Emit signal for HUD
	EventBus.player_damaged.emit(current_hp, max_hp)
```

---

## Color Threshold Reference

| HP Percentage | Color | Hex Code | Meaning |
|--------------|-------|----------|---------|
| > 60% | Green | #00FF00 | Healthy |
| 30% - 60% | Yellow | #FFFF00 | Caution |
| < 30% | Red | #FF0000 | Danger |

### Threshold Logic
```gdscript
func _get_hp_color(percentage: float) -> Color:
	if percentage > 0.6:      # 60%
		return Color.GREEN
	elif percentage > 0.3:    # 30%
		return Color.YELLOW
	else:
		return Color.RED
```

---

## Common Issues

### Issue 1: HPBar not visible
**Symptom:** HPBar doesn't show in HUD
**Solution:**
- Verify HPBar.tscn is instanced in StatsPanel
- Check custom_minimum_size is set (200x30)
- Verify PanelContainer has StyleBoxFlat background
- Check CanvasLayer is rendering

### Issue 2: Progress bar not filling
**Symptom:** Progress bar shows empty or wrong percentage
**Solution:**
- Check `max_value` matches `max_hp`
- Verify `value` is set to `current_hp`
- Ensure `update_hp()` is being called
- Check for division by zero (max_hp = 0)

### Issue 3: Colors not changing
**Symptom:** Bar stays same color regardless of HP
**Solution:**
- Verify `_get_hp_color()` is being called in `update_hp()`
- Check StyleBoxFlat is being applied to progress bar
- Ensure thresholds are correct (0.6, 0.3)
- Check if progress bar has custom theme overriding colors

### Issue 4: Label text not updating
**Symptom:** Label shows "HP: 100 / 100" even when HP changes
**Solution:**
- Verify label reference is valid: `@onready var label: Label = $MarginContainer/VBoxContainer/Label`
- Check `update_hp()` is updating label.text
- Ensure label node exists in scene tree

### Issue 5: Background not transparent
**Symptom:** Panel has solid background instead of semi-transparent
**Solution:**
- Check StyleBoxFlat bg_color alpha: `Color(0, 0, 0, 0.7)`
- Verify StyleBoxFlat is applied: `add_theme_stylebox_override("panel", style)`
- Ensure CanvasLayer allows transparency

---

## Verification Checklist

- [ ] HPBar.tscn scene exists and opens
- [ ] HPBar.gd script attached to root node
- [ ] Scene structure matches: PanelContainer → MarginContainer → VBoxContainer → (ProgressBar + Label)
- [ ] Custom minimum size set to (200, 30)
- [ ] Progress bar shows 100% when HP is full
- [ ] Label displays "HP: X / Y" format
- [ ] Color changes to GREEN when HP > 60%
- [ ] Color changes to YELLOW when HP 30-60%
- [ ] Color changes to RED when HP < 30%
- [ ] Semi-transparent dark background visible
- [ ] HPBar instanced in HUD StatsPanel
- [ ] HPBar visible in game scene
- [ ] No errors in Output console

---

## Next Task
**Task 4:** Implement ManaBar component with similar structure but cyan color scheme for mana/stamina display.

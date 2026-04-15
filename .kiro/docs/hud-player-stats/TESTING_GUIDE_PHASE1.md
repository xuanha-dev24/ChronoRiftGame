# HUD & Player Stats - Testing Guide Phase 1

## Tasks Completed
- ✅ Task 1: EventBus signals + ResourceManager autoload
- ✅ Task 2: HUD scene structure
- ✅ Task 3: HPBar component

---

## Setup Instructions

### Step 1: Verify Autoload Registration

1. Open Godot Editor
2. Go to **Project → Project Settings → Autoload**
3. Verify **ResourceManager** is in the list:
   - Name: `ResourceManager`
   - Path: `res://scripts/autoloads/resource_manager.gd`
   - Enabled: ✅

**If not present:**
- Click **Add** button
- Browse to `res://scripts/autoloads/resource_manager.gd`
- Node Name: `ResourceManager`
- Enable checkbox
- Click **Add**

---

### Step 2: Update HUD Scene with HPBar Component

1. Open `scenes/ui/HUD.tscn` in Godot Editor
2. Select **StatsPanel** node in Scene tree
3. **Remove** the old `HPLabel` child node (we'll replace it with HPBar component)
4. Right-click **StatsPanel** → **Instance Child Scene**
5. Browse to `scenes/ui/components/HPBar.tscn`
6. Click **Open**
7. The HPBar component should now appear in StatsPanel

**Expected Scene Structure:**
```
HUD (CanvasLayer)
├── StatsPanel (VBoxContainer)
│   ├── HPBar (PanelContainer) ← NEW
│   ├── ManaLabel (Label)
│   └── ChronoRiftLabel (Label)
├── Hotbar (HBoxContainer)
└── InfoPanel (VBoxContainer)
    ├── InventoryLabel (Label)
    └── ResourcesLabel (Label)
```

---

### Step 3: Test HPBar Component Standalone

**Test 1: Visual Appearance**
1. Open `scenes/ui/components/HPBar.tscn`
2. Click **Run Current Scene** (F6)
3. **Expected Result:**
   - Dark semi-transparent panel (200x30px)
   - Green progress bar (100% filled)
   - Text: "HP: 100 / 100"

**Test 2: Color Changes**
1. Open `scripts/ui/hp_bar.gd`
2. In `_ready()`, add test code:
```gdscript
func _ready() -> void:
	# ... existing code ...
	
	# Test color changes
	await get_tree().create_timer(1.0).timeout
	update_hp(80, 100)  # Should be green
	
	await get_tree().create_timer(1.0).timeout
	update_hp(50, 100)  # Should be yellow
	
	await get_tree().create_timer(1.0).timeout
	update_hp(20, 100)  # Should be red
```
3. Run scene (F6)
4. **Expected Result:**
   - Bar starts green (100%)
   - After 1s: Still green (80%)
   - After 2s: Turns yellow (50%)
   - After 3s: Turns red (20%)

**Remove test code after verification!**

---

### Step 4: Test ResourceManager Autoload

1. Open `scripts/autoloads/resource_manager.gd`
2. In `_ready()`, add test code:
```gdscript
func _ready() -> void:
	print("[ResourceManager] Initialized with resources: ", resources)
	
	# Test resource operations
	await get_tree().create_timer(1.0).timeout
	add_resource("gold", 100)
	add_resource("fire_shard", 5)
	
	await get_tree().create_timer(1.0).timeout
	print("[ResourceManager] Current gold: ", get_resource("gold"))
	print("[ResourceManager] Current fire_shard: ", get_resource("fire_shard"))
	
	await get_tree().create_timer(1.0).timeout
	spend_resource("gold", 30)
	print("[ResourceManager] After spending 30 gold: ", get_resource("gold"))
```
3. Run any scene (e.g., Prototype_World.tscn)
4. Check **Output** console
5. **Expected Output:**
```
[ResourceManager] Initialized with resources: {fire_shard:0, gold:0, stone:0, wood:0, meat:0}
[ResourceManager] gold changed: 100 (delta: +100)
[ResourceManager] fire_shard changed: 5 (delta: +5)
[ResourceManager] Current gold: 100
[ResourceManager] Current fire_shard: 5
[ResourceManager] gold changed: 70 (delta: -30)
[ResourceManager] After spending 30 gold: 70
```

**Remove test code after verification!**

---

### Step 5: Test EventBus Signals

1. Open `autoloads/EventBus.gd`
2. Verify new signals exist:
   - `player_mana_changed(current_mana: int, max_mana: int)`
   - `chrono_rift_cooldown_started(duration: float)`
   - `chrono_rift_ready()`
   - `resource_changed(resource_type: String, amount: int)`
   - `hotbar_slot_changed(slot_index: int, item_data: Dictionary)`

3. Test signal emission in any script:
```gdscript
func _ready():
	# Connect to signal
	EventBus.resource_changed.connect(_on_resource_changed)
	
	# Emit signal
	await get_tree().create_timer(1.0).timeout
	EventBus.resource_changed.emit("gold", 100)

func _on_resource_changed(resource_type: String, amount: int):
	print("Resource changed: %s = %d" % [resource_type, amount])
```

4. **Expected Output:**
```
Resource changed: gold = 100
```

---

### Step 6: Test HUD in Game Scene

1. Open `scenes/world/Prototype_World.tscn`
2. Check if HUD is already instanced as child
3. **If not present:**
   - Right-click root node → **Instance Child Scene**
   - Browse to `scenes/ui/HUD.tscn`
   - Click **Open**

4. Run scene (F6)
5. **Expected Result:**
   - HUD visible on screen
   - HPBar component in top-left (green, "HP: 100 / 100")
   - Mana label below HP
   - Chrono Rift label below Mana
   - Inventory label in top-right
   - Resources label below inventory

---

## Verification Checklist

### ✅ ResourceManager Autoload
- [ ] ResourceManager appears in Autoload list
- [ ] ResourceManager initializes on game start
- [ ] Can add/get/spend resources
- [ ] Emits `resource_changed` signal correctly

### ✅ EventBus Signals
- [ ] 5 new signals added to EventBus.gd
- [ ] Signals can be connected and emitted
- [ ] No errors in Output console

### ✅ HPBar Component
- [ ] HPBar.tscn scene exists and opens
- [ ] HPBar displays correctly (panel + progress bar + label)
- [ ] Color changes at correct thresholds:
  - Green when HP > 60%
  - Yellow when HP 30-60%
  - Red when HP < 30%
- [ ] Text displays "HP: X / Y" format

### ✅ HUD Scene Structure
- [ ] HUD.tscn has 3 main panels (StatsPanel, Hotbar, InfoPanel)
- [ ] HPBar component instanced in StatsPanel
- [ ] HUD renders in game scene
- [ ] All labels visible and positioned correctly

---

## Common Issues

### Issue 1: ResourceManager not found
**Symptom:** Error "ResourceManager is not a valid Node path"
**Solution:** 
- Restart Godot Editor after adding autoload
- Verify path is correct: `res://scripts/autoloads/resource_manager.gd`
- Check autoload is enabled (checkbox)

### Issue 2: HPBar not visible
**Symptom:** HPBar component doesn't show in HUD
**Solution:**
- Verify HPBar.tscn is instanced in StatsPanel
- Check HPBar has `custom_minimum_size` set (200x30)
- Verify CanvasLayer is rendering (should be above world)

### Issue 3: Colors not changing
**Symptom:** HPBar stays same color
**Solution:**
- Check `update_hp()` is being called
- Verify `_get_hp_color()` logic (thresholds: 0.6, 0.3)
- Check progress bar has StyleBoxFlat applied

### Issue 4: Signals not working
**Symptom:** EventBus signals not emitting/receiving
**Solution:**
- Verify signal is defined in EventBus.gd
- Check signal connection syntax: `EventBus.signal_name.connect(callback)`
- Ensure callback function signature matches signal parameters

---

## Next Steps

After verifying all tests pass:
1. Remove all test code from scripts
2. Save all scenes
3. Commit changes to git (optional)
4. Ready to proceed with Task 4 (ManaBar component)

---

## Quick Test Script

If you want to test everything at once, add this to `scripts/ui/hud.gd`:

```gdscript
func _ready() -> void:
	print("[HUD] Testing Phase 1 components...")
	
	# Test ResourceManager
	await get_tree().create_timer(1.0).timeout
	ResourceManager.add_resource("gold", 50)
	print("[HUD] Gold: ", ResourceManager.get_resource("gold"))
	
	# Test HPBar color changes
	if has_node("StatsPanel/HPBar"):
		var hp_bar = $StatsPanel/HPBar
		
		await get_tree().create_timer(1.0).timeout
		hp_bar.update_hp(80, 100)  # Green
		
		await get_tree().create_timer(1.0).timeout
		hp_bar.update_hp(50, 100)  # Yellow
		
		await get_tree().create_timer(1.0).timeout
		hp_bar.update_hp(20, 100)  # Red
		
		await get_tree().create_timer(1.0).timeout
		hp_bar.update_hp(100, 100)  # Back to green
	
	print("[HUD] Phase 1 tests complete!")
```

Run Prototype_World scene and watch the Output console + visual changes.

**Remember to remove this test code after verification!**

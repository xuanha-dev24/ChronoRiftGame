# HUD & Player Stats Display - Setup Guide

**Date:** 2026-04-16  
**Status:** All components created, ready for Godot setup

---

## 📋 Prerequisites

Before testing, you need to:
1. Register ResourceManager autoload (if not done yet)
2. Verify HUD.tscn has all components
3. Ensure Prototype_World.tscn has HUD instance

---

## 🔧 Step 1: Register ResourceManager Autoload

**IMPORTANT:** ResourceManager must be registered as autoload!

### In Godot Editor:

1. Go to **Project → Project Settings**
2. Click **Autoload** tab
3. Check if `ResourceManager` exists in the list
4. If NOT exists:
   - Click the folder icon
   - Navigate to `scripts/autoloads/resource_manager.gd`
   - Node Name: `ResourceManager`
   - Click **Add**
5. Verify autoload order:
   ```
   1. EventBus
   2. GameManager
   3. DataManager
   4. LootSystem
   5. EffectManager
   6. Player_Inventory
   7. ResourceManager  ← Should be here
   ```

---

## 🎨 Step 2: Verify HUD.tscn Components

### Open HUD.tscn in Godot:

1. Navigate to `scenes/ui/HUD.tscn`
2. Double-click to open in editor
3. Verify scene structure:

```
HUD (CanvasLayer)
├── StatsPanel (VBoxContainer)
│   ├── HPBar (instance)
│   ├── ManaBar (instance)
│   └── ChronoRiftIndicator (instance)
├── Hotbar (instance)
└── InfoPanel (VBoxContainer)
    ├── InventoryCounter (instance)
    └── ResourceDisplay (instance)
```

### If components are missing:

**Add ManaBar:**
1. Right-click `StatsPanel`
2. **Instance Child Scene**
3. Select `scenes/ui/components/ManaBar.tscn`
4. Move it below HPBar

**Add ChronoRiftIndicator:**
1. Right-click `StatsPanel`
2. **Instance Child Scene**
3. Select `scenes/ui/components/ChronoRiftIndicator.tscn`
4. Move it below ManaBar

**Replace Hotbar:**
1. Delete old `Hotbar` (HBoxContainer) if exists
2. Right-click `HUD` root
3. **Instance Child Scene**
4. Select `scenes/ui/components/Hotbar.tscn`
5. Set anchors: **Bottom Center**
6. Set offsets:
   - Left: -150
   - Top: -70
   - Right: 150
   - Bottom: -10

**Add InventoryCounter:**
1. Right-click `InfoPanel`
2. **Instance Child Scene**
3. Select `scenes/ui/components/InventoryCounter.tscn`

**Add ResourceDisplay:**
1. Right-click `InfoPanel`
2. **Instance Child Scene**
3. Select `scenes/ui/components/ResourceDisplay.tscn`
4. Move it below InventoryCounter

---

## 🌍 Step 3: Verify HUD in Prototype_World

### Open Prototype_World.tscn:

1. Navigate to `scenes/world/Prototype_World.tscn`
2. Double-click to open
3. Check if `HUD` instance exists in scene tree
4. If NOT exists:
   - Right-click root node
   - **Instance Child Scene**
   - Select `scenes/ui/HUD.tscn`
   - Move HUD to bottom of scene tree (render on top)

---

## 🎮 Step 4: Test Component Rendering

### Quick Visual Test:

1. Open `HUD.tscn`
2. Click **Run Current Scene** (F6)
3. You should see:
   - ✅ HPBar (green, top-left)
   - ✅ ManaBar (cyan, below HPBar)
   - ✅ ChronoRiftIndicator ("READY", pulsing)
   - ✅ Hotbar (5 slots, bottom-center)
   - ✅ InventoryCounter ("Inventory: 0/30", top-right)
   - ✅ ResourceDisplay (5 resources, below inventory)

### If components don't show:
- Check Output console for errors
- Verify all .tscn files exist in `scenes/ui/components/`
- Verify all .gd scripts exist in `scripts/ui/`

---

## 🧪 Step 5: Test Signal Connections

### Create Test Script (Optional):

Create `scripts/test/test_hud_signals.gd`:

```gdscript
extends Node

func _ready():
	await get_tree().create_timer(1.0).timeout
	
	print("=== Testing HUD Signals ===")
	
	# Test HP change
	print("1. Testing HP change...")
	EventBus.player_damaged.emit(50, 100)
	
	await get_tree().create_timer(1.0).timeout
	
	# Test Mana change
	print("2. Testing Mana change...")
	EventBus.player_mana_changed.emit(30, 100)
	
	await get_tree().create_timer(1.0).timeout
	
	# Test Chrono Rift cooldown
	print("3. Testing Chrono Rift cooldown...")
	EventBus.chrono_rift_cooldown_started.emit(5.0)
	
	await get_tree().create_timer(6.0).timeout
	
	# Test Resource change
	print("4. Testing Resource change...")
	ResourceManager.add_resource("gold", 100)
	ResourceManager.add_resource("fire_shard", 50)
	
	print("=== Test Complete ===")
```

Attach to HUD node and run scene.

---

## ⚠️ Common Issues & Fixes

### Issue 1: "ResourceManager not found"
**Fix:** Register ResourceManager autoload (Step 1)

### Issue 2: Components not visible
**Fix:** 
- Check if .tscn files have correct UIDs
- Re-instance components in HUD.tscn
- Check console for missing script errors

### Issue 3: "Invalid get index 'inventory'"
**Fix:** Ensure Player_Inventory autoload is registered

### Issue 4: Signals not working
**Fix:**
- Check EventBus has all 5 new signals
- Verify hud.gd connects signals in _ready()
- Check Output console for connection errors

### Issue 5: Mana not regenerating
**Fix:**
- Ensure player_stats.gd has mana system
- Check player has PlayerStats node
- Verify mana_regen_rate > 0

---

## 🎯 Ready to Test!

Once setup is complete:

1. **Open Prototype_World.tscn**
2. **Press F5** to run game
3. **Check HUD displays:**
   - HP bar updates when taking damage
   - Mana bar regenerates over time
   - Chrono Rift shows cooldown when used (press Q)
   - Inventory counter updates when picking up items
   - Resources display (currently all 0)

---

## 📝 Next Steps After Testing

If everything works:
- ✅ Mark Phase 2 complete
- ✅ Update CURRENT_WORK.md
- ✅ Create completion summary
- 🎉 Celebrate! HUD system is done!

If issues found:
- Check Output console for errors
- Review this guide's "Common Issues" section
- Ask for help with specific error messages

---

**Last Updated:** 2026-04-16  
**Status:** Ready for testing

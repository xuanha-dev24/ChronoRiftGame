# Quick Setup Checklist - HUD System

## ✅ Before Testing

### 1. Register ResourceManager Autoload
- [ ] Open **Project → Project Settings → Autoload**
- [ ] Check if `ResourceManager` exists
- [ ] If not: Add `scripts/autoloads/resource_manager.gd` as `ResourceManager`

### 2. Verify HUD.tscn Structure
- [ ] Open `scenes/ui/HUD.tscn`
- [ ] Check StatsPanel has: HPBar, ManaBar, ChronoRiftIndicator
- [ ] Check Hotbar is instanced (not empty HBoxContainer)
- [ ] Check InfoPanel has: InventoryCounter, ResourceDisplay

### 3. Verify Prototype_World has HUD
- [ ] Open `scenes/world/Prototype_World.tscn`
- [ ] Check HUD instance exists in scene tree
- [ ] If not: Instance `scenes/ui/HUD.tscn` as child

### 4. Quick Visual Test
- [ ] Open HUD.tscn
- [ ] Press F6 (Run Current Scene)
- [ ] See all components render correctly

### 5. Run Full Game
- [ ] Open Prototype_World.tscn
- [ ] Press F5 (Run Project)
- [ ] Test gameplay with HUD

---

## 🎮 What to Test

- [ ] **HPBar**: Changes color when taking damage (green → yellow → red)
- [ ] **ManaBar**: Cyan color, regenerates over time
- [ ] **ChronoRift**: Shows cooldown timer when pressing Q, then "READY"
- [ ] **Hotbar**: 5 slots visible with key numbers (1-5)
- [ ] **Inventory**: Updates when picking up items
- [ ] **Resources**: Shows 5 resources (currently all 0)

---

## ⚠️ If Errors Occur

Check Output console for:
- `[HUD] component not found!` → Re-instance components in HUD.tscn
- `ResourceManager not found` → Register autoload (Step 1)
- `Invalid get index 'inventory'` → Check Player_Inventory autoload

---

**Ready?** Open Godot and follow the checklist! 🚀

# Building System - Quick Reference Card

## 🎮 Controls

| Key | Action |
|-----|--------|
| **B** | Toggle build mode |
| **1** | Select Wall |
| **2** | Select Turret |
| **3** | Select Crafting Station |
| **4** | Select Storage Chest |
| **Left Click** | Place structure / Demolish (with X) |
| **Right Click** | Cancel selection |
| **Escape** | Cancel selection / Exit build mode |
| **X + Left Click** | Demolish structure (50% refund) |
| **E** | Interact with Crafting Station / Storage Chest |

---

## 🏗️ Structures

| Structure | Size | HP | Cost | Function |
|-----------|------|----|----- |----------|
| **Wall** | 1x1 | 100 | 10 wood | Basic defense |
| **Turret** | 1x1 | 150 | 15 wood + 10 stone | Auto-attacks enemies (150px range, 15 dmg, 1.5s cooldown) |
| **Crafting Station** | 2x2 | 200 | 20 wood + 15 stone | Crafting UI (placeholder) |
| **Storage Chest** | 2x2 | 150 | 25 wood | 20-slot inventory |

---

## 🎨 Visual Feedback

| Color | Meaning |
|-------|---------|
| **Green preview** | Valid placement |
| **Red preview** | Invalid placement |
| **White structure** | HP > 66% |
| **Yellow structure** | 33% < HP ≤ 66% |
| **Red structure** | HP ≤ 33% |
| **White flash** | Taking damage |

---

## 📋 Placement Rules

✅ **Valid Placement:**
- Within map bounds (30x30 grid)
- No overlap with structures
- No overlap with harvestables (trees, rocks, bushes)
- Sufficient resources
- Under structure limit (100 max)

❌ **Invalid Placement:**
- Out of bounds
- Overlapping with existing structure
- Overlapping with harvestable object
- Insufficient resources
- Structure limit reached (100/100)

---

## 🔧 System Limits

| Limit | Value |
|-------|-------|
| **Max Structures** | 100 |
| **Warning Threshold** | 50 structures |
| **Grid Size** | 16x16 pixels per cell |
| **Map Size** | 30x30 cells (480x480 pixels) |
| **Turret Range** | 150 pixels |
| **Turret Cooldown** | 1.5 seconds |
| **Projectile Speed** | 200 px/s |
| **Projectile Max Distance** | 200 pixels |

---

## 💾 Save/Load

**Auto-saved data:**
- Structure type
- Grid position
- Current health
- Rotation
- Chest inventory (if Storage Chest)

**Validation on load:**
- Position within bounds [0, 29]
- No overlap with existing structures
- Valid structure type

---

## 🧪 Testing

**Run all tests:**
```bash
Project > Tools > Gut > Run All
```

**Test files:**
- `tests/test_building_system_core.gd` (40 tests)
- `tests/test_structure_base.gd` (24 tests)
- `tests/test_wall.gd` (6 tests)
- `tests/test_crafting_station.gd` (8 tests)
- `tests/test_storage_chest.gd` (23 tests)
- `tests/test_build_ui.gd` (9 tests)
- `tests/test_turret.gd` (20 tests)
- `tests/test_turret_projectile.gd` (15 tests)
- `tests/unit/test_placement_system.gd` (8 tests)

**Total: 153 tests**

---

## 🐛 Common Issues

**Build mode not working?**
→ Check Building_System autoload is enabled

**Structures not placing?**
→ Check resources, bounds, overlap

**Tests failing?**
→ Check GUT addon installed and enabled

**Turrets not firing?**
→ Check enemies in range (150px), check YSortRoot exists

**Save/load not working?**
→ Check Save_System autoload, check structure scenes exist

---

## 📞 Files to Check

**Autoloads:**
- `scripts/systems/building_system.gd` → Building_System
- `autoloads/resource_manager.gd` → ResourceManager
- `autoloads/EventBus.gd` → EventBus
- `scripts/systems/save_system.gd` → Save_System

**Scenes:**
- `scenes/structures/Wall.tscn`
- `scenes/structures/Turret.tscn`
- `scenes/structures/CraftingStation.tscn`
- `scenes/structures/StorageChest.tscn`
- `scenes/structures/TurretProjectile.tscn`
- `scenes/ui/Build_UI.tscn`
- `scenes/ui/Placement_Preview.tscn`

**Data:**
- `data/structures.json`

---

## 📚 Documentation

- `TESTING_SETUP.md` - Detailed testing guide
- `QUICK_TEST_GUIDE.md` - 5-minute setup guide
- `.kiro/specs/building-base-system/requirements.md` - Requirements
- `.kiro/specs/building-base-system/design.md` - Design document
- `.kiro/specs/building-base-system/tasks.md` - Implementation tasks
- `.kiro/specs/building-base-system/IMPLEMENTATION_COMPLETE.md` - Summary

---

**Version**: 1.0  
**Status**: ✅ Production Ready  
**Last Updated**: 2026-04-17

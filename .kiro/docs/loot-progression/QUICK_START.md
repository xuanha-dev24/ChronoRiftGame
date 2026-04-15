# Loot & Progression System - Quick Start

## 🚀 3 Bước Để Test Ngay

### Bước 1: Register LootSystem (2 phút)

1. Mở Godot Editor
2. **Project → Project Settings → Autoload**
3. Path: `res://scripts/systems/loot_system.gd`
4. Name: `LootSystem`
5. Click **Add**

### Bước 2: Tạo PickupItem Scene (5 phút)

1. **Scene → New Scene** → Node2D → name "PickupItem"
2. Attach script: `res://scripts/items/pickup_item.gd`
3. Add children:
   - **Area2D** (layer 3) → **CollisionShape2D** (CircleShape2D, radius 16)
   - **ColorRect** name "Visual" (16x16, position -8,-8)
   - **Timer** name "DespawnTimer" (60s, one shot)
   - **Label** name "InteractPrompt" ("Press E", visible off)
4. Save: `res://scenes/items/PickupItem.tscn`

### Bước 3: Update Enemy (1 phút)

Mở `scripts/enemies/base_enemy.gd`:

```gdscript
# Add at top
@export var enemy_type: String = "slime_basic"

# In take_damage() when HP <= 0, add:
EventBus.enemy_killed.emit(enemy_type, global_position)
```

---

## ✅ Test Ngay!

1. Mở `Prototype_World.tscn`
2. Run (F5)
3. Kill một enemy
4. **Kết quả**: Items spawn, walk over để nhặt!

---

## 📚 Chi Tiết Hơn?

- **Full setup**: Xem `PICKUP_ITEM_SETUP.md`, `LOOT_SYSTEM_SETUP.md`
- **Testing**: Xem `TESTING_GUIDE.md`
- **Integration**: Xem `FINAL_INTEGRATION_GUIDE.md`

---

**Chỉ 3 bước, 8 phút là test được!** 🎉


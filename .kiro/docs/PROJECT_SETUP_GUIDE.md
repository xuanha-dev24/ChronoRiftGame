# ChronoRift Game - Project Setup Guide

## 📋 Cấu hình trong Godot Editor

### 1. Thêm Autoload Singletons

Vào **Project > Project Settings > Autoload** và thêm các file theo thứ tự:

| Name | Path | Enabled |
|------|------|---------|
| `EventBus` | `res://autoloads/EventBus.gd` | ✅ |
| `GameManager` | `res://autoloads/GameManager.gd` | ✅ |
| `DataManager` | `res://autoloads/DataManager.gd` | ✅ |

**Lưu ý:** Thứ tự quan trọng! EventBus phải được load trước.

---

### 2. Cấu hình Input Map

Vào **Project > Project Settings > Input Map** và thêm các action:

#### Movement
- `move_up` → W, Arrow Up
- `move_down` → S, Arrow Down
- `move_left` → A, Arrow Left
- `move_right` → D, Arrow Right

#### Actions
- `attack` → Space, Left Mouse Button
- `use_chrono_rift` → Q
- `interact` → E
- `open_inventory` → I, Tab

---

### 3. Cấu hình Display (Pixel Art)

Vào **Project > Project Settings > Rendering**:

#### Textures
- **Default Texture Filter** → `Nearest`
- **Default Texture Repeat** → `Disabled`

#### 2D
- **Snap 2D Transforms to Pixel** → `Enabled`
- **Snap 2D Vertices to Pixel** → `Enabled`

#### Viewport
- **Transparent Background** → `Disabled`

---

### 4. Cấu hình HTML5 Export

Vào **Project > Export**:

1. Click **Add...** → chọn **Web**
2. Cấu hình:
   - **Export Path**: `builds/web/index.html`
   - **Texture Format**: `VRAM Compressed`
   - **Head Include**: (để trống hoặc thêm analytics)

3. **Custom HTML Shell** (optional):
   - Có thể tạo custom HTML template nếu cần

4. Click **Export Project** để test

---

### 5. Tạo Scene Player (Ví dụ)

1. Tạo scene mới: **Scene > New Scene**
2. Root node: **CharacterBody2D** (đặt tên `Player`)
3. Thêm các node con:
   - `CollisionShape2D` (thêm shape)
   - `Sprite2D` (placeholder sprite)
   - `PlayerStats` (script: `res://scripts/player/player_stats.gd`)
   - `PlayerInventory` (script: `res://scripts/player/player_inventory.gd`)
4. Attach script `player_controller.gd` vào root node
5. Save as `res://scenes/player/Player.tscn`

---

### 6. Tạo Scene Enemy (Ví dụ)

1. Tạo scene mới
2. Root node: **CharacterBody2D** (đặt tên `SlimeBasic`)
3. Thêm các node con:
   - `CollisionShape2D`
   - `Sprite2D`
   - `StateMachine` (script: `res://scripts/enemies/enemy_state_machine.gd`)
4. Attach script `base_enemy.gd` vào root node
5. Set `enemy_id` = `"slime_basic"` trong Inspector
6. Save as `res://scenes/enemies/SlimeBasic.tscn`

---

## ✅ Checklist sau khi setup

- [ ] 3 Autoload đã được đăng ký (EventBus, GameManager, DataManager)
- [ ] Input Map đã được cấu hình đầy đủ
- [ ] Texture Filter = Nearest (cho pixel art)
- [ ] Tạo được Player.tscn và test di chuyển
- [ ] Không có lỗi đỏ trong Output console
- [ ] `.gitignore` đã có ở root project

---

## 🎮 Test di chuyển Player

1. Tạo scene test: **WorldMap.tscn**
2. Root node: **Node2D**
3. Instance `Player.tscn` vào scene
4. Press **F6** để chạy scene
5. Dùng WASD hoặc Arrow keys để di chuyển

Nếu player di chuyển được → Setup thành công! ✨

---

## 📁 Cấu trúc thư mục đã tạo

```
res://
├── autoloads/          ✅ (EventBus, GameManager, DataManager)
├── scripts/            ✅ (player, enemies, systems, world, ui)
├── scenes/             ✅ (placeholder folders)
├── assets/             ✅ (sprites, tilesets, audio)
├── data/               ✅ (JSON files: items, enemies, elements, biomes)
└── .gitignore          ✅
```

---

## 🔧 Troubleshooting

### Lỗi: "Invalid get index 'player'"
→ Đảm bảo Player scene đã gọi `GameManager.register_player(self)` trong `_ready()`

### Lỗi: "Cannot open file: res://data/items.json"
→ Kiểm tra file JSON có đúng format và không có syntax error

### Player không di chuyển
→ Kiểm tra Input Map đã được cấu hình đúng

---

## 🚀 Next Steps

1. Tạo các scene còn lại (HUD, Inventory, Enemies)
2. Thêm sprites và animations
3. Implement combat system
4. Test Chrono Rift mechanics
5. Build level đầu tiên

Good luck với ChronoRift Game! 🎮✨

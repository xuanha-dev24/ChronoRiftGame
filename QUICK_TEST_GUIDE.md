# Quick Test Guide - 5 Phút Setup

## 🚀 Setup Nhanh (5 phút)

### Bước 1: Cài GUT Addon (2 phút)
1. Mở Godot Editor
2. Click tab **"AssetLib"** ở góc trên
3. Gõ **"GUT"** vào ô tìm kiếm
4. Click **"Download"** → **"Install"**
5. Vào **Project > Project Settings > Plugins**
6. Enable **"Gut"** plugin
7. Restart Godot

### Bước 2: Chạy Tests (1 phút)
1. Vào menu **Project > Tools > Gut**
2. Trong GUT panel:
   - **Directories/Scripts**: Thêm `res://tests/`
   - Check **"Include Subdirectories"**
3. Click nút **"Run All"**
4. Xem kết quả (Green = Pass, Red = Fail)

### Bước 3: Manual Test trong Game (2 phút)
1. Press **F5** để run game
2. Press **B** để toggle build mode
3. Click **Wall button** hoặc press **1**
4. Move mouse → Preview hiển thị (green/red)
5. **Left click** để place structure
6. **X + Left click** để demolish

---

## ✅ Test Checklist Nhanh

### Build Mode
- [ ] Press B → Build UI hiển thị
- [ ] Press B lại → Build UI ẩn
- [ ] Trong build mode: Không thể di chuyển player

### Placement
- [ ] Select Wall → Preview màu xanh (nếu đủ resources)
- [ ] Place structure → Resources bị trừ
- [ ] Try place overlap → Preview màu đỏ, không place được

### Combat
- [ ] Spawn enemy (nếu có)
- [ ] Enemy attack structure → HP giảm
- [ ] Place Turret → Turret auto-attack enemy

### Demolition
- [ ] Hold X + click structure → Nhận 50% refund

---

## 🐛 Troubleshooting Nhanh

**GUT không hiển thị?**
→ Check Project Settings > Plugins > Enable "Gut"

**Tests fail "Autoload not found"?**
→ Check Project Settings > Autoload:
- Building_System → `scripts/systems/building_system.gd`
- ResourceManager → `autoloads/resource_manager.gd`
- EventBus → `autoloads/EventBus.gd`

**Tests fail "Scene not found"?**
→ Check các scenes tồn tại:
- `scenes/structures/Wall.tscn`
- `scenes/structures/Turret.tscn`
- `scenes/ui/Build_UI.tscn`

---

## 📊 Test Coverage

- ✅ **148+ unit tests** covering all Building System features
- ✅ **9 test files** for different components
- ✅ **100% core functionality** tested

---

## 🎯 Expected Results

Nếu mọi thứ hoạt động đúng:
- **Unit tests**: 140+ tests pass (một số có thể skip nếu thiếu dependencies)
- **Manual test**: Build mode hoạt động, place structures thành công
- **Combat test**: Enemies attack structures, turrets attack enemies
- **Save/Load**: Structures persist between sessions

---

## 📞 Need Help?

Xem file `TESTING_SETUP.md` để có hướng dẫn chi tiết hơn.

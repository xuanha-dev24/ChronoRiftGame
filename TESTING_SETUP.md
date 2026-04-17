# Testing Setup Guide - Building System

## Cài đặt GUT (Godot Unit Testing)

### Phương pháp 1: Cài đặt từ AssetLib (Khuyến nghị)

1. **Mở Godot Editor**
   - Mở project ChronoRiftGame

2. **Truy cập AssetLib**
   - Click tab "AssetLib" ở góc trên cùng của editor
   - Hoặc menu: `Project > Asset Library`

3. **Tìm kiếm GUT**
   - Gõ "GUT" hoặc "Godot Unit Test" vào ô tìm kiếm
   - Chọn addon "Gut - Godot Unit Test" (by bitwes)

4. **Cài đặt**
   - Click "Download"
   - Click "Install"
   - Chọn thư mục cài đặt: `res://addons/gut/`
   - Click "Install"

5. **Kích hoạt Plugin**
   - Vào menu: `Project > Project Settings > Plugins`
   - Tìm "Gut" trong danh sách
   - Check vào ô "Enable"
   - Restart Godot nếu được yêu cầu

### Phương pháp 2: Cài đặt thủ công từ GitHub

1. **Download GUT**
   - Truy cập: https://github.com/bitwes/Gut
   - Click "Code" > "Download ZIP"
   - Giải nén file

2. **Copy vào project**
   - Copy thư mục `addons/gut` từ file giải nén
   - Paste vào `ChronoRiftGame/addons/gut/`

3. **Kích hoạt Plugin**
   - Vào menu: `Project > Project Settings > Plugins`
   - Tìm "Gut" trong danh sách
   - Check vào ô "Enable"
   - Restart Godot nếu được yêu cầu

---

## Cấu trúc Test Files

Các test files đã được tạo sẵn trong thư mục `tests/`:

```
ChronoRiftGame/tests/
├── test_building_system_core.gd       # Phase 1: Core Building System
├── test_structure_base.gd             # Phase 2: Structure Base Class
├── test_wall.gd                       # Phase 3: Wall Structure
├── test_crafting_station.gd           # Phase 3: Crafting Station
├── test_storage_chest.gd              # Phase 3: Storage Chest
├── test_build_ui.gd                   # Phase 4: Build UI
├── unit/
│   └── test_placement_system.gd       # Phase 5: Placement System
├── test_turret.gd                     # Phase 6: Turret Structure
└── test_turret_projectile.gd          # Phase 6: Turret Projectile
```

**Tổng cộng: 9 test files với 100+ test cases**

---

## Chạy Tests

### Cách 1: Sử dụng GUT Panel (GUI)

1. **Mở GUT Panel**
   - Vào menu: `Project > Tools > Gut`
   - Hoặc click tab "Gut" ở bottom panel

2. **Cấu hình Test Directory**
   - Trong GUT panel, tìm "Directories/Scripts"
   - Thêm đường dẫn: `res://tests/`
   - Check "Include Subdirectories" nếu muốn chạy tests trong `tests/unit/`

3. **Chạy Tests**
   - Click nút "Run All" để chạy tất cả tests
   - Hoặc click "Run" bên cạnh từng test file để chạy riêng lẻ

4. **Xem Kết quả**
   - Kết quả hiển thị trong GUT panel
   - ✅ Green = Pass
   - ❌ Red = Fail
   - Xem chi tiết lỗi trong output

### Cách 2: Chạy từ Command Line

```bash
# Chạy tất cả tests
godot --path ChronoRiftGame -s addons/gut/gut_cmdln.gd -gdir=res://tests/ -gexit

# Chạy một test file cụ thể
godot --path ChronoRiftGame -s addons/gut/gut_cmdln.gd -gtest=res://tests/test_turret.gd -gexit

# Chạy với output chi tiết
godot --path ChronoRiftGame -s addons/gut/gut_cmdln.gd -gdir=res://tests/ -gverbose -gexit
```

### Cách 3: Tạo Test Scene (Khuyến nghị cho CI/CD)

1. **Tạo Test Scene**
   - Tạo scene mới: `res://tests/test_runner.tscn`
   - Add node `Gut` (từ addon)
   - Configure properties:
     - Directory 1: `res://tests/`
     - Include Subdirectories: true

2. **Chạy Test Scene**
   - Press F6 hoặc click "Run Current Scene"
   - Tests sẽ chạy tự động

---

## Test Coverage

### Phase 1: Core Building System (40 tests)
- ✅ Grid coordinate conversion
- ✅ Placement validation (bounds, overlap, resources)
- ✅ Structure data loading
- ✅ Build mode toggle

### Phase 2: Structure Base Class (24 tests)
- ✅ Health system (damage, destruction, clamping)
- ✅ Visual feedback (health bar, color modulation)
- ✅ Save/load interface
- ✅ Collision layers

### Phase 3: Basic Structures (37 tests)
- ✅ Wall properties and collision
- ✅ Crafting Station interaction system
- ✅ Storage Chest inventory (add, remove, stack, full check)
- ✅ Chest item dropping on destruction
- ✅ Chest inventory serialization

### Phase 4: Build UI (9 tests)
- ✅ UI visibility based on build mode
- ✅ Resource display updates
- ✅ Button states (enabled/disabled)
- ✅ Button highlighting
- ✅ Error message display

### Phase 5: Placement System (8 tests)
- ✅ Preview position snapping
- ✅ Structure selection/deselection
- ✅ Placement validation
- ✅ Multi-cell structure registry

### Phase 6: Turret and AI (30+ tests)
- ✅ Turret properties and AI constants
- ✅ Enemy scanning and target selection
- ✅ Turret rotation toward target
- ✅ AI main loop (scan timer, attack cooldown)
- ✅ Projectile movement and collision
- ✅ Projectile velocity and lifetime

**Total: 148+ test cases**

---

## Troubleshooting

### Lỗi: "Gut not found"
**Giải pháp:**
- Kiểm tra addon đã được enable trong Project Settings > Plugins
- Restart Godot Editor
- Kiểm tra thư mục `addons/gut/` tồn tại

### Lỗi: "Cannot find test files"
**Giải pháp:**
- Kiểm tra đường dẫn test directory: `res://tests/`
- Đảm bảo test files có extension `.gd`
- Đảm bảo test files extend `GutTest`

### Lỗi: "Autoload not found" (Building_System, ResourceManager, EventBus)
**Giải pháp:**
- Kiểm tra autoloads đã được thêm trong Project Settings > Autoload
- Đảm bảo các autoload scripts tồn tại:
  - `scripts/systems/building_system.gd` → Building_System
  - `autoloads/resource_manager.gd` → ResourceManager
  - `autoloads/EventBus.gd` → EventBus

### Tests fail do missing scenes
**Giải pháp:**
- Đảm bảo tất cả structure scenes đã được tạo:
  - `scenes/structures/Wall.tscn`
  - `scenes/structures/Turret.tscn`
  - `scenes/structures/CraftingStation.tscn`
  - `scenes/structures/StorageChest.tscn`
  - `scenes/structures/TurretProjectile.tscn`
  - `scenes/ui/Build_UI.tscn`
  - `scenes/ui/Placement_Preview.tscn`

### Tests fail do missing data files
**Giải pháp:**
- Đảm bảo `data/structures.json` tồn tại và có đúng format

---

## Manual Testing Checklist

Ngoài unit tests, bạn nên test thủ công các tính năng sau:

### Build Mode
- [ ] Press B để toggle build mode
- [ ] Build UI hiển thị/ẩn đúng
- [ ] Player không thể di chuyển/attack trong build mode

### Structure Placement
- [ ] Click structure button để select
- [ ] Preview hiển thị và follow mouse
- [ ] Preview màu xanh khi valid, đỏ khi invalid
- [ ] Left click để place structure
- [ ] Resources bị trừ đúng
- [ ] Structure xuất hiện tại vị trí đúng

### Structure Interaction
- [ ] Crafting Station: Hiển thị interaction indicator khi player gần
- [ ] Storage Chest: Mở inventory UI khi interact (E key)
- [ ] Chest inventory: Add/remove items hoạt động

### Combat
- [ ] Enemies detect và attack structures
- [ ] Structures take damage và health bar giảm
- [ ] Structures destroyed khi HP = 0
- [ ] Turrets scan và target enemies
- [ ] Turrets rotate toward target
- [ ] Turrets fire projectiles
- [ ] Projectiles deal damage to enemies

### Demolition
- [ ] Hold X + left click để demolish structure
- [ ] Nhận 50% resources refund
- [ ] Structure bị xóa khỏi scene

### Save/Load
- [ ] Place structures
- [ ] Save game
- [ ] Load game
- [ ] Structures restore đúng vị trí và HP
- [ ] Chest inventory restore đúng items

### Performance
- [ ] Place 50+ structures → Warning message hiển thị
- [ ] Place 100 structures → Cannot place more
- [ ] Multiple turrets hoạt động mượt (AI staggering)

---

## Chạy Specific Test Groups

### Test Core Building System
```bash
godot --path ChronoRiftGame -s addons/gut/gut_cmdln.gd -gtest=res://tests/test_building_system_core.gd -gexit
```

### Test Structures
```bash
godot --path ChronoRiftGame -s addons/gut/gut_cmdln.gd -gtest=res://tests/test_structure_base.gd -gexit
godot --path ChronoRiftGame -s addons/gut/gut_cmdln.gd -gtest=res://tests/test_wall.gd -gexit
godot --path ChronoRiftGame -s addons/gut/gut_cmdln.gd -gtest=res://tests/test_crafting_station.gd -gexit
godot --path ChronoRiftGame -s addons/gut/gut_cmdln.gd -gtest=res://tests/test_storage_chest.gd -gexit
```

### Test Turret System
```bash
godot --path ChronoRiftGame -s addons/gut/gut_cmdln.gd -gtest=res://tests/test_turret.gd -gexit
godot --path ChronoRiftGame -s addons/gut/gut_cmdln.gd -gtest=res://tests/test_turret_projectile.gd -gexit
```

### Test UI
```bash
godot --path ChronoRiftGame -s addons/gut/gut_cmdln.gd -gtest=res://tests/test_build_ui.gd -gexit
```

---

## CI/CD Integration (Optional)

Nếu bạn muốn chạy tests tự động trong CI/CD pipeline:

### GitHub Actions Example
```yaml
name: Run Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Setup Godot
        uses: chickensoft-games/setup-godot@v1
        with:
          version: 4.2.0
      - name: Run Tests
        run: |
          godot --path ChronoRiftGame -s addons/gut/gut_cmdln.gd -gdir=res://tests/ -gexit
```

---

## Kết luận

Sau khi setup xong, bạn có thể:
1. Chạy tất cả 148+ unit tests để verify Building System hoạt động đúng
2. Chạy manual tests để kiểm tra gameplay
3. Debug các issues nếu có tests fail

**Lưu ý:** Một số tests có thể fail nếu thiếu dependencies (scenes, autoloads). Hãy đảm bảo tất cả files đã được tạo đúng theo structure.

Good luck với testing! 🧪✨

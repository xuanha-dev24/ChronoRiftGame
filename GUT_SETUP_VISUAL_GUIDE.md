# GUT Setup - Hướng dẫn có hình ảnh chi tiết

## 📋 Bước 1: Cài đặt GUT Addon

### 1.1. Mở AssetLib
```
┌─────────────────────────────────────────────────────────┐
│ Godot Editor - Top Menu Bar                             │
├─────────────────────────────────────────────────────────┤
│ [2D] [3D] [Script] [AssetLib] ← Click vào đây          │
└─────────────────────────────────────────────────────────┘
```

### 1.2. Tìm kiếm GUT
```
┌─────────────────────────────────────────────────────────┐
│ AssetLib Tab                                             │
├─────────────────────────────────────────────────────────┤
│ Search: [GUT                    ] [🔍]                  │
│                                                          │
│ Results:                                                 │
│ ┌──────────────────────────────────────────────────┐   │
│ │ 📦 Gut - Godot Unit Test                         │   │
│ │    by bitwes                                      │   │
│ │    [Download] ← Click vào đây                    │   │
│ └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

### 1.3. Install Addon
```
┌─────────────────────────────────────────────────────────┐
│ Install Asset                                            │
├─────────────────────────────────────────────────────────┤
│ Install to folder: [res://addons/gut/]                  │
│                                                          │
│ [Cancel]                              [Install] ← Click │
└─────────────────────────────────────────────────────────┘
```

### 1.4. Enable Plugin
```
┌─────────────────────────────────────────────────────────┐
│ Project > Project Settings > Plugins                     │
├─────────────────────────────────────────────────────────┤
│ Plugin Name          | Status                            │
│ ─────────────────────┼──────────────────────────────────│
│ Gut                  | [✓] Enable ← Check vào đây       │
└─────────────────────────────────────────────────────────┘
```

**⚠️ Lưu ý:** Sau khi enable, Godot có thể yêu cầu restart. Click "Restart" nếu có popup.

---

## 📋 Bước 2: Mở GUT Panel

### 2.1. Truy cập GUT từ Menu
```
┌─────────────────────────────────────────────────────────┐
│ Top Menu Bar                                             │
├─────────────────────────────────────────────────────────┤
│ Project > Tools > Gut ← Click vào đây                   │
└─────────────────────────────────────────────────────────┘
```

### 2.2. GUT Panel xuất hiện ở Bottom
```
┌─────────────────────────────────────────────────────────┐
│ Main Editor Area                                         │
│ (Scene tree, viewport, inspector...)                    │
├─────────────────────────────────────────────────────────┤
│ Bottom Panel Tabs:                                       │
│ [Output] [Debugger] [Audio] [Animation] [Gut] ← Click   │
├─────────────────────────────────────────────────────────┤
│ GUT Panel Content (sẽ hiển thị ở đây)                   │
└─────────────────────────────────────────────────────────┘
```

---

## 📋 Bước 3: Cấu hình Test Directory (CHI TIẾT)

### 3.1. Tìm phần "Directories/Scripts" trong GUT Panel

Khi bạn mở GUT panel, bạn sẽ thấy giao diện như sau:

```
┌─────────────────────────────────────────────────────────────────┐
│ GUT Panel                                                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│ ┌─ Config ─────────────────────────────────────────────────┐   │
│ │                                                            │   │
│ │ ┌─ Directories/Scripts ─────────────────────────────┐    │   │
│ │ │                                                     │    │   │
│ │ │ Directory 1: [                    ] [📁] ← Click   │    │   │
│ │ │                                                     │    │   │
│ │ │ Directory 2: [                    ] [📁]           │    │   │
│ │ │                                                     │    │   │
│ │ │ Script:      [                    ] [📁]           │    │   │
│ │ │                                                     │    │   │
│ │ │ [✓] Include Subdirectories ← Check vào đây        │    │   │
│ │ │                                                     │    │   │
│ │ └─────────────────────────────────────────────────────┘    │   │
│ │                                                            │   │
│ │ ┌─ Options ──────────────────────────────────────────┐    │   │
│ │ │ [✓] Log Level: 1                                   │    │   │
│ │ │ [ ] Disable Colors                                 │    │   │
│ │ └─────────────────────────────────────────────────────┘    │   │
│ │                                                            │   │
│ └────────────────────────────────────────────────────────────┘   │
│                                                                  │
│ [Run All] [Run] [Clear]                                         │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 3.2. Thêm đường dẫn test directory

**Bước 1:** Click vào ô "Directory 1" hoặc nút [📁] bên cạnh

```
┌─────────────────────────────────────────────────────────┐
│ Directory 1: [                    ] [📁] ← Click đây    │
└─────────────────────────────────────────────────────────┘
```

**Bước 2:** Một file browser sẽ mở ra. Navigate đến thư mục `tests/`

```
┌─────────────────────────────────────────────────────────┐
│ Select Directory                                         │
├─────────────────────────────────────────────────────────┤
│ Path: res://                                             │
│                                                          │
│ 📁 addons/                                              │
│ 📁 assets/                                              │
│ 📁 autoloads/                                           │
│ 📁 data/                                                │
│ 📁 scenes/                                              │
│ 📁 scripts/                                             │
│ 📁 tests/          ← Click vào đây                      │
│                                                          │
│ [Cancel]                    [Select Current Folder]     │
└─────────────────────────────────────────────────────────┘
```

**Bước 3:** Click "Select Current Folder" hoặc "Open"

**Bước 4:** Đường dẫn sẽ được điền vào ô:

```
┌─────────────────────────────────────────────────────────┐
│ Directory 1: [res://tests/        ] [📁] ✓              │
└─────────────────────────────────────────────────────────┘
```

### 3.3. Check "Include Subdirectories"

**Quan trọng:** Bạn PHẢI check vào ô này để GUT scan cả thư mục `tests/unit/`

```
┌─────────────────────────────────────────────────────────┐
│ Directory 1: [res://tests/        ] [📁]                │
│                                                          │
│ [✓] Include Subdirectories ← PHẢI check vào đây        │
│     ^                                                    │
│     └─ Click vào checkbox này                           │
└─────────────────────────────────────────────────────────┘
```

**Tại sao cần check này?**
- Thư mục `tests/` có cấu trúc:
  ```
  tests/
  ├── test_building_system_core.gd
  ├── test_structure_base.gd
  ├── test_wall.gd
  ├── ... (các test files khác)
  └── unit/
      └── test_placement_system.gd  ← File này ở subdirectory
  ```
- Nếu KHÔNG check "Include Subdirectories", GUT sẽ bỏ qua `tests/unit/test_placement_system.gd`

### 3.4. Kết quả cuối cùng

Sau khi cấu hình xong, GUT panel sẽ trông như thế này:

```
┌─────────────────────────────────────────────────────────────────┐
│ GUT Panel                                                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│ ┌─ Config ─────────────────────────────────────────────────┐   │
│ │                                                            │   │
│ │ ┌─ Directories/Scripts ─────────────────────────────┐    │   │
│ │ │                                                     │    │   │
│ │ │ Directory 1: [res://tests/        ] [📁] ✓        │    │   │
│ │ │                                                     │    │   │
│ │ │ [✓] Include Subdirectories                         │    │   │
│ │ │                                                     │    │   │
│ │ └─────────────────────────────────────────────────────┘    │   │
│ │                                                            │   │
│ └────────────────────────────────────────────────────────────┘   │
│                                                                  │
│ [Run All] [Run] [Clear]                                         │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📋 Bước 4: Chạy Tests

### 4.1. Click nút "Run All"

```
┌─────────────────────────────────────────────────────────┐
│ GUT Panel - Bottom                                       │
├─────────────────────────────────────────────────────────┤
│ [Run All] ← Click vào đây để chạy tất cả tests         │
│ [Run]                                                    │
│ [Clear]                                                  │
└─────────────────────────────────────────────────────────┘
```

### 4.2. Xem kết quả

GUT sẽ chạy tests và hiển thị kết quả:

```
┌─────────────────────────────────────────────────────────────────┐
│ GUT Panel - Results                                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│ Running Tests...                                                 │
│                                                                  │
│ ✓ test_building_system_core.gd                                  │
│   ✓ test_grid_coordinate_conversion (0.001s)                    │
│   ✓ test_placement_validation_bounds (0.002s)                   │
│   ✓ test_structure_data_loading (0.003s)                        │
│   ... (37 more tests)                                            │
│                                                                  │
│ ✓ test_structure_base.gd                                        │
│   ✓ test_structure_initializes_with_max_health (0.001s)         │
│   ✓ test_structure_takes_damage (0.002s)                        │
│   ... (22 more tests)                                            │
│                                                                  │
│ ✓ test_wall.gd                                                  │
│   ✓ test_wall_has_correct_type (0.001s)                         │
│   ... (5 more tests)                                             │
│                                                                  │
│ ... (6 more test files)                                          │
│                                                                  │
│ ═══════════════════════════════════════════════════════════════ │
│ Summary:                                                         │
│ ✓ 153 tests passed                                              │
│ ✗ 0 tests failed                                                │
│ ⊘ 0 tests skipped                                               │
│ Total time: 2.345s                                               │
│ ═══════════════════════════════════════════════════════════════ │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 4.3. Hiểu kết quả

**Ký hiệu:**
- ✓ (Green checkmark) = Test passed
- ✗ (Red X) = Test failed
- ⊘ (Gray circle) = Test skipped

**Nếu có test fail:**
```
┌─────────────────────────────────────────────────────────────────┐
│ ✗ test_turret.gd                                                │
│   ✓ test_turret_has_correct_type (0.001s)                       │
│   ✗ test_turret_ai_scans_enemies (0.005s)                       │
│     └─ Expected: <Enemy#12345>                                  │
│        Got: null                                                 │
│        at line 45 in test_turret.gd                             │
│   ✓ test_turret_rotation (0.002s)                               │
└─────────────────────────────────────────────────────────────────┘
```

Click vào test fail để xem chi tiết lỗi.

---

## 📋 Bước 5: Chạy từng test file riêng lẻ (Optional)

Nếu bạn muốn chạy chỉ một test file cụ thể:

### 5.1. Chọn test file

```
┌─────────────────────────────────────────────────────────┐
│ GUT Panel                                                │
├─────────────────────────────────────────────────────────┤
│ Test Files:                                              │
│ [ ] test_building_system_core.gd                        │
│ [ ] test_structure_base.gd                              │
│ [✓] test_turret.gd ← Check vào file muốn chạy          │
│ [ ] test_turret_projectile.gd                           │
│ [ ] ...                                                  │
│                                                          │
│ [Run] ← Click để chạy chỉ file đã check                │
└─────────────────────────────────────────────────────────┘
```

### 5.2. Hoặc dùng Script field

```
┌─────────────────────────────────────────────────────────┐
│ Script: [res://tests/test_turret.gd] [📁]              │
│                                                          │
│ [Run] ← Click để chạy chỉ file này                     │
└─────────────────────────────────────────────────────────┘
```

---

## 🔧 Troubleshooting

### Vấn đề 1: Không thấy GUT panel

**Triệu chứng:**
- Không có tab "Gut" ở bottom panel
- Menu "Project > Tools > Gut" không tồn tại

**Giải pháp:**
1. Check plugin đã enable chưa:
   - `Project > Project Settings > Plugins`
   - Tìm "Gut" và check "Enable"
2. Restart Godot Editor
3. Nếu vẫn không có, cài lại addon từ AssetLib

### Vấn đề 2: GUT không tìm thấy test files

**Triệu chứng:**
- Click "Run All" nhưng không có tests chạy
- Message: "No tests found"

**Giải pháp:**
1. Check đường dẫn directory đúng chưa: `res://tests/`
2. Check "Include Subdirectories" đã được check chưa
3. Check test files có extension `.gd` chưa
4. Check test files có extend `GutTest` chưa:
   ```gdscript
   extends GutTest  # ← Dòng này phải có ở đầu file
   ```

### Vấn đề 3: Tests fail với lỗi "Autoload not found"

**Triệu chứng:**
```
✗ test_building_system_core.gd
  Error: Building_System not found
```

**Giải pháp:**
Check autoloads đã được thêm chưa:
1. `Project > Project Settings > Autoload`
2. Phải có các autoloads sau:
   - `Building_System` → `res://scripts/systems/building_system.gd`
   - `ResourceManager` → `res://autoloads/resource_manager.gd`
   - `EventBus` → `res://autoloads/EventBus.gd`

### Vấn đề 4: Tests fail với lỗi "Scene not found"

**Triệu chứng:**
```
✗ test_turret.gd
  Error: Failed to load scene: res://scenes/structures/Turret.tscn
```

**Giải pháp:**
Check các scene files tồn tại:
- `scenes/structures/Wall.tscn`
- `scenes/structures/Turret.tscn`
- `scenes/structures/CraftingStation.tscn`
- `scenes/structures/StorageChest.tscn`
- `scenes/structures/TurretProjectile.tscn`
- `scenes/ui/Build_UI.tscn`
- `scenes/ui/Placement_Preview.tscn`

---

## 📊 Expected Results

Nếu mọi thứ hoạt động đúng, bạn sẽ thấy:

```
═══════════════════════════════════════════════════════════════
Summary:
✓ 153 tests passed
✗ 0 tests failed
⊘ 0 tests skipped
Total time: ~2-5 seconds
═══════════════════════════════════════════════════════════════
```

**Lưu ý:** Một số tests có thể skip nếu thiếu dependencies (scenes, autoloads). Đây là bình thường.

---

## 🎯 Next Steps

Sau khi tests chạy thành công:

1. **Nếu tất cả tests pass (green):**
   - ✅ Building System hoạt động đúng!
   - Tiếp tục với manual testing trong game (Press F5)

2. **Nếu có tests fail (red):**
   - Xem chi tiết lỗi trong GUT panel
   - Fix issues theo hướng dẫn troubleshooting
   - Chạy lại tests

3. **Manual Testing:**
   - Press F5 để run game
   - Press B để test build mode
   - Test placement, combat, demolition
   - Xem `BUILDING_SYSTEM_REFERENCE.md` để biết controls

---

**Chúc bạn testing thành công! 🧪✨**

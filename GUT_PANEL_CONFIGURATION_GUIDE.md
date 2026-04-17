# Hướng Dẫn Cấu Hình GUT Panel Chi Tiết

## 📋 Mục Lục
1. [Mở GUT Panel](#1-mở-gut-panel)
2. [Cấu Hình Test Directory](#2-cấu-hình-test-directory)
3. [Cấu Hình Settings](#3-cấu-hình-settings)
4. [Chạy Tests](#4-chạy-tests)
5. [Đọc Kết Quả](#5-đọc-kết-quả)
6. [Troubleshooting](#6-troubleshooting)

---

## 1. Mở GUT Panel

### Cách 1: Từ Menu
```
┌─────────────────────────────────────────┐
│ Project > Tools > Gut                   │
└─────────────────────────────────────────┘
```

### Cách 2: Từ Bottom Panel
```
┌──────────────────────────────────────────────────────────┐
│ [Output] [Debugger] [Audio] [Animation] [Gut] ← Click   │
└──────────────────────────────────────────────────────────┘
```

### Giao Diện GUT Panel
```
╔═══════════════════════════════════════════════════════════╗
║                      GUT PANEL                            ║
╠═══════════════════════════════════════════════════════════╣
║                                                           ║
║  ┌─────────────────────────────────────────────────┐     ║
║  │ [Run All]  [Run at Cursor]  [Stop]              │     ║
║  └─────────────────────────────────────────────────┘     ║
║                                                           ║
║  ┌─────────────────────────────────────────────────┐     ║
║  │ Settings                                        │     ║
║  │  ├─ Directories/Scripts                         │     ║
║  │  ├─ Output                                      │     ║
║  │  ├─ Misc                                        │     ║
║  │  └─ Advanced                                    │     ║
║  └─────────────────────────────────────────────────┘     ║
║                                                           ║
║  ┌─────────────────────────────────────────────────┐     ║
║  │ Results                                         │     ║
║  │  (Test results will appear here)                │     ║
║  └─────────────────────────────────────────────────┘     ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
```

---

## 2. Cấu Hình Test Directory

### Bước 1: Mở Settings Section
Click vào "Settings" để expand:

```
┌─────────────────────────────────────────────────────┐
│ ▼ Settings                                          │
│   ├─ ▶ Directories/Scripts  ← Click để expand      │
│   ├─ ▶ Output                                       │
│   ├─ ▶ Misc                                         │
│   └─ ▶ Advanced                                     │
└─────────────────────────────────────────────────────┘
```

### Bước 2: Expand Directories/Scripts
Click vào "Directories/Scripts":

```
┌─────────────────────────────────────────────────────┐
│ ▼ Settings                                          │
│   ├─ ▼ Directories/Scripts                          │
│   │   ├─ Directory 1: [_______________] [Browse]    │
│   │   ├─ Directory 2: [_______________] [Browse]    │
│   │   ├─ Directory 3: [_______________] [Browse]    │
│   │   ├─ [☐] Include Subdirectories                 │
│   │   └─ Test Prefix: test_                         │
│   ├─ ▶ Output                                       │
│   ├─ ▶ Misc                                         │
│   └─ ▶ Advanced                                     │
└─────────────────────────────────────────────────────┘
```

### Bước 3: Thêm Test Directory
1. Click vào ô "Directory 1"
2. Nhập: `res://tests/`
3. Hoặc click [Browse] và chọn thư mục `tests/`

```
┌─────────────────────────────────────────────────────┐
│ ▼ Directories/Scripts                               │
│   ├─ Directory 1: [res://tests/    ] [Browse]      │
│   │                 ↑                               │
│   │                 Nhập đường dẫn này              │
│   ├─ Directory 2: [_______________] [Browse]        │
│   ├─ Directory 3: [_______________] [Browse]        │
│   ├─ [☐] Include Subdirectories                     │
│   └─ Test Prefix: test_                             │
└─────────────────────────────────────────────────────┘
```

### Bước 4: Enable Include Subdirectories
Check vào ô "Include Subdirectories" để chạy tests trong `tests/unit/`:

```
┌─────────────────────────────────────────────────────┐
│ ▼ Directories/Scripts                               │
│   ├─ Directory 1: [res://tests/    ] [Browse]      │
│   ├─ Directory 2: [_______________] [Browse]        │
│   ├─ Directory 3: [_______________] [Browse]        │
│   ├─ [☑] Include Subdirectories  ← Check vào đây   │
│   │       ↑                                         │
│   │       Quan trọng!                               │
│   └─ Test Prefix: test_                             │
└─────────────────────────────────────────────────────┘
```

### Kết Quả Sau Khi Cấu Hình
```
┌─────────────────────────────────────────────────────┐
│ ▼ Directories/Scripts                               │
│   ├─ Directory 1: [res://tests/    ] [Browse]      │
│   ├─ Directory 2: [_______________] [Browse]        │
│   ├─ Directory 3: [_______________] [Browse]        │
│   ├─ [☑] Include Subdirectories                     │
│   └─ Test Prefix: test_                             │
│                                                     │
│   GUT sẽ tìm các files:                             │
│   ✓ res://tests/test_*.gd                           │
│   ✓ res://tests/unit/test_*.gd                      │
└─────────────────────────────────────────────────────┘
```

---

## 3. Cấu Hình Settings

### Output Settings (Tùy chọn)
```
┌─────────────────────────────────────────────────────┐
│ ▼ Output                                            │
│   ├─ Log Level: [Info ▼]                            │
│   │   Options: Quiet, Normal, Info, Debug           │
│   ├─ [☑] Print Passing Tests                        │
│   ├─ [☑] Print Failures                             │
│   └─ [☐] Print Orphans                              │
└─────────────────────────────────────────────────────┘
```

**Khuyến nghị:**
- Log Level: **Info** (để xem chi tiết)
- Print Passing Tests: **Checked** (để thấy tests pass)
- Print Failures: **Checked** (để debug)

### Misc Settings (Tùy chọn)
```
┌─────────────────────────────────────────────────────┐
│ ▼ Misc                                              │
│   ├─ [☐] Run on Load                                │
│   ├─ [☐] Minimize Maximize on Run                   │
│   └─ [☑] Yield Between Tests                        │
└─────────────────────────────────────────────────────┘
```

**Khuyến nghị:**
- Run on Load: **Unchecked** (chạy manual)
- Yield Between Tests: **Checked** (tránh conflicts)

---

## 4. Chạy Tests

### Các Nút Chức Năng
```
┌─────────────────────────────────────────────────────┐
│ [Run All]  [Run at Cursor]  [Stop]  [Clear]        │
│    ↑            ↑              ↑        ↑           │
│    │            │              │        │           │
│    │            │              │        └─ Xóa kết quả
│    │            │              └─ Dừng tests        │
│    │            └─ Chạy test tại cursor             │
│    └─ Chạy tất cả tests                             │
└─────────────────────────────────────────────────────┘
```

### Cách 1: Chạy Tất Cả Tests
1. Click nút **[Run All]**
2. Chờ tests chạy xong
3. Xem kết quả trong Results panel

```
┌─────────────────────────────────────────────────────┐
│ [Run All] ← Click vào đây                           │
└─────────────────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────────────────┐
│ Running tests...                                    │
│ ████████████████████░░░░░░░░░░ 65%                  │
└─────────────────────────────────────────────────────┘
```

### Cách 2: Chạy Test File Cụ Thể
1. Mở test file trong editor (ví dụ: `test_turret.gd`)
2. Click vào bất kỳ dòng nào trong file
3. Click nút **[Run at Cursor]**

```
Editor:
┌─────────────────────────────────────────────────────┐
│ test_turret.gd                                      │
│ ─────────────────────────────────────────────────── │
│ 1  extends GutTest                                  │
│ 2                                                   │
│ 3  func test_turret_properties():                   │
│ 4      var turret = preload(...).instantiate()     │
│ 5      assert_eq(turret.max_health, 150)           │
│    ↑ Cursor ở đây                                   │
└─────────────────────────────────────────────────────┘
         ↓
GUT Panel:
┌─────────────────────────────────────────────────────┐
│ [Run at Cursor] ← Click vào đây                     │
└─────────────────────────────────────────────────────┘
```

### Cách 3: Chạy Test Method Cụ Thể
1. Mở test file
2. Đặt cursor vào test method muốn chạy
3. Click **[Run at Cursor]**

```
┌─────────────────────────────────────────────────────┐
│ func test_turret_properties():                      │
│     var turret = preload(...).instantiate()         │
│     assert_eq(turret.max_health, 150)               │
│     ↑ Cursor ở đây                                  │
│                                                     │
│ func test_turret_ai_scanning():                     │
│     var turret = preload(...).instantiate()         │
│     # ...                                           │
└─────────────────────────────────────────────────────┘

Chỉ chạy test_turret_properties(), không chạy test_turret_ai_scanning()
```

---

## 5. Đọc Kết Quả

### Giao Diện Results Panel
```
╔═══════════════════════════════════════════════════════════╗
║ Results                                                   ║
╠═══════════════════════════════════════════════════════════╣
║                                                           ║
║  Tests Run: 153                                           ║
║  Passed: 150 ✓                                            ║
║  Failed: 3 ✗                                              ║
║  Pending: 0                                               ║
║  Orphans: 0                                               ║
║                                                           ║
║  ─────────────────────────────────────────────────────   ║
║                                                           ║
║  ✓ test_building_system_core.gd (40/40)                  ║
║  ✓ test_structure_base.gd (24/24)                        ║
║  ✓ test_wall.gd (6/6)                                    ║
║  ✗ test_turret.gd (17/20)                                ║
║    ├─ ✓ test_turret_properties                           ║
║    ├─ ✓ test_turret_ai_constants                         ║
║    ├─ ✗ test_turret_rotation                             ║
║    │   Expected: 1.5708                                  ║
║    │   Got: 1.5707                                       ║
║    │   at line 45                                        ║
║    └─ ...                                                ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
```

### Ý Nghĩa Các Ký Hiệu
```
✓ = Test passed (màu xanh)
✗ = Test failed (màu đỏ)
⊙ = Test pending (màu vàng)
⚠ = Warning/Orphan (màu cam)
```

### Chi Tiết Test Failed
```
┌─────────────────────────────────────────────────────┐
│ ✗ test_turret_rotation                              │
│   ├─ File: res://tests/test_turret.gd               │
│   ├─ Line: 45                                       │
│   ├─ Expected: 1.5708                               │
│   ├─ Got: 1.5707                                    │
│   └─ Stack Trace:                                   │
│       at test_turret_rotation (test_turret.gd:45)   │
│       at _run_test (gut.gd:1234)                    │
└─────────────────────────────────────────────────────┘
```

### Summary Statistics
```
┌─────────────────────────────────────────────────────┐
│ Summary:                                            │
│ ─────────────────────────────────────────────────── │
│ Total Tests:     153                                │
│ Passed:          150 (98.0%)                        │
│ Failed:          3   (2.0%)                         │
│ Pending:         0   (0.0%)                         │
│ Orphans:         0                                  │
│ Time:            2.34s                              │
└─────────────────────────────────────────────────────┘
```

---

## 6. Troubleshooting

### Vấn Đề 1: Không Thấy GUT Panel

**Triệu chứng:**
```
┌─────────────────────────────────────────────────────┐
│ [Output] [Debugger] [Audio] [Animation]            │
│                                     ↑               │
│                                     Không có [Gut]  │
└─────────────────────────────────────────────────────┘
```

**Giải pháp:**
1. Kiểm tra plugin đã enable:
   ```
   Project > Project Settings > Plugins
   ├─ Gut [☑] Enabled  ← Phải checked
   ```

2. Restart Godot Editor

3. Kiểm tra thư mục `addons/gut/` tồn tại:
   ```
   ChronoRiftGame/
   └── addons/
       └── gut/
           ├── plugin.cfg  ← File này phải có
           ├── gut.gd
           └── ...
   ```

### Vấn Đề 2: Không Tìm Thấy Test Files

**Triệu chứng:**
```
┌─────────────────────────────────────────────────────┐
│ Results:                                            │
│ No tests found in res://tests/                     │
└─────────────────────────────────────────────────────┘
```

**Giải pháp:**
1. Kiểm tra đường dẫn directory:
   ```
   Directory 1: [res://tests/] ← Phải đúng
   ```

2. Kiểm tra test files có prefix đúng:
   ```
   ✓ test_turret.gd        ← Đúng
   ✗ turret_test.gd        ← Sai
   ✗ my_test.gd            ← Sai
   ```

3. Kiểm tra test files extend GutTest:
   ```gdscript
   extends GutTest  # ← Dòng đầu tiên phải có
   
   func test_something():
       pass
   ```

### Vấn Đề 3: Tests Fail Do Missing Dependencies

**Triệu chứng:**
```
┌─────────────────────────────────────────────────────┐
│ ✗ test_building_system_core                         │
│   Error: Cannot find autoload 'Building_System'    │
└─────────────────────────────────────────────────────┘
```

**Giải pháp:**
1. Kiểm tra autoloads:
   ```
   Project > Project Settings > Autoload
   ├─ Building_System: scripts/systems/building_system.gd
   ├─ ResourceManager: autoloads/resource_manager.gd
   └─ EventBus: autoloads/EventBus.gd
   ```

2. Kiểm tra scenes tồn tại:
   ```
   scenes/
   ├── structures/
   │   ├── Wall.tscn           ← Phải có
   │   ├── Turret.tscn         ← Phải có
   │   └── ...
   ```

3. Kiểm tra data files:
   ```
   data/
   └── structures.json  ← Phải có
   ```

### Vấn Đề 4: Tests Chạy Chậm

**Triệu chứng:**
```
Running tests... (takes > 30 seconds)
```

**Giải pháp:**
1. Disable "Print Passing Tests" nếu không cần:
   ```
   Output
   ├─ [☐] Print Passing Tests  ← Uncheck
   ```

2. Chạy từng test file thay vì Run All:
   ```
   [Run at Cursor] thay vì [Run All]
   ```

3. Disable "Include Subdirectories" nếu không cần:
   ```
   [☐] Include Subdirectories
   ```

### Vấn Đề 5: Orphan Nodes Warning

**Triệu chứng:**
```
┌─────────────────────────────────────────────────────┐
│ ⚠ Orphans: 5                                        │
│   - Node (Structure)                                │
│   - Node2D (Turret)                                 │
└─────────────────────────────────────────────────────┘
```

**Giải pháp:**
1. Thêm `queue_free()` trong tests:
   ```gdscript
   func test_something():
       var node = preload("...").instantiate()
       add_child(node)
       # ... test logic ...
       node.queue_free()  # ← Thêm dòng này
   ```

2. Hoặc dùng `autofree()`:
   ```gdscript
   func test_something():
       var node = autofree(preload("...").instantiate())
       add_child(node)
       # ... test logic ...
       # Tự động free khi test kết thúc
   ```

---

## 7. Tips & Best Practices

### Tip 1: Sử Dụng Shortcuts
```
Ctrl + Shift + T  = Chạy test tại cursor (nếu đã cấu hình)
F6                = Chạy test scene
```

### Tip 2: Organize Tests
```
tests/
├── unit/              # Unit tests (isolated)
│   └── test_*.gd
├── integration/       # Integration tests
│   └── test_*.gd
└── test_*.gd          # General tests
```

### Tip 3: Sử Dụng Test Prefixes
```gdscript
# Trong test file:
func test_basic_functionality():  # Chạy mặc định
    pass

func xtest_work_in_progress():    # Skip (prefix 'x')
    pass

func ptest_pending_feature():     # Pending (prefix 'p')
    pass
```

### Tip 4: Debug Tests
```gdscript
func test_something():
    var result = some_function()
    print("Debug: result = ", result)  # ← Thêm print
    assert_eq(result, expected)
```

### Tip 5: Sử Dụng Before/After
```gdscript
extends GutTest

var building_system

func before_each():
    # Chạy trước mỗi test
    building_system = Building_System
    building_system.reset()

func after_each():
    # Chạy sau mỗi test
    building_system.clear_all()

func test_something():
    # Test logic
    pass
```

---

## 8. Cấu Hình Nâng Cao

### Tạo GUT Config File
Tạo file `.gutconfig.json` trong root project:

```json
{
  "dirs": ["res://tests/"],
  "include_subdirs": true,
  "log_level": 1,
  "should_maximize": true,
  "compact_mode": false,
  "junit_xml_file": "res://test_results.xml",
  "junit_xml_timestamp": true
}
```

### Chạy Tests Với Config File
```bash
godot --path ChronoRiftGame -s addons/gut/gut_cmdln.gd -gconfig=.gutconfig.json -gexit
```

### Export Test Results
```bash
# Export to XML (for CI/CD)
godot --path ChronoRiftGame -s addons/gut/gut_cmdln.gd \
  -gdir=res://tests/ \
  -gjunit_xml_file=test_results.xml \
  -gexit
```

---

## 9. Checklist Cấu Hình Hoàn Chỉnh

```
☐ 1. GUT addon đã được cài đặt
☐ 2. GUT plugin đã được enable
☐ 3. GUT panel hiển thị trong bottom panel
☐ 4. Directory 1 = res://tests/
☐ 5. Include Subdirectories = checked
☐ 6. Test Prefix = test_
☐ 7. Log Level = Info
☐ 8. Print Passing Tests = checked
☐ 9. Print Failures = checked
☐ 10. Yield Between Tests = checked
☐ 11. Autoloads đã được cấu hình
☐ 12. Test files tồn tại trong tests/
☐ 13. Chạy [Run All] thành công
☐ 14. Không có orphan nodes
☐ 15. Tất cả tests pass (hoặc biết lý do fail)
```

---

## 10. Kết Luận

Sau khi hoàn thành hướng dẫn này, bạn đã:

✅ Biết cách mở và sử dụng GUT panel
✅ Cấu hình test directory đúng cách
✅ Chạy tests và đọc kết quả
✅ Debug và fix các vấn đề thường gặp
✅ Sử dụng các tính năng nâng cao

**Next Steps:**
1. Chạy tất cả 153 tests của Building System
2. Fix các tests fail (nếu có)
3. Viết thêm tests cho features mới
4. Integrate vào CI/CD pipeline (optional)

**Tài Liệu Tham Khảo:**
- GUT Documentation: https://github.com/bitwes/Gut/wiki
- GUT API Reference: https://bitwes.github.io/Gut/
- Godot Testing Best Practices: https://docs.godotengine.org/en/stable/tutorials/scripting/unit_testing.html

---

**Version:** 1.0  
**Last Updated:** 2026-04-17  
**Author:** Kiro AI Assistant

Happy Testing! 🧪✨

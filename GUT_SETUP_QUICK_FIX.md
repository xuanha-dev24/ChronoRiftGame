# GUT Setup - Quick Fix Guide

## ❌ Lỗi Bạn Đang Gặp

```
Cannot run tests, you have a
* You do not have any directories to test.
Check your settings ----->
```

**Nguyên nhân:** GUT chưa được cấu hình test directory.

---

## ✅ Giải Pháp - 5 Bước Đơn Giản

### Bước 1: Mở GUT Settings
Trong GUT panel (bottom), tìm và click vào biểu tượng **bánh răng (⚙️)** hoặc **"..."** ở góc phải:

```
┌────────────────────────────────────────────────┐
│ [Run All]  [+]  [Passing]  [Sync]  [⚙️] [...]  │
│                                      ↑    ↑    │
│                                      Click đây │
└────────────────────────────────────────────────┘
```

### Bước 2: Tìm "Directories/Scripts"
Trong menu settings, scroll xuống tìm section **"Directories/Scripts"**

### Bước 3: Thêm Test Directory
1. Tìm dòng **"Dir 1"** hoặc **"Directory 1"**
2. Click vào ô input bên cạnh
3. Nhập: `res://tests/`

```
┌────────────────────────────────────────────────┐
│ Directories/Scripts                            │
│ ─────────────────────────────────────────────  │
│ Dir 1: [res://tests/              ] [📁]      │
│         ↑ Nhập vào đây                         │
└────────────────────────────────────────────────┘
```

### Bước 4: Enable "Include Subdirectories"
Tìm checkbox **"Include Subdirectories"** và check vào:

```
┌────────────────────────────────────────────────┐
│ [☑] Include Subdirectories                     │
│  ↑ Check vào đây                               │
└────────────────────────────────────────────────┘
```

### Bước 5: Đóng Settings và Chạy Test
1. Click nút **"X"** hoặc click ra ngoài để đóng settings
2. Click nút **[Run All]** để chạy tests

```
┌────────────────────────────────────────────────┐
│ [▶ Run All] ← Click vào đây                    │
└────────────────────────────────────────────────┘
```

---

## 🎯 Cấu Hình Đầy Đủ

Sau khi làm 5 bước trên, settings của bạn nên như sau:

```
Directories/Scripts:
├─ Dir 1: res://tests/
├─ Dir 2: (empty)
├─ Dir 3: (empty)
├─ [☑] Include Subdirectories
└─ Prefix: test_
```

---

## 🔍 Kiểm Tra Lại

### 1. Kiểm tra thư mục tests/ tồn tại
```
ChronoRiftGame/
└── tests/
    ├── test_building_system_core.gd
    ├── test_structure_base.gd
    ├── test_wall.gd
    └── ... (các test files khác)
```

### 2. Kiểm tra test files có đúng format
Mở 1 test file, dòng đầu tiên phải là:
```gdscript
extends GutTest
```

### 3. Chạy lại test
Click **[Run All]** và xem kết quả.

---

## 📸 Hình Ảnh Minh Họa

### Trước khi cấu hình:
```
┌────────────────────────────────────────────────┐
│ Cannot run tests, you have a                   │
│ * You do not have any directories to test.     │
│ Check your settings ----->                     │
└────────────────────────────────────────────────┘
```

### Sau khi cấu hình:
```
┌────────────────────────────────────────────────┐
│ Running tests...                               │
│ ████████████████████████████ 100%              │
│                                                │
│ Tests Run: 153                                 │
│ Passed: 153 ✓                                  │
│ Failed: 0                                      │
└────────────────────────────────────────────────┘
```

---

## 🚨 Vẫn Không Được?

### Vấn đề 1: Không tìm thấy settings icon
**Giải pháp:** 
- Thử click vào **"..."** (3 chấm) ở góc phải GUT panel
- Hoặc right-click vào GUT panel

### Vấn đề 2: Không có thư mục tests/
**Giải pháp:**
```bash
# Tạo thư mục tests
mkdir ChronoRiftGame/tests
```

### Vấn đề 3: GUT panel không hiển thị
**Giải pháp:**
1. Vào `Project > Project Settings > Plugins`
2. Tìm "Gut"
3. Check vào "Enable"
4. Restart Godot

### Vấn đề 4: Test files không được tìm thấy
**Giải pháp:**
- Đảm bảo test files có tên bắt đầu bằng `test_`
- Ví dụ: `test_turret.gd` ✓, `turret_test.gd` ✗

---

## 📋 Checklist Nhanh

```
☐ 1. GUT plugin đã enable
☐ 2. GUT panel hiển thị ở bottom
☐ 3. Click vào settings icon (⚙️ hoặc ...)
☐ 4. Thêm Dir 1: res://tests/
☐ 5. Check "Include Subdirectories"
☐ 6. Đóng settings
☐ 7. Click [Run All]
☐ 8. Tests chạy thành công!
```

---

## 🎓 Video Tutorial (Text-based)

```
Step 1: Open GUT Panel
[Bottom Panel] → [GUT] tab

Step 2: Open Settings
[GUT Panel] → Click [⚙️] or [...]

Step 3: Add Directory
[Directories/Scripts] → Dir 1: type "res://tests/"

Step 4: Enable Subdirectories
[Include Subdirectories] → Check ☑

Step 5: Run Tests
[Close Settings] → Click [▶ Run All]

Result: Tests running! 🎉
```

---

## 💡 Pro Tips

### Tip 1: Shortcut để mở settings
```
Right-click vào GUT panel → Settings
```

### Tip 2: Xem test files được tìm thấy
Sau khi cấu hình, GUT sẽ hiển thị danh sách test files trong panel.

### Tip 3: Chạy test file cụ thể
```
1. Mở test file trong editor
2. Click vào file
3. Click [Run at Cursor] trong GUT panel
```

### Tip 4: Debug nếu tests fail
```
1. Click vào test failed trong results
2. Xem error message
3. Double-click để jump to line
```

---

## 📞 Cần Thêm Giúp Đỡ?

Nếu vẫn gặp vấn đề, hãy kiểm tra:

1. **GUT version:** Đảm bảo dùng GUT 9.x trở lên
2. **Godot version:** Đảm bảo dùng Godot 4.x
3. **File permissions:** Đảm bảo có quyền đọc thư mục tests/
4. **Console errors:** Xem Output tab có error gì không

---

**Chúc bạn setup thành công! 🚀**

Sau khi setup xong, bạn sẽ có 153 tests sẵn sàng để chạy cho Building System!

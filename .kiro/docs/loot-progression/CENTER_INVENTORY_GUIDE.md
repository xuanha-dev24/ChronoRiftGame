# Hướng Dẫn Tạo Inventory UI Luôn Ở Giữa Màn Hình

## Tổng Quan

Hướng dẫn này giải thích cách tạo Inventory UI luôn nằm chính giữa màn hình, kể cả khi thay đổi độ phân giải cửa sổ, sử dụng hệ thống UI Containers và Anchors của Godot.

---

## Phần 1: Hiểu Về Anchors

### Anchors Là Gì?

**Anchors** (điểm neo) xác định vị trí của UI node **tương đối** với parent node, sử dụng giá trị từ 0.0 đến 1.0:

- `0.0` = cạnh trái/trên
- `0.5` = giữa
- `1.0` = cạnh phải/dưới

### Ví Dụ Anchors

```
Anchor Left = 0.0, Anchor Right = 1.0
→ Node kéo dài toàn bộ chiều ngang

Anchor Left = 0.5, Anchor Right = 0.5
→ Node neo vào giữa theo chiều ngang

Anchor Top = 0.5, Anchor Bottom = 0.5
→ Node neo vào giữa theo chiều dọc
```

### Anchor Presets Trong Editor

Trong Godot Editor, click vào icon **Layout** (hình anchor) ở toolbar trên viewport để chọn preset:

| Preset | Vị Trí | Anchors |
|--------|--------|---------|
| **Top Left** | Góc trên trái | (0, 0, 0, 0) |
| **Center** | Giữa màn hình | (0.5, 0.5, 0.5, 0.5) |
| **Full Rect** | Toàn màn hình | (0, 0, 1, 1) |

---

## Phần 2: Cấu Trúc Scene Inventory UI

### Hierarchy Đúng Chuẩn

```
Inventory_UI (Control) - Root, Full Rect
└── CenterContainer - Full Rect, tự động center children
    └── PanelContainer - Nền inventory
        └── MarginContainer - Padding 10px
            └── VBoxContainer - Layout dọc
                ├── Title (Label) - "Inventory"
                └── GridContainer - 6 cột, chứa items
```

### Tại Sao Dùng CenterContainer?

**CenterContainer** tự động căn giữa tất cả children nodes, bất kể kích thước window. Đây là cách **đơn giản nhất** để center UI.

### Tại Sao Dùng PanelContainer?

**PanelContainer** tự động thêm background panel và điều chỉnh kích thước theo children, giúp UI responsive.

---

## Phần 3: Tạo Scene Từng Bước

### Bước 1: Tạo Root Node

1. **Scene → New Scene**
2. Chọn **User Interface** (hoặc **Control**)
3. Đổi tên thành `Inventory_UI`
4. Trong Inspector:
   - Click icon **Layout** → chọn **Full Rect**
   - Hoặc set thủ công:
     ```
     Anchor Left: 0
     Anchor Top: 0
     Anchor Right: 1
     Anchor Bottom: 1
     ```

**Kết quả:** Root node phủ toàn màn hình.

### Bước 2: Thêm CenterContainer

1. Click chuột phải vào `Inventory_UI` → **Add Child Node**
2. Tìm `CenterContainer` → Create
3. Trong Inspector:
   - Click icon **Layout** → chọn **Full Rect**

**Kết quả:** CenterContainer phủ toàn màn hình, sẵn sàng center children.

### Bước 3: Thêm PanelContainer

1. Click chuột phải vào `CenterContainer` → **Add Child Node**
2. Tìm `PanelContainer` → Create
3. Trong Inspector:
   - **Custom Minimum Size**: Width = `400`, Height = `500`

**Giải thích:** `custom_minimum_size` đảm bảo panel có kích thước cố định 400x500, nhưng vẫn được center bởi CenterContainer.

### Bước 4: Thêm MarginContainer

1. Click chuột phải vào `PanelContainer` → **Add Child Node**
2. Tìm `MarginContainer` → Create
3. Trong Inspector → **Theme Overrides → Constants**:
   - **Margin Left**: `10`
   - **Margin Top**: `10`
   - **Margin Right**: `10`
   - **Margin Bottom**: `10`

**Kết quả:** Tạo padding 10px xung quanh nội dung.

### Bước 5: Thêm VBoxContainer

1. Click chuột phải vào `MarginContainer` → **Add Child Node**
2. Tìm `VBoxContainer` → Create

**Giải thích:** VBoxContainer sắp xếp children theo chiều dọc (Title ở trên, Grid ở dưới).

### Bước 6: Thêm Title Label

1. Click chuột phải vào `VBoxContainer` → **Add Child Node** → **Label**
2. Đổi tên thành `Title`
3. Set **Text**: `Inventory`
4. **Horizontal Alignment**: Center
5. **Vertical Alignment**: Center

### Bước 7: Thêm GridContainer

1. Click chuột phải vào `VBoxContainer` → **Add Child Node** → **GridContainer**
2. Trong Inspector:
   - **Columns**: `6`
   - **Size Flags → Vertical**: Check **Expand** (để fill không gian còn lại)
3. Trong **Theme Overrides → Constants**:
   - **H Separation**: `8`
   - **V Separation**: `8`

**Kết quả:** Grid 6 cột, tự động mở rộng để fill panel.

### Bước 8: Thêm TooltipPanel

1. Click chuột phải vào `Inventory_UI` (root) → **Add Child Node** → **Panel**
2. Đổi tên thành `TooltipPanel`
3. **Size**: Width = `200`, Height = `100`
4. **Visible**: ❌ Uncheck
5. Thêm **VBoxContainer** làm child
6. Thêm 2 **Label** vào VBoxContainer:
   - `ItemName` - Horizontal Alignment: Center
   - `ItemDescription` - Autowrap Mode: Word

---

## Phần 4: Script Ẩn/Hiện Inventory

### Script Đơn Giản

```gdscript
# inventory_ui.gd
extends Control

var is_open: bool = false

func _ready() -> void:
	visible = false  # Ẩn khi bắt đầu

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("open_inventory"):
		toggle_inventory()

func toggle_inventory() -> void:
	is_open = !is_open
	visible = is_open
	
	# Pause game khi mở inventory (optional)
	get_tree().paused = is_open
```

### Giải Thích

- `visible = false` - Ẩn inventory khi game bắt đầu
- `_input()` - Lắng nghe phím I (action "open_inventory")
- `toggle_inventory()` - Đảo trạng thái hiện/ẩn
- `get_tree().paused` - Tạm dừng game khi mở inventory (optional)

### Đăng Ký Input Action

1. **Project → Project Settings → Input Map**
2. Thêm action mới: `open_inventory`
3. Click **+** → chọn **Key** → nhấn phím **I**
4. Click **Add**

---

## Phần 5: Tại Sao Cách Này Luôn Center?

### Cơ Chế Hoạt Động

```
1. Inventory_UI (Full Rect)
   → Phủ toàn màn hình (0,0) đến (width, height)

2. CenterContainer (Full Rect)
   → Cũng phủ toàn màn hình
   → Tự động tính toán vị trí center

3. PanelContainer (custom_minimum_size = 400x500)
   → CenterContainer đặt nó tại:
      X = (screen_width / 2) - (400 / 2)
      Y = (screen_height / 2) - (500 / 2)
```

### Khi Resize Window

- Screen width thay đổi → CenterContainer tự động tính lại X
- Screen height thay đổi → CenterContainer tự động tính lại Y
- Panel **luôn ở giữa** mà không cần code

---

## Phần 6: So Sánh Với Cách Cũ (Sai)

### ❌ Cách Sai: Dùng Offset Cố Định

```
Panel:
  position = (200, 150)  # Cố định!
```

**Vấn đề:** Khi resize window, panel vẫn ở (200, 150) → không còn center.

### ✅ Cách Đúng: Dùng Anchors + CenterContainer

```
Inventory_UI (Full Rect)
└── CenterContainer (Full Rect)
    └── PanelContainer (custom_minimum_size)
```

**Ưu điểm:**
- Tự động center khi resize
- Không cần code tính toán
- Responsive với mọi độ phân giải

---

## Phần 7: Testing

### Test Resize Window

1. Run game (F5)
2. Mở inventory (I)
3. Resize window (kéo góc)
4. **Kết quả:** Panel luôn ở giữa

### Test Fullscreen

1. Run game (F5)
2. Toggle fullscreen (F11)
3. Mở inventory (I)
4. **Kết quả:** Panel vẫn center

---

## Phần 8: Troubleshooting

### Vấn Đề: Panel không ở giữa

**Nguyên nhân:** CenterContainer không có Full Rect anchors.

**Fix:**
1. Click vào CenterContainer
2. Icon Layout → chọn Full Rect

### Vấn Đề: Panel quá nhỏ/lớn

**Nguyên nhân:** `custom_minimum_size` không đúng.

**Fix:**
1. Click vào PanelContainer
2. Trong Inspector, điều chỉnh **Custom Minimum Size**

### Vấn Đề: Panel bị offset khi add vào scene khác

**Nguyên nhân:** Node cha có transform offset.

**Fix:**
1. Mở scene cha (Prototype_World)
2. Click vào Inventory_UI instance
3. Trong Inspector, đảm bảo:
   - **Position**: (0, 0)
   - **Anchors**: Full Rect

---

## Tóm Tắt

### Công Thức Center UI

```
Root (Full Rect)
└── CenterContainer (Full Rect)
    └── Your UI (custom_minimum_size)
```

### Key Points

1. **CenterContainer** tự động center children
2. **Full Rect anchors** đảm bảo responsive
3. **custom_minimum_size** xác định kích thước UI
4. **Không cần code** để center

### Script Tối Thiểu

```gdscript
extends Control

func _ready():
	visible = false

func _input(event):
	if event.is_action_pressed("open_inventory"):
		visible = !visible
```

---

**Kết luận:** Với cấu trúc này, Inventory UI sẽ **luôn ở giữa màn hình** bất kể độ phân giải, không cần code phức tạp!

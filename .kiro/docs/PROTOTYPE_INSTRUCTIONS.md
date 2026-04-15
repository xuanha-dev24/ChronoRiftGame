# Prototype Instructions

## Phase 1: Tileset & Map ✅

Tôi đã tạo sẵn:
- `tileset_generator.gd` - Tạo tileset placeholder bằng code
- `prototype_world.gd` - Generate map 20x20 tự động

## Tạo Prototype_World.tscn

### Cách 1: Copy từ POC_World (Nhanh nhất)

1. Trong Godot, mở `POC_World.tscn`
2. **Scene > Save Scene As...**
3. Đặt tên: `Prototype_World.tscn`
4. Lưu vào: `res://scenes/world/Prototype_World.tscn`
5. Đổi script của root node:
   - Click vào `POC_World` (root)
   - Trong Inspector, đổi script từ `poc_world.gd` → `prototype_world.gd`
6. Save (Ctrl+S)

### Cách 2: Tạo mới từ đầu

1. **Scene > New Scene**
2. Chọn **2D Scene** (Node2D)
3. Đặt tên root: `Prototype_World`
4. Attach script: `res://scripts/world/prototype_world.gd`

5. Thêm các node con:

```
Prototype_World (Node2D)
├── TileMapLayer (TileMapLayer)
└── YSortRoot (Node2D, Y-Sort enabled)
    ├── Player (CharacterBody2D) [từ POC]
    └── SlimeBasic (CharacterBody2D) [từ POC]
```

6. **Instance Player và SlimeBasic:**
   - Nếu bạn đã save Player.tscn và SlimeBasic.tscn từ POC
   - Click chuột phải vào `YSortRoot` → **Instantiate Child Scene**
   - Chọn `Player.tscn` và `SlimeBasic.tscn`
   
   - Nếu chưa có scene riêng, copy từ POC_World

7. Save scene: `res://scenes/world/Prototype_World.tscn`

---

## Test Prototype

1. Press **F6** để chạy scene
2. Map sẽ tự động generate với:
   - Grass tiles (xanh lá)
   - Dirt patches (nâu)
   - Stone border (xám)
   - Water corners (xanh dương)
   - Trees và rocks để test Y-Sort

---

## Next Steps

Sau khi Prototype_World chạy được:

### Phase 2: Player Animations
- [ ] Tạo AnimationPlayer
- [ ] Idle animation
- [ ] Walk animation (4 hướng)
- [ ] Attack animation

### Phase 3: State Machine
- [ ] PlayerStateMachine
- [ ] States: Idle, Walk, Attack

### Phase 4: Polish
- [ ] Camera follow
- [ ] Hit feedback
- [ ] Sound effects

---

## Troubleshooting

**Lỗi: "Can't load tileset_generator.gd"**
→ Đảm bảo file đã được tạo ở `res://scripts/world/tileset_generator.gd`

**Map không hiện**
→ Kiểm tra TileMapLayer có trong scene không

**Tiles không đúng màu**
→ Chạy lại scene, tileset sẽ được generate lại

---

Làm xong Phase 1 rồi báo tôi nhé! 🎨

# POC Setup Instructions

## Mục tiêu POC
Validate 3 thứ duy nhất:
1. Player di chuyển isometric + Y-Sort đúng
2. Slime có HP, chết khi bị đánh
3. Chrono Rift SLOW mode làm chậm enemy

## Các bước tạo POC trong Godot Editor

### 1. Tạo POC_World.tscn

**File > New Scene**

Cấu trúc node:
```
POC_World (Node2D) [script: res://scripts/world/poc_world.gd]
├── TileMapLayer (TileMapLayer)
└── YSortRoot (Node2D, Y-Sort enabled)
    ├── Player (CharacterBody2D) [script: res://scripts/player/player_controller_poc.gd]
    │   ├── CollisionShape2D (CapsuleShape2D)
    │   ├── Sprite (ColorRect, size 16x24, color green)
    │   ├── AttackArea (Area2D)
    │   │   └── CollisionShape2D (CircleShape2D, radius 40)
    │   ├── AttackCooldown (Timer, wait_time=0.6, one_shot=true)
    │   └── ChronoRiftSystem (Node) [script: res://scripts/systems/chrono_rift_system_poc.gd]
    │       ├── CooldownTimer (Timer, one_shot=true)
    │       ├── SlowArea (Area2D)
    │       │   └── CollisionShape2D (CircleShape2D, radius 80)
    │       └── SlowVisual (ColorRect, size 160x160, offset -80,-80, color cyan alpha 0.2, visible=false)
    └── SlimeBasic (CharacterBody2D) [script: res://scripts/enemies/slime_basic_poc.gd]
        ├── CollisionShape2D (CircleShape2D, radius 12)
        ├── Sprite (ColorRect, size 24x20, color green)
        └── HPLabel (Label, position offset up)
```

### 2. Cấu hình chi tiết từng node

#### POC_World (Node2D)
- Attach script: `res://scripts/world/poc_world.gd`

#### TileMapLayer
- Để trống (hoặc vẽ background đơn giản)
- Không bắt buộc phải có tileset

#### YSortRoot (Node2D)
- **Inspector > Ordering > Y Sort Enabled**: ✅ Check

#### Player (CharacterBody2D)
- Attach script: `res://scripts/player/player_controller_poc.gd`
- Position: (640, 360) - giữa màn hình

**Player > CollisionShape2D**
- Shape: New CapsuleShape2D
- Height: 24, Radius: 8

**Player > Sprite (ColorRect)**
- Add Child Node → ColorRect
- Rename to "Sprite"
- Size: 16x24
- Color: Green (0.2, 0.8, 0.2)
- Position: offset để center với collision

**Player > AttackArea (Area2D)**
- Add Child Node → Area2D

**Player > AttackArea > CollisionShape2D**
- Shape: New CircleShape2D
- Radius: 40

**Player > AttackCooldown (Timer)**
- Wait Time: 0.6
- One Shot: ✅
- Connect signal `timeout` to player script method `_on_attack_cooldown_timeout`

**Player > ChronoRiftSystem (Node)**
- Attach script: `res://scripts/systems/chrono_rift_system_poc.gd`

**ChronoRiftSystem > CooldownTimer (Timer)**
- One Shot: ✅

**ChronoRiftSystem > SlowArea (Area2D)**

**ChronoRiftSystem > SlowArea > CollisionShape2D**
- Shape: New CircleShape2D
- Radius: 80

**ChronoRiftSystem > SlowVisual (ColorRect)**
- Size: 160x160
- Position: -80, -80 (để center)
- Color: Cyan với alpha 0.2 (0.0, 1.0, 1.0, 0.2)
- Visible: ❌ Uncheck (sẽ hiện khi dùng rift)

#### SlimeBasic (CharacterBody2D)
- Attach script: `res://scripts/enemies/slime_basic_poc.gd`
- Position: (700, 360) - gần player để test

**SlimeBasic > CollisionShape2D**
- Shape: New CircleShape2D
- Radius: 12

**SlimeBasic > Sprite (ColorRect)**
- Size: 24x20
- Color: Green (0.2, 0.8, 0.2)

**SlimeBasic > HPLabel (Label)**
- Text: "30 / 30"
- Position: offset lên trên sprite (0, -30)
- Horizontal Alignment: Center

### 3. Cấu hình Input Map (nếu chưa có)

**Project > Project Settings > Input Map**

Thêm actions:
- `attack` → Z key
- `use_chrono_rift` → X key

(WASD đã có sẵn từ lúc setup)

### 4. Save và Test

- Save scene: `res://scenes/world/POC_World.tscn`
- Press **F6** để chạy scene
- Test theo POC Acceptance Criteria

---

## POC Acceptance Criteria

### [1] Isometric movement
- [ ] Player di chuyển 8 hướng mượt (WASD)
- [ ] Di chuyển trông "đúng góc nhìn isometric"

### [2] Y-Sort
- [ ] Player đứng PHÍA TRÊN cái cây → cây đè lên player
- [ ] Player đứng PHÍA DƯỚI cái cây → player đè lên cây

### [3] Combat
- [ ] Nhấn Z khi đứng gần Slime → Slime mất HP
- [ ] Spam Z không có tác dụng (cooldown)
- [ ] Slime flash đỏ khi bị đánh
- [ ] Slime biến mất khi HP = 0

### [4] Chrono Rift
- [ ] Nhấn X → Slime chuyển màu xanh (bị slow)
- [ ] Vùng slow (cyan) hiện ra xung quanh Player
- [ ] Sau 3 giây Slime trở về màu bình thường
- [ ] X không dùng được trong 5 giây tiếp theo

---

## Troubleshooting

**Lỗi: "Can't open file 'player_controller_poc.gd'"**
→ Đảm bảo đã tạo đủ 4 file script POC

**Player không di chuyển**
→ Kiểm tra Input Map có `move_up/down/left/right`

**Attack không hoạt động**
→ Kiểm tra AttackArea có CollisionShape2D và signal timeout đã connect

**Chrono Rift không hoạt động**
→ Kiểm tra Input Map có `use_chrono_rift` (X key)

---

## Sau khi POC pass

Nếu tất cả criteria pass → Tech stack validated ✅

Tiếp theo: Chuyển sang Prototype với proper animation và tileset thật.

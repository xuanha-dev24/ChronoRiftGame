# Prototype Phase 3: State Machine

## ✅ Đã tạo:

**`player_state_machine.gd`** - State Machine cho Player với 4 states:
- **IDLE**: Đứng yên
- **WALK**: Di chuyển
- **ATTACK**: Đang tấn công
- **DEAD**: Chết

---

## 🎯 Setup trong Godot Editor:

### Bước 1: Thêm StateMachine vào Player

1. Mở scene **Prototype_World.tscn** (hoặc Player.tscn)
2. Click vào node **Player**
3. Click chuột phải vào **Player** → **Add Child Node**
4. Tìm **Node** → Create
5. Đổi tên thành **`StateMachine`**
6. Attach script: `res://scripts/player/player_state_machine.gd`

### Bước 2: Test State Machine

1. Save scene (Ctrl+S)
2. Chạy game (F6)
3. Mở **Output console** (tab dưới cùng)
4. Bạn sẽ thấy state transitions:
   - Đứng yên → "State: IDLE"
   - Di chuyển → "State: WALK"
   - Attack → "State: ATTACK"

---

## 🔧 Cấu trúc Player sau khi setup:

```
Player (CharacterBody2D) [script: player_controller_prototype.gd]
├── CollisionShape2D
├── Sprite (ColorRect)
├── AttackArea (Area2D)
├── AttackCooldown (Timer)
├── ChronoRiftSystem (Node)
├── AnimationController (Node)
│   └── AnimationPlayer
└── StateMachine (Node) [script: player_state_machine.gd] ← NEW!
```

---

## 🎮 State Machine Flow:

```
IDLE ←→ WALK
  ↓       ↓
  ATTACK ←┘
  
DEAD (terminal state)
```

### Transitions:

| From | To | Condition |
|------|-----|-----------|
| IDLE | WALK | velocity > 10 |
| IDLE | ATTACK | is_attacking = true |
| WALK | IDLE | velocity < 10 |
| WALK | ATTACK | is_attacking = true |
| ATTACK | IDLE | attack finished + not moving |
| ATTACK | WALK | attack finished + moving |
| Any | DEAD | HP <= 0 |

---

## 🚀 Next Steps:

State Machine đã sẵn sàng! Bây giờ có thể:

### Phase 4: Polish & Feel
- Camera follow
- Screen shake
- Particle effects
- Sound effects

### Phase 5: Map & World
- Import tileset thật
- Vẽ map đẹp
- Decorations

### Phase 6: Enemy AI
- Enemy State Machine
- Pathfinding
- New enemy types

---

## ✅ Checklist:

- [ ] StateMachine node đã thêm vào Player
- [ ] Script đã attach
- [ ] Chạy game → State transitions hoạt động
- [ ] Console hiển thị state changes

Làm xong báo tôi nhé! 🎮

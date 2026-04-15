# Prototype Phase 4: Polish & Feel

## ✅ Đã tạo:

1. **`smooth_camera.gd`** - Camera mượt với:
   - Smooth follow player
   - Look-ahead (nhìn trước hướng di chuyển)
   - Screen shake system

2. **`hit_effect.gd`** - Particle effect khi hit

3. **`effect_manager.gd`** - Quản lý effects:
   - Screen shake khi attack
   - Hit particles
   - Chrono rift effects

---

## 🎯 Setup trong Godot Editor:

### Bước 1: Tạo Camera

1. Mở scene **Prototype_World.tscn**
2. Click chuột phải vào **Prototype_World** (root) → **Add Child Node**
3. Tìm **Camera2D** → Create
4. Đổi tên thành **`MainCamera`**
5. Attach script: `res://scripts/camera/smooth_camera.gd`
6. Trong Inspector:
   - **Enabled**: ✅ Check
   - **Zoom**: (1, 1) hoặc (1.5, 1.5) nếu muốn zoom in
7. Click vào **MainCamera** → **Node** tab (bên cạnh Inspector)
8. Trong **Groups**, thêm group: `camera`

### Bước 2: Thêm Player vào group

1. Click vào node **Player**
2. **Node** tab → **Groups**
3. Thêm group: `player`

### Bước 3: Tạo HitEffect scene

1. **Scene > New Scene**
2. Chọn **2D Scene** (Node2D)
3. Đặt tên root: `HitEffect`
4. Attach script: `res://scripts/effects/hit_effect.gd`

5. Thêm CPUParticles2D:
   - Click chuột phải vào `HitEffect` → **Add Child Node**
   - Tìm **CPUParticles2D** → Create
   
6. Cấu hình CPUParticles2D:
   - **Emitting**: ❌ Uncheck (script sẽ bật)
   - **Amount**: 20
   - **Lifetime**: 0.5
   - **One Shot**: ✅ Check
   - **Explosiveness**: 1.0
   - **Direction**: (0, -1)
   - **Spread**: 45
   - **Initial Velocity**: Min=100, Max=200
   - **Gravity**: (0, 300)
   - **Color**: Đỏ hoặc vàng

7. Save scene: `res://scenes/effects/HitEffect.tscn`

### Bước 4: Tạo EffectManager

1. Quay lại **Prototype_World.tscn**
2. Click chuột phải vào **Prototype_World** (root) → **Add Child Node**
3. Tìm **Node** → Create
4. Đổi tên thành **`EffectManager`**
5. Attach script: `res://scripts/effects/effect_manager.gd`

---

## 🔧 Cấu trúc Prototype_World sau khi setup:

```
Prototype_World (Node2D)
├── TileMapLayer
├── YSortRoot (Node2D)
│   ├── Player
│   └── SlimeBasic
├── MainCamera (Camera2D) [script: smooth_camera.gd] ← NEW!
└── EffectManager (Node) [script: effect_manager.gd] ← NEW!
```

---

## 🎮 Test Effects:

1. Save scene (Ctrl+S)
2. Chạy game (F6)
3. Test:
   - **Camera follow**: Di chuyển → camera theo mượt
   - **Look-ahead**: Di chuyển nhanh → camera nhìn trước
   - **Screen shake**: Attack enemy → màn hình rung
   - **Hit particles**: Hit enemy → particles bay ra
   - **Chrono rift shake**: Ấn Q → màn hình rung mạnh

---

## 🎨 Polish Effects:

### Camera:
- ✅ Smooth follow (lerp)
- ✅ Look-ahead based on velocity
- ✅ Screen shake system

### Hit Feedback:
- ✅ Screen shake khi attack
- ✅ Particle effects khi hit
- ✅ Chrono rift screen shake

### Next: Sound Effects (Optional)
- Attack sound
- Hit sound
- Death sound
- Chrono rift sound

---

## ✅ Checklist:

- [ ] MainCamera đã thêm vào scene
- [ ] Player có group "player"
- [ ] MainCamera có group "camera"
- [ ] HitEffect.tscn đã tạo
- [ ] EffectManager đã thêm vào scene
- [ ] Camera follow hoạt động
- [ ] Screen shake khi attack
- [ ] Hit particles xuất hiện

---

## 🚀 Next: Phase 5 - Map & World

Sau khi effects xong, chúng ta sẽ:
- Import tileset isometric thật
- Vẽ map đẹp
- Thêm decorations

Làm xong Phase 4 báo tôi nhé! ✨

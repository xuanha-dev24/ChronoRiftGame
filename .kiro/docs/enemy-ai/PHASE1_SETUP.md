# Enemy AI Phase 1 - Setup & Testing Instructions

## 📋 Overview

Phase 1 của Enemy AI system đã hoàn thành! Bạn có thể test SlimeBasic enemy với full state machine trong Godot.

**Đã implement:**
- ✅ BaseEnemy abstract class
- ✅ EnemyStateMachine controller
- ✅ 4 States: Idle, Chase, Attack, Dead
- ✅ SlimeBasic enemy type
- ✅ Isometric movement
- ✅ Combat system

---

## 🎮 Setup trong Godot Editor

### Bước 1: Mở Prototype_World scene

1. Mở Godot Editor
2. Trong FileSystem, navigate đến `scenes/world/`
3. Double-click `Prototype_World.tscn` để mở scene

---

### Bước 2: Add SlimeBasic vào scene

1. Trong Scene tree, click vào `YSortRoot` node (hoặc root node của world)
2. Click chuột phải → **Instantiate Child Scene**
3. Navigate đến `scenes/enemies/SlimeBasic.tscn`
4. Click **Open**

---

### Bước 3: Position SlimeBasic

1. Select SlimeBasic node trong Scene tree
2. Trong Inspector, tìm **Transform → Position**
3. Set position cách player một khoảng (ví dụ: X=200, Y=100)
4. Hoặc drag SlimeBasic trong viewport để đặt vị trí

**Gợi ý positions để test:**
- **Test Idle**: Đặt xa player (distance > 150px)
- **Test Chase**: Đặt gần player (distance < 150px)
- **Test Attack**: Đặt rất gần player (distance < 30px)

---

### Bước 4: Enable Debug Mode (Optional)

Để xem aggro/attack ranges và state transitions:

1. Select SlimeBasic node
2. Trong Inspector, scroll xuống **Debug** group
3. Check ✅ **Debug Log**
4. Save scene (Ctrl+S)

**Debug features:**
- Console logs cho state transitions
- Cyan circle = Aggro range (150px)
- Red circle = Attack range (30px)

---

### Bước 5: Run Scene

1. Click **Run Current Scene** (F6)
2. Hoặc click icon ▶️ ở top-right

---

## ✅ Testing Checklist

### Test 1: Idle State
- [ ] SlimeBasic spawns và đứng yên
- [ ] Sprite màu xanh lá (green)
- [ ] HP label hiển thị "30 / 30"
- [ ] Có idle pulse animation (subtle brightness change)

### Test 2: Chase State
- [ ] Di chuyển player lại gần SlimeBasic (< 150px)
- [ ] SlimeBasic transitions từ IDLE → CHASE
- [ ] SlimeBasic chase theo player
- [ ] Movement sử dụng isometric direction (đúng hướng visual)
- [ ] Console log: "Entering CHASE state"

### Test 3: Attack State
- [ ] Đứng yên để SlimeBasic đến gần (< 30px)
- [ ] SlimeBasic transitions từ CHASE → ATTACK
- [ ] SlimeBasic dừng lại (velocity = 0)
- [ ] Sprite flash red khi attack
- [ ] Console log: "Entering ATTACK state"
- [ ] Console log: "Attacking player for 5 damage"

### Test 4: Player Takes Damage
- [ ] Player HP giảm khi bị attack (check console)
- [ ] **NOTE**: Player chưa có HP system, sẽ thấy error "take_damage method not found"
- [ ] Đây là expected behavior, sẽ fix trong Phase 3

### Test 5: Enemy Takes Damage
- [ ] Attack SlimeBasic bằng Space (player attack)
- [ ] SlimeBasic HP giảm (check HP label)
- [ ] Sprite flash red khi bị hit
- [ ] Console log: "Took 10 damage, HP: 20/30"

### Test 6: Death State
- [ ] Tiếp tục attack cho đến khi HP = 0
- [ ] SlimeBasic transitions to DEAD state
- [ ] Sprite fade out (alpha 1.0 → 0.0 over 0.5s)
- [ ] Console log: "slime_basic died — dropped 5 chrono dust"
- [ ] SlimeBasic disappears sau fade animation
- [ ] EventBus signal emitted (check console)

### Test 7: Aggro Loss
- [ ] Spawn SlimeBasic, lại gần để trigger chase
- [ ] Chạy xa khỏi aggro range (> 150px)
- [ ] Đợi 2 giây
- [ ] SlimeBasic transitions từ CHASE → IDLE
- [ ] Console log: "Player out of aggro range for 2.0s. Returning to IDLE"

### Test 8: Debug Visualization (if enabled)
- [ ] Cyan circle hiển thị aggro range
- [ ] Red circle hiển thị attack range
- [ ] Circles follow enemy khi di chuyển

---

## 🐛 Common Issues & Solutions

### Issue 1: SlimeBasic không spawn
**Cause**: Scene chưa được save hoặc script chưa attach  
**Solution**: 
- Check SlimeBasic.tscn có script attached không
- Save scene (Ctrl+S)
- Restart Godot

### Issue 2: SlimeBasic không chase player
**Cause**: Player không có group "player"  
**Solution**:
- Select Player node trong scene
- Trong Inspector → Node → Groups
- Add group "player"

### Issue 3: Console spam errors "Player not found"
**Cause**: Player chưa có group "player"  
**Solution**: Same as Issue 2

### Issue 4: SlimeBasic không attack
**Cause**: Attack range quá nhỏ hoặc player không có take_damage method  
**Solution**:
- Check attack_range trong Inspector (should be 30px)
- Player take_damage sẽ được implement trong Phase 3

### Issue 5: Movement không smooth
**Cause**: Frame rate thấp hoặc speed quá cao  
**Solution**:
- Check FPS trong Godot (should be 60)
- Adjust base_speed trong Inspector (default: 60)

### Issue 6: Sprite không đổi màu khi slowed
**Cause**: Chrono Rift chưa được integrate  
**Solution**: Phase 2 sẽ implement Chrono Rift integration

---

## 🎯 Expected Behavior Summary

**Full Combat Loop:**
1. SlimeBasic spawns in IDLE (green, stationary)
2. Player approaches → IDLE → CHASE (enemy moves toward player)
3. Enemy reaches player → CHASE → ATTACK (stops, flash red, deal damage)
4. Attack completes → ATTACK → CHASE (if player still in range)
5. Player defeats enemy → Any State → DEAD (fade out, emit signal, remove)

**State Transitions:**
```
IDLE → CHASE (player in aggro range)
CHASE → ATTACK (player in attack range)
ATTACK → CHASE (attack complete, player in aggro range)
ATTACK → IDLE (attack complete, player out of range)
CHASE → IDLE (player out of aggro range for 2s)
Any State → DEAD (HP <= 0)
```

---

## 📝 Testing Notes

**Ghi chú khi test:**
- Velocity có smooth không?
- State transitions có đúng timing không?
- Visual feedback (colors, flash) có rõ ràng không?
- Console logs có hữu ích không?
- Performance có ổn không? (FPS stable?)

**Known Limitations (sẽ fix trong phases sau):**
- Player chưa có HP system (Phase 3)
- Player chưa có i-frames (Phase 3)
- Chrono Rift chưa affect enemies (Phase 2)
- Chỉ có 1 enemy type (Phase 4 sẽ add EarthGolem)
- Không có PatrolState (Phase 6)

---

## ✅ Checkpoint Complete Criteria

Phase 1 được coi là hoàn thành khi:
- [ ] SlimeBasic spawns successfully
- [ ] All 4 states work correctly (Idle, Chase, Attack, Dead)
- [ ] State transitions occur at correct ranges
- [ ] Enemy takes damage and dies
- [ ] Visual feedback works (colors, flash, fade)
- [ ] EventBus signal emitted on death
- [ ] No critical errors in console
- [ ] Performance is acceptable (60 FPS)

---

## 🚀 Next Steps

Sau khi Phase 1 checkpoint pass:

**Phase 2: Chrono Rift Integration**
- Integrate với existing ChronoRiftSystem
- Enemies slow down trong rift area
- Sprite turns magenta when slowed
- State machine continues while slowed

**Phase 3: Player Combat Response**
- Player HP system
- I-frames (invincibility frames)
- Player death
- HUD HP display

**Phase 4: EarthGolem Variant**
- Second enemy type
- Different stats (tanky, slow, high damage)
- Test multiple enemy types together

---

## 📞 Need Help?

Nếu gặp vấn đề:
1. Check console logs (Output tab trong Godot)
2. Enable debug_log để xem state transitions
3. Verify player có group "player"
4. Check collision layers (Enemy: Layer 2, Player: Layer 1)
5. Restart Godot nếu cần

---

**Status**: Phase 1 Implementation Complete ✅  
**Next**: Test trong Godot và report results  
**Goal**: Validate combat loop works before moving to Phase 2

# Enemy AI Phase 2 - Chrono Rift Integration Testing

## 📋 Overview

Phase 2 integrates Enemy AI với existing Chrono Rift system. Enemies giờ sẽ bị slow down khi player activate rift!

**Đã implement:**
- ✅ Slow effect methods (apply_slow, remove_slow)
- ✅ Integration với ChronoRiftSystem
- ✅ Visual feedback (magenta color when slowed)
- ✅ State machine continues while slowed
- ✅ Speed restoration when rift expires

---

## 🎮 Testing Instructions

### Setup

1. Mở Godot Editor
2. Mở `Prototype_World.tscn`
3. Ensure có ít nhất 2-3 SlimeBasic enemies trong scene
4. Ensure Player có ChronoRiftSystem attached (should already have from POC)

---

## ✅ Testing Checklist

### Test 1: Basic Slow Effect
- [ ] Spawn 2-3 SlimeBasic enemies
- [ ] Let enemies chase player
- [ ] Press **Q** to activate Chrono Rift
- [ ] **Expected**: Cyan circle appears around player
- [ ] **Expected**: Enemies within 80px radius slow down
- [ ] **Expected**: Slowed enemies turn **magenta/pink**
- [ ] **Expected**: Console log: "Enemies slowed: X"

### Test 2: Speed Reduction
- [ ] Activate rift near chasing enemy
- [ ] Observe enemy movement speed
- [ ] **Expected**: Enemy moves at 20% of normal speed (60 → 12 px/s)
- [ ] **Expected**: Enemy still chases player (doesn't stop)
- [ ] **Expected**: Movement direction still correct (isometric)

### Test 3: Visual Feedback
- [ ] Activate rift
- [ ] Check slowed enemy sprite color
- [ ] **Expected**: Sprite changes from green → magenta
- [ ] **Expected**: Color change is immediate
- [ ] **Expected**: HP label still visible

### Test 4: State Machine Continues
- [ ] Activate rift while enemy in CHASE state
- [ ] Let enemy reach attack range
- [ ] **Expected**: Enemy transitions CHASE → ATTACK normally
- [ ] **Expected**: Attack executes (sprite flash red)
- [ ] **Expected**: Enemy still slowed during attack
- [ ] **Expected**: State transitions not affected by slow

### Test 5: Slow Duration
- [ ] Activate rift
- [ ] Wait and observe
- [ ] **Expected**: Slow lasts 3 seconds
- [ ] **Expected**: After 3s, enemies return to normal speed
- [ ] **Expected**: Sprite color changes magenta → green
- [ ] **Expected**: Console log: "Slow removed: speed restored to 60"

### Test 6: Multiple Enemies
- [ ] Spawn 3+ enemies at different distances
- [ ] Activate rift
- [ ] **Expected**: Only enemies within 80px radius are slowed
- [ ] **Expected**: Enemies outside radius not affected
- [ ] **Expected**: Each slowed enemy turns magenta
- [ ] **Expected**: Console shows correct count

### Test 7: Rift Cooldown
- [ ] Activate rift (Press Q)
- [ ] Try to activate again immediately
- [ ] **Expected**: Nothing happens (cooldown active)
- [ ] Wait 5 seconds
- [ ] **Expected**: Console log: "Chrono Rift ready"
- [ ] Press Q again
- [ ] **Expected**: Rift activates successfully

### Test 8: Slow During Combat
- [ ] Let enemy attack player
- [ ] Activate rift during attack animation
- [ ] **Expected**: Enemy slows down
- [ ] **Expected**: Attack completes normally
- [ ] **Expected**: Enemy returns to CHASE (slowed)

### Test 9: Enemy Death While Slowed
- [ ] Activate rift to slow enemy
- [ ] Attack and kill slowed enemy
- [ ] **Expected**: Enemy dies normally (fade out)
- [ ] **Expected**: Loot signal emitted
- [ ] **Expected**: No errors in console

### Test 10: Slow Removal on Rift Expire
- [ ] Activate rift
- [ ] Observe slowed enemies
- [ ] Wait for rift to expire (3s)
- [ ] **Expected**: Cyan circle disappears
- [ ] **Expected**: All slowed enemies return to normal speed
- [ ] **Expected**: All sprites change magenta → green
- [ ] **Expected**: Console logs for each enemy

---

## 🐛 Common Issues & Solutions

### Issue 1: Enemies không slow down
**Cause**: Enemies không trong "enemies" group  
**Solution**:
- Select SlimeBasic node
- Check Node → Groups
- Ensure "enemies" group exists (BaseEnemy adds this automatically)

### Issue 2: Sprite không đổi màu
**Cause**: Sprite node không tồn tại hoặc tên sai  
**Solution**:
- Check SlimeBasic.tscn có node tên "Sprite"
- Verify node type là ColorRect
- Check BaseEnemy.apply_slow() có set sprite.color

### Issue 3: Slow không remove sau 3s
**Cause**: Timer issue hoặc enemies bị destroyed  
**Solution**:
- Check console logs
- Verify ChronoRiftSystem._remove_slow() được call
- Check is_instance_valid() trong _remove_slow()

### Issue 4: Console spam "Already slowed"
**Cause**: Multiple rift activations overlap  
**Solution**: This is expected behavior, slow factor updates

### Issue 5: Enemies stop moving when slowed
**Cause**: current_speed = 0 hoặc state machine issue  
**Solution**:
- Check current_speed value (should be base_speed * 0.2)
- Verify ChaseState uses enemy.current_speed
- Check console logs for state transitions

---

## 🎯 Expected Behavior

**Slow Effect Sequence:**
1. Player presses Q
2. Cyan circle appears (80px radius)
3. Enemies within radius:
   - `is_slowed = true`
   - `current_speed = base_speed * 0.2` (60 → 12)
   - Sprite color → magenta
4. Enemies continue state machine logic (chase, attack, etc.)
5. After 3 seconds:
   - `is_slowed = false`
   - `current_speed = base_speed` (12 → 60)
   - Sprite color → green
6. Rift cooldown: 5 seconds

**Visual Indicators:**
- **Cyan circle**: Rift active area
- **Magenta sprite**: Enemy is slowed
- **Green sprite**: Enemy normal speed
- **Console logs**: State changes, slow applied/removed

---

## 📊 Performance Check

**With 5 enemies + Chrono Rift:**
- [ ] FPS stable at 60
- [ ] No frame drops when activating rift
- [ ] Smooth slow/restore transitions
- [ ] No memory leaks (enemies properly removed from slowed_enemies array)

---

## ✅ Phase 2 Complete Criteria

Phase 2 được coi là hoàn thành khi:
- [ ] Enemies slow down when rift activated
- [ ] Sprite color changes to magenta when slowed
- [ ] Speed reduces to 20% (60 → 12 px/s)
- [ ] State machine continues normally while slowed
- [ ] Slow effect removes after 3 seconds
- [ ] Sprite color restores to green
- [ ] Speed restores to 100%
- [ ] Multiple enemies can be slowed simultaneously
- [ ] Rift cooldown works (5 seconds)
- [ ] No errors in console
- [ ] Performance acceptable (60 FPS)

---

## 🚀 Next Steps

Sau khi Phase 2 checkpoint pass:

**Phase 3: Player Combat Response**
- Player HP system
- take_damage() method
- I-frames (invincibility frames)
- Player death
- HUD HP display

**Why Phase 3 is important:**
- Currently player can't take damage (method missing)
- Enemy attacks don't affect player
- No win/lose condition
- Combat loop incomplete

---

## 📝 Debug Tips

**Enable debug logging:**
```gdscript
# In SlimeBasic Inspector
debug_log = true
```

**Console logs to watch for:**
- "CHRONO RIFT — SLOW activated"
- "Enemies slowed: X"
- "[slime_basic] Slowed: speed 60.0 -> 12.0"
- "[slime_basic] Slow removed: speed restored to 60.0"
- State transitions continue normally

**Visual debugging:**
- Cyan circle = Rift area (80px radius)
- Magenta enemy = Slowed
- Green enemy = Normal speed
- Red flash = Taking damage (not affected by slow)

---

**Status**: Phase 2 Implementation Complete ✅  
**Next**: Test Chrono Rift integration và report results  
**Goal**: Validate slow effects work before moving to Phase 3

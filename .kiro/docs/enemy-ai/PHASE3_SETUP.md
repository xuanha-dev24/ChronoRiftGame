# Enemy AI Phase 3 - Player Combat Response Testing

## 📋 Overview

Phase 3 implements player HP system, damage handling, invincibility frames, và death. Bây giờ combat loop đã hoàn chỉnh!

**Đã implement:**
- ✅ Player HP system (100 HP)
- ✅ take_damage() method
- ✅ I-frames (0.5s invincibility after hit)
- ✅ Visual feedback (red flash, flashing during i-frames)
- ✅ Player death (fade out, disable input)
- ✅ HUD HP display với color coding
- ✅ EventBus signals (player_damaged, player_died)

---

## 🎮 Setup Requirements

### Bước 1: Add HUD to Scene

1. Mở `Prototype_World.tscn`
2. Check xem đã có HUD node chưa
3. Nếu chưa có:
   - Click chuột phải vào root → Add Child Node
   - Chọn **CanvasLayer**
   - Rename thành "HUD"
   - Attach script: `res://scripts/ui/hud.gd`

### Bước 2: Add HP Label to HUD

1. Select HUD node
2. Click chuột phải → Add Child Node
3. Chọn **Label**
4. Rename thành "HPLabel"
5. Trong Inspector:
   - Text: "HP: 100 / 100"
   - Position: X=10, Y=10 (top-left corner)
   - Font Size: 20 (hoặc lớn hơn để dễ đọc)

### Bước 3: Verify Player Setup

1. Select Player node
2. Trong Inspector, verify:
   - Script: `player_controller_prototype.gd`
   - Max HP: 100
   - Has Sprite node (ColorRect)
3. Trong Node → Groups:
   - Ensure "player" group exists

---

## ✅ Testing Checklist

### Test 1: Player Takes Damage
- [ ] Spawn SlimeBasic enemy
- [ ] Let enemy chase and attack player
- [ ] **Expected**: Player sprite flashes red
- [ ] **Expected**: Console log: "[Player] Took 5 damage | HP: 95/100"
- [ ] **Expected**: HUD updates: "HP: 95 / 100"
- [ ] **Expected**: HP label color stays white (HP > 60%)

### Test 2: Invincibility Frames (I-frames)
- [ ] Let enemy attack player
- [ ] Observe player sprite after hit
- [ ] **Expected**: Player sprite flashes (alpha 0.5 ↔ 1.0)
- [ ] **Expected**: Flashing lasts 0.5 seconds
- [ ] **Expected**: Enemy attacks during i-frames don't deal damage
- [ ] **Expected**: Console log: "[Player] I-frames ended" after 0.5s

### Test 3: Multiple Hits with I-frames
- [ ] Let enemy attack player
- [ ] Enemy attacks again immediately
- [ ] **Expected**: Second attack blocked by i-frames
- [ ] **Expected**: Only first hit deals damage
- [ ] Wait 0.5s, let enemy attack again
- [ ] **Expected**: Third attack deals damage (i-frames expired)

### Test 4: HP Color Coding
- [ ] Take damage until HP < 60%
- [ ] **Expected**: HP label turns **yellow**
- [ ] Take more damage until HP < 30%
- [ ] **Expected**: HP label turns **red**
- [ ] **Expected**: Color changes are immediate

### Test 5: Player Death
- [ ] Let enemies attack until HP reaches 0
- [ ] **Expected**: Console log: "[Player] DIED"
- [ ] **Expected**: Player sprite fades out (1 second)
- [ ] **Expected**: Player stops moving (physics disabled)
- [ ] **Expected**: Console log: "=== GAME OVER ==="
- [ ] **Expected**: EventBus.player_died signal emitted

### Test 6: Death Prevents Further Damage
- [ ] After player dies, check if enemies still attack
- [ ] **Expected**: Attacks don't deal damage (is_dead flag)
- [ ] **Expected**: No console logs for damage
- [ ] **Expected**: HP stays at 0

### Test 7: Full Combat Loop
- [ ] Start fresh scene
- [ ] Spawn 2-3 SlimeBasic enemies
- [ ] Let them chase and attack
- [ ] **Expected**: HP decreases gradually
- [ ] **Expected**: I-frames prevent damage stacking
- [ ] **Expected**: HUD updates in real-time
- [ ] **Expected**: Player dies when HP = 0
- [ ] **Expected**: Smooth fade out animation

### Test 8: Combat with Chrono Rift
- [ ] Spawn enemies, let them chase
- [ ] Activate Chrono Rift (Q) to slow enemies
- [ ] Let slowed enemies attack
- [ ] **Expected**: Attacks still deal damage
- [ ] **Expected**: I-frames still work
- [ ] **Expected**: Slower attack rate due to enemy slow

---

## 🐛 Common Issues & Solutions

### Issue 1: Player không take damage
**Cause**: Player không có group "player" hoặc sprite node missing  
**Solution**:
- Add player to "player" group
- Verify Sprite node exists và tên đúng
- Check console for errors

### Issue 2: HUD không update
**Cause**: HPLabel node không tồn tại hoặc tên sai  
**Solution**:
- Check HUD scene có node "HPLabel"
- Verify EventBus.player_damaged signal connected
- Check console logs

### Issue 3: I-frames không work
**Cause**: is_invincible flag không được set  
**Solution**:
- Check _start_iframes() được call
- Verify await timer works
- Check console log: "I-frames ended"

### Issue 4: Player không die
**Cause**: HP không giảm xuống 0 hoặc _die() không được call  
**Solution**:
- Check take_damage() logic
- Verify current_hp <= 0 check
- Check console logs

### Issue 5: Sprite không flash
**Cause**: Sprite node reference null  
**Solution**:
- Verify @onready var sprite: ColorRect = $Sprite
- Check Sprite node exists trong Player scene
- Check node name chính xác

---

## 🎯 Expected Behavior

**Damage Sequence:**
1. Enemy attacks player
2. Player sprite flashes red (0.1s)
3. HP decreases by enemy damage amount
4. HUD updates immediately
5. EventBus.player_damaged emitted
6. I-frames start (0.5s)
7. Player sprite flashes (alpha oscillation)
8. Further attacks blocked during i-frames
9. I-frames end, player vulnerable again

**Death Sequence:**
1. HP reaches 0
2. is_dead flag set to true
3. EventBus.player_died emitted
4. Physics disabled (no movement)
5. Sprite fades out (1 second)
6. "GAME OVER" message in console
7. Player remains in scene (invisible)

**HP Display:**
- **White**: HP > 60%
- **Yellow**: 30% < HP ≤ 60%
- **Red**: HP ≤ 30%

---

## 📊 Combat Balance Check

**With SlimeBasic (5 damage, 1.5s cooldown):**
- Player HP: 100
- Hits to kill player: 20 hits
- Time to kill (no i-frames): 30 seconds
- Time to kill (with i-frames): ~40 seconds

**With multiple enemies:**
- 2 enemies: ~20 seconds to death
- 3 enemies: ~15 seconds to death
- Player needs to kite or use Chrono Rift!

---

## ✅ Phase 3 Complete Criteria

Phase 3 được coi là hoàn thành khi:
- [ ] Player takes damage from enemy attacks
- [ ] HP decreases correctly
- [ ] HUD displays HP and updates in real-time
- [ ] HP label color codes correctly (white/yellow/red)
- [ ] I-frames work (0.5s invincibility after hit)
- [ ] Visual feedback works (red flash, flashing during i-frames)
- [ ] Player dies when HP = 0
- [ ] Death animation plays (fade out)
- [ ] Physics disabled on death
- [ ] EventBus signals emitted correctly
- [ ] No errors in console
- [ ] Combat feels fair and balanced

---

## 🚀 Next Steps

Sau khi Phase 3 checkpoint pass:

**Phase 4: EarthGolem Variant**
- Add second enemy type
- Tanky melee (120 HP, 40 speed, 15 damage)
- Test multiple enemy types together
- Verify variety in combat

**Phase 5: FireImp Ranged (DEFER)**
- Ranged enemy with projectiles
- Kiting behavior
- Most complex enemy type

**Phase 6: PatrolState (SHOULD)**
- Enemies wander when idle
- More dynamic world
- Better AI behavior

---

## 📝 Testing Notes

**Ghi chú khi test:**
- I-frames có đủ dài không? (0.5s)
- Visual feedback có rõ ràng không?
- HP color coding có hữu ích không?
- Death animation có smooth không?
- Combat có cảm giác fair không?

**Known Limitations:**
- Chưa có respawn system
- Chưa có death screen UI
- Chưa có restart button
- Chưa có healing items
- Chưa có HP bar (chỉ có label)

---

## 💡 Improvement Ideas (Post-MVP)

**Visual:**
- HP bar thay vì label
- Damage numbers floating up
- Better death animation
- Screen shake when hit

**Gameplay:**
- Healing items
- Max HP upgrades
- Armor/defense system
- Dodge roll with i-frames

**UI:**
- Death screen with restart button
- Damage indicator (red vignette)
- Low HP warning (pulsing red)

---

**Status**: Phase 3 Implementation Complete ✅  
**Next**: Test player combat và report results  
**Goal**: Validate full combat loop before adding more enemy types

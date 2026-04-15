# Enemy AI Phase 4 - EarthGolem Variant Testing

## 📋 Overview

Phase 4 adds EarthGolem - second enemy type với different stats và behavior. Bây giờ có enemy variety!

**Đã implement:**
- ✅ EarthGolem class (extends BaseEnemy)
- ✅ Tanky stats (120 HP, 40 speed, 15 damage)
- ✅ Larger sprite (36x36 vs 24x24)
- ✅ Brown color
- ✅ Same state machine as SlimeBasic
- ✅ Different combat feel (slow but dangerous)

---

## 🎮 Setup Instructions

### Bước 1: Add EarthGolem to Scene

1. Mở `Prototype_World.tscn`
2. Click chuột phải vào YSortRoot
3. **Instantiate Child Scene**
4. Navigate đến `scenes/enemies/EarthGolem.tscn`
5. Click **Open**
6. Position EarthGolem cách player ~250px

### Bước 2: Add Multiple Enemies

Để test variety, add cả 2 types:
- 2-3 SlimeBasic (green, fast, weak)
- 1-2 EarthGolem (brown, slow, tanky)

Position chúng ở different locations để test combat dynamics.

---

## ✅ Testing Checklist

### Test 1: EarthGolem Spawns
- [ ] EarthGolem spawns successfully
- [ ] Sprite màu **brown** (not green)
- [ ] Sprite **larger** than SlimeBasic (36x36 vs 24x24)
- [ ] HP label shows "120 / 120"
- [ ] Starts in IDLE state

### Test 2: Movement Speed Difference
- [ ] Spawn both SlimeBasic và EarthGolem
- [ ] Let both chase player
- [ ] **Expected**: SlimeBasic moves faster (60 px/s)
- [ ] **Expected**: EarthGolem moves slower (40 px/s)
- [ ] **Expected**: Visual difference is noticeable

### Test 3: HP Difference
- [ ] Attack SlimeBasic (30 HP)
- [ ] Count hits to kill: ~3 hits
- [ ] Attack EarthGolem (120 HP)
- [ ] Count hits to kill: ~12 hits
- [ ] **Expected**: EarthGolem much tankier

### Test 4: Damage Difference
- [ ] Let SlimeBasic attack player
- [ ] Check damage: 5 HP per hit
- [ ] Let EarthGolem attack player
- [ ] Check damage: 15 HP per hit
- [ ] **Expected**: EarthGolem hits 3x harder!

### Test 5: Visual Distinction
- [ ] Spawn both enemy types
- [ ] **Expected**: Easy to tell apart by:
  - Color (green vs brown)
  - Size (small vs large)
  - Speed (fast vs slow)

### Test 6: Chrono Rift on Both Types
- [ ] Spawn both enemy types
- [ ] Activate Chrono Rift (Q)
- [ ] **Expected**: Both turn magenta when slowed
- [ ] **Expected**: SlimeBasic: 60 → 12 px/s
- [ ] **Expected**: EarthGolem: 40 → 8 px/s
- [ ] After 3s, both restore original colors

### Test 7: Combat Against Multiple Types
- [ ] Spawn 2 SlimeBasic + 1 EarthGolem
- [ ] Let them chase player
- [ ] **Expected**: SlimeBasic reach player first (faster)
- [ ] **Expected**: EarthGolem arrives later (slower)
- [ ] **Expected**: Different threat levels
- [ ] **Expected**: Player must prioritize targets

### Test 8: Death Animations
- [ ] Kill SlimeBasic
- [ ] **Expected**: Fade out, "dropped 5 chrono dust"
- [ ] Kill EarthGolem
- [ ] **Expected**: Fade out, "dropped 15 chrono dust"
- [ ] **Expected**: Both use same death animation

### Test 9: State Machine Consistency
- [ ] Test both enemy types through all states
- [ ] **Expected**: IDLE → CHASE → ATTACK → DEAD
- [ ] **Expected**: Same state logic, different stats
- [ ] **Expected**: No errors in console

### Test 10: Performance with Multiple Enemies
- [ ] Spawn 3 SlimeBasic + 2 EarthGolem (5 total)
- [ ] Let them all chase player
- [ ] **Expected**: 60 FPS maintained
- [ ] **Expected**: Smooth movement for all
- [ ] **Expected**: No lag or stuttering

---

## 🎯 Enemy Comparison Table

| Stat | SlimeBasic | EarthGolem | Difference |
|------|------------|------------|------------|
| **HP** | 30 | 120 | 4x tankier |
| **Speed** | 60 px/s | 40 px/s | 1.5x slower |
| **Damage** | 5 | 15 | 3x stronger |
| **Aggro Range** | 150 px | 180 px | Slightly larger |
| **Attack Range** | 30 px | 40 px | Slightly larger |
| **Attack Cooldown** | 1.5s | 2.5s | Slower attacks |
| **Chrono Dust** | 5 | 15 | 3x reward |
| **Color** | Green | Brown | Visual distinction |
| **Size** | 24x24 | 36x36 | 1.5x larger |
| **Threat Level** | Low | High | Boss-like |

---

## 💡 Combat Strategy Tips

**Against SlimeBasic:**
- Fast but weak
- Easy to kite
- Kill quickly before they swarm
- Low threat individually

**Against EarthGolem:**
- Slow but tanky
- Hits very hard (15 damage!)
- Takes many hits to kill
- High priority target
- Use Chrono Rift to slow them down

**Mixed Groups:**
- Kill SlimeBasic first (fast threats)
- Kite EarthGolem while dealing with Slimes
- Use Chrono Rift when surrounded
- Manage HP carefully (EarthGolem 2-shots you at low HP!)

---

## 🐛 Common Issues & Solutions

### Issue 1: EarthGolem sprite màu green
**Cause**: Color not set correctly  
**Solution**: Check earth_golem.gd _ready() sets brown color

### Issue 2: EarthGolem same size as SlimeBasic
**Cause**: Scene file sprite size wrong  
**Solution**: Check EarthGolem.tscn sprite offset (-18 to 18, -24 to 12)

### Issue 3: EarthGolem too fast/slow
**Cause**: base_speed not set correctly  
**Solution**: Verify base_speed = 40.0 in _init()

### Issue 4: Both enemies behave identically
**Cause**: Stats not overridden  
**Solution**: Check _init() in earth_golem.gd

### Issue 5: EarthGolem doesn't restore brown after slow
**Cause**: remove_slow() not overridden  
**Solution**: Verify remove_slow() in earth_golem.gd

---

## 📊 Expected Combat Feel

**SlimeBasic:**
- "Swarm" enemy
- Fast, numerous, weak
- Easy to kill individually
- Dangerous in groups
- Low risk, low reward

**EarthGolem:**
- "Tank" enemy
- Slow, rare, strong
- Hard to kill
- Very dangerous
- High risk, high reward

**Together:**
- Dynamic combat
- Target prioritization matters
- Positioning important
- Chrono Rift becomes strategic tool

---

## ✅ Phase 4 Complete Criteria

Phase 4 được coi là hoàn thành khi:
- [ ] EarthGolem spawns successfully
- [ ] Visual distinction clear (color, size)
- [ ] Stat differences noticeable (HP, speed, damage)
- [ ] Both enemy types work with same state machine
- [ ] Chrono Rift affects both types
- [ ] Combat feels different against each type
- [ ] Multiple enemies can coexist
- [ ] Performance acceptable (60 FPS with 5+ enemies)
- [ ] No errors in console
- [ ] Loot drops correctly for both types

---

## 🚀 Next Steps

Sau khi Phase 4 checkpoint pass:

**Phase 5: FireImp Ranged (DEFER)**
- Most complex enemy type
- Ranged attacks with projectiles
- Kiting behavior
- Different combat pattern

**Phase 6: PatrolState (SHOULD)**
- Enemies wander when idle
- More dynamic world
- Better AI behavior
- Recommended before Phase 5

**Phase 7: Polish & Debug**
- Debug visualization
- Aggro loss timeout
- Final integration tests
- Performance optimization

---

## 📝 Testing Notes

**Ghi chú khi test:**
- Enemy variety có thú vị không?
- Combat có dynamic hơn không?
- Target prioritization có matter không?
- Visual distinction có đủ rõ không?
- Performance có OK với nhiều enemies không?

**Balance feedback:**
- EarthGolem có quá mạnh không?
- SlimeBasic có quá yếu không?
- Loot rewards có fair không?
- Combat có fun không?

---

## 🎮 Recommended Test Scenario

**"Survival Challenge":**
1. Spawn 3 SlimeBasic + 2 EarthGolem
2. Position chúng ở different sides
3. Try to survive và kill all
4. Use Chrono Rift strategically
5. Manage HP carefully
6. See how long you last!

**Expected difficulty:** Hard but fair  
**Expected time:** 1-2 minutes  
**Expected deaths:** 2-3 attempts to win

---

**Status**: Phase 4 Implementation Complete ✅  
**Next**: Test enemy variety và report results  
**Goal**: Validate multiple enemy types work together before adding more complexity

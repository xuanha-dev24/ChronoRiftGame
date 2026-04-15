# Enemy AI Phase 6 - PatrolState Testing

## 📋 Overview

Phase 6 adds PatrolState - enemies giờ sẽ wander around khi không có player! World cảm giác dynamic và alive hơn.

**Đã implement:**
- ✅ PatrolState với waypoint logic
- ✅ Random waypoint selection trong patrol radius
- ✅ Isometric movement toward waypoint
- ✅ Idle → Patrol → Idle cycle
- ✅ Chase → Patrol when player escapes
- ✅ Integration với SlimeBasic và EarthGolem

---

## 🎮 Testing Instructions

### Setup

1. Mở Godot Editor
2. Mở `Prototype_World.tscn`
3. Spawn 2-3 enemies (SlimeBasic và/hoặc EarthGolem)
4. Position chúng xa player (> aggro range)
5. **Enable debug_log** để see state transitions:
   - Select enemy → Inspector → Debug → Check "Debug Log"

---

## ✅ Testing Checklist

### Test 1: Idle to Patrol Transition
- [ ] Spawn enemy xa player
- [ ] Enemy starts in IDLE (đứng yên, pulse animation)
- [ ] Wait 3-5 seconds
- [ ] **Expected**: Console log: "Idle timeout, transitioning to PATROL"
- [ ] **Expected**: Enemy starts moving
- [ ] **Expected**: Console log: "New waypoint selected at..."

### Test 2: Patrol Movement
- [ ] Enemy in PATROL state
- [ ] Observe movement
- [ ] **Expected**: Enemy moves toward waypoint
- [ ] **Expected**: Movement uses isometric direction (correct visual)
- [ ] **Expected**: Console log: "Moving to waypoint | Distance: X"
- [ ] **Expected**: Distance decreases over time

### Test 3: Waypoint Reached
- [ ] Enemy moving toward waypoint
- [ ] Wait for enemy to reach waypoint
- [ ] **Expected**: Console log: "Waypoint reached, returning to IDLE"
- [ ] **Expected**: Enemy stops moving
- [ ] **Expected**: Enemy enters IDLE state
- [ ] After 3-5s, enemy starts patrolling again

### Test 4: Patrol Radius Constraint
- [ ] Enable debug_log
- [ ] Observe multiple patrol cycles
- [ ] Note spawn position và waypoint positions
- [ ] **Expected**: All waypoints within patrol_radius of spawn
- [ ] **Expected**: SlimeBasic: 80px radius
- [ ] **Expected**: EarthGolem: 60px radius
- [ ] **Expected**: Enemy never wanders too far from spawn

### Test 5: Player Interrupts Patrol
- [ ] Enemy in PATROL state
- [ ] Move player into aggro range
- [ ] **Expected**: Console log: "Player detected in aggro range!"
- [ ] **Expected**: Enemy transitions PATROL → CHASE
- [ ] **Expected**: Enemy chases player
- [ ] **Expected**: Patrol interrupted immediately

### Test 6: Return to Patrol After Chase
- [ ] Enemy chasing player
- [ ] Run away (exit aggro range)
- [ ] Wait 2 seconds
- [ ] **Expected**: Console log: "Player out of aggro range, returning to PATROL"
- [ ] **Expected**: Enemy transitions CHASE → PATROL
- [ ] **Expected**: Enemy selects new waypoint
- [ ] **Expected**: Enemy resumes patrolling

### Test 7: Patrol While Slowed
- [ ] Enemy in PATROL state
- [ ] Activate Chrono Rift (Q)
- [ ] **Expected**: Enemy turns magenta
- [ ] **Expected**: Movement speed reduces (60 → 12 px/s)
- [ ] **Expected**: Enemy continues moving toward waypoint
- [ ] **Expected**: State remains PATROL
- [ ] After 3s, enemy returns to normal speed

### Test 8: Multiple Enemies Patrolling
- [ ] Spawn 3+ enemies at different positions
- [ ] Let them all patrol
- [ ] **Expected**: Each enemy has own waypoint
- [ ] **Expected**: Enemies don't follow each other
- [ ] **Expected**: Independent patrol patterns
- [ ] **Expected**: No collisions or overlap issues

### Test 9: Patrol Cycle Timing
- [ ] Spawn enemy
- [ ] Measure time for full cycle:
   - IDLE (3-5s) → PATROL (varies) → IDLE (3-5s)
- [ ] **Expected**: Idle duration randomized (3-5s)
- [ ] **Expected**: Patrol duration depends on waypoint distance
- [ ] **Expected**: Cycle repeats indefinitely
- [ ] **Expected**: No stuck states

### Test 10: Visual Distinction
- [ ] Observe enemy in different states
- [ ] **Expected**: IDLE - Stationary, pulse animation
- [ ] **Expected**: PATROL - Moving, same color as idle
- [ ] **Expected**: CHASE - Moving faster, chasing player
- [ ] **Expected**: ATTACK - Stationary, flash red
- [ ] **Expected**: Clear visual difference between states

---

## 🎯 Expected Behavior

**Full State Cycle:**
```
IDLE (3-5s random)
  ↓
PATROL (move to waypoint)
  ↓
IDLE (waypoint reached, 3-5s)
  ↓
PATROL (new waypoint)
  ↓
... (repeats)
```

**With Player Interaction:**
```
IDLE/PATROL
  ↓ (player enters aggro range)
CHASE
  ↓ (player in attack range)
ATTACK
  ↓ (player escapes)
PATROL (not IDLE!)
  ↓ (waypoint reached)
IDLE
```

---

## 🐛 Common Issues & Solutions

### Issue 1: Enemy không patrol
**Cause**: PatrolState không được initialized  
**Solution**:
- Check slime_basic.gd hoặc earth_golem.gd
- Verify `var patrol = PatrolState.new(self, state_machine)`
- Check console for errors

### Issue 2: Enemy wanders too far
**Cause**: Waypoint selection không respect patrol_radius  
**Solution**:
- Check patrol_state.gd `_select_new_waypoint()`
- Verify `distance = randf() * enemy.patrol_radius`
- Enable debug_log để see waypoint distances

### Issue 3: Enemy stuck in PATROL
**Cause**: Waypoint threshold quá nhỏ  
**Solution**:
- Check `WAYPOINT_THRESHOLD = 10.0` in patrol_state.gd
- Increase if enemy never reaches waypoint
- Check console logs for distance values

### Issue 4: Idle timeout không work
**Cause**: idle_duration không được set  
**Solution**:
- Check idle_state.gd `enter()` method
- Verify `idle_duration = randf_range(3.0, 5.0)`
- Check console log: "Idle timeout"

### Issue 5: Enemy returns to IDLE instead of PATROL
**Cause**: ChaseState không updated  
**Solution**:
- Check chase_state.gd out of range logic
- Verify `transition_to(state_machine.patrol_state)`
- Should prefer PATROL over IDLE

---

## 📊 Patrol Behavior Comparison

| Enemy | Patrol Radius | Speed | Idle Duration | Behavior |
|-------|---------------|-------|---------------|----------|
| **SlimeBasic** | 80 px | 60 px/s | 3-5s | Active, frequent patrols |
| **EarthGolem** | 60 px | 40 px/s | 3-5s | Slower, smaller area |

**Visual Difference:**
- SlimeBasic: Covers more ground, faster patrols
- EarthGolem: Stays closer to spawn, slower movement

---

## 💡 Gameplay Impact

**Before PatrolState:**
- Enemies just stood still
- World felt static
- Easy to avoid enemies

**After PatrolState:**
- Enemies wander naturally
- World feels alive
- Harder to predict enemy positions
- More dynamic encounters

**Strategic Implications:**
- Can't rely on enemies staying in one spot
- Need to check surroundings more often
- Patrol patterns create opportunities
- Enemies might wander into/out of danger zones

---

## ✅ Phase 6 Complete Criteria

Phase 6 được coi là hoàn thành khi:
- [ ] Enemies transition IDLE → PATROL after 3-5s
- [ ] Waypoints selected within patrol_radius
- [ ] Enemies move toward waypoints correctly
- [ ] Enemies return to IDLE when waypoint reached
- [ ] Patrol cycle repeats indefinitely
- [ ] Player can interrupt patrol (PATROL → CHASE)
- [ ] Enemies return to PATROL after chase (not IDLE)
- [ ] Patrol works while slowed (Chrono Rift)
- [ ] Multiple enemies patrol independently
- [ ] No errors in console
- [ ] Performance acceptable (60 FPS)

---

## 🎮 Recommended Test Scenario

**"Living World Test":**
1. Spawn 5 enemies (3 Slime, 2 Golem)
2. Position them at different locations
3. Stand still và observe for 2 minutes
4. **Expected**:
   - Enemies patrol independently
   - Different patrol patterns
   - Some wander close, some far
   - World feels dynamic
   - No stuck enemies

**Then:**
5. Walk around the map
6. Trigger some enemies (enter aggro range)
7. Escape and observe
8. **Expected**:
   - Chased enemies return to patrol
   - Other enemies continue patrolling
   - Dynamic threat levels
   - Unpredictable encounters

---

## 📝 Testing Notes

**Ghi chú khi test:**
- Patrol có natural không?
- Enemies có stuck không?
- Waypoints có reasonable không?
- World có cảm giác alive không?
- Performance có OK với nhiều enemies patrol không?

**Balance feedback:**
- Idle duration có OK không? (3-5s)
- Patrol radius có hợp lý không?
- Movement speed có phù hợp không?
- Patrol có annoying không?

---

## 🚀 What's Next?

**Enemy AI System giờ có:**
- ✅ 5 States (Idle, Patrol, Chase, Attack, Dead)
- ✅ 2 Enemy Types (SlimeBasic, EarthGolem)
- ✅ Player Combat System
- ✅ Chrono Rift Integration
- ✅ Dynamic World (Patrol)

**Optional Phases (DEFER):**
- Phase 5: FireImp Ranged (3 tasks) - Complex
- Phase 7: Polish & Debug (4 tasks) - Nice to have

**Recommendation:**
System đã rất complete! Có thể kết thúc spec ở đây và move on với game development.

---

**Status**: Phase 6 Implementation Complete ✅  
**Next**: Test patrol behavior và decide next steps  
**Goal**: Validate dynamic world behavior before concluding spec

# Test 1: Mana Consumption via Chrono Rift

**Date:** 2026-04-16  
**Test Type:** Manual Gameplay Test  
**Duration:** ~5 minutes

---

## 🎯 Test Objective

Verify that:
1. ManaBar displays correctly
2. Mana regenerates over time (5 mana/sec)
3. Chrono Rift consumes 30 mana per use
4. Cannot use Chrono Rift when mana < 30
5. ManaBar color changes when empty

---

## 📋 Prerequisites

Before starting test:
- ✅ ResourceManager autoload registered
- ✅ HUD.tscn has all components
- ✅ Prototype_World.tscn has HUD instance
- ✅ Chrono Rift system updated with mana cost

---

## 🧪 Test Steps

### Step 1: Launch Game
1. Open Godot Editor
2. Open `scenes/world/Prototype_World.tscn`
3. Press **F5** (Run Project)
4. Wait for game to load

**Expected Result:**
- Game starts successfully
- HUD visible in top-left and top-right
- ManaBar shows "100 / 100" in cyan color

---

### Step 2: Verify Initial Mana Display
**Look at StatsPanel (top-left):**
- [ ] HPBar visible (green)
- [ ] ManaBar visible (cyan)
- [ ] ManaBar shows "100 / 100"
- [ ] ChronoRiftIndicator shows "READY" (pulsing)

**If ManaBar not visible:**
- Check Output console for errors
- Verify ManaBar instance in HUD.tscn

---

### Step 3: Test Mana Regeneration
1. Wait and observe ManaBar for 5 seconds
2. Mana should stay at 100/100 (already full)

**To test regen from lower mana:**
- Skip to Step 4 first (use Chrono Rift)
- Then come back to verify regen

---

### Step 4: Use Chrono Rift (1st Time)
1. Press **Q** key (use_chrono_rift)
2. Observe HUD changes

**Expected Result:**
- ✅ Cyan circle appears around player (visual effect)
- ✅ ManaBar drops from 100 → 70 (consumed 30 mana)
- ✅ ManaBar text updates to "70 / 100"
- ✅ ChronoRiftIndicator shows cooldown timer (5.0s → 4.9s → ...)
- ✅ Output console: "CHRONO RIFT — SLOW activated (-30 mana)"

**If mana doesn't drop:**
- Check Output console for errors
- Verify PlayerStats node exists on player
- Check chrono_rift_system_poc.gd has mana cost code

---

### Step 5: Wait for Mana Regeneration
1. Wait ~6 seconds (don't press Q yet)
2. Observe ManaBar regenerating

**Expected Result:**
- ✅ Mana increases: 70 → 75 → 80 → 85 → 90 → 95 → 100
- ✅ Regeneration rate: ~5 mana per second
- ✅ ManaBar text updates continuously
- ✅ After 6 seconds, mana back to 100/100

---

### Step 6: Use Chrono Rift Multiple Times
1. Press **Q** (1st use) → Mana: 100 → 70
2. Wait 5 seconds for cooldown
3. Press **Q** (2nd use) → Mana: 70 → 40
4. Wait 5 seconds for cooldown
5. Press **Q** (3rd use) → Mana: 40 → 10
6. Wait 5 seconds for cooldown
7. Press **Q** (4th use) → **Should FAIL!**

**Expected Result (4th use):**
- ❌ Chrono Rift does NOT activate
- ❌ No cyan circle appears
- ❌ Mana stays at 10 (not enough)
- ✅ Output console: "CHRONO RIFT — Not enough mana! Need 30 mana"
- ✅ ManaBar color might be darker (empty state)

---

### Step 7: Wait for Full Regeneration
1. Don't press any keys
2. Wait ~18 seconds (10 mana → 100 mana)
3. Observe ManaBar regenerating

**Expected Result:**
- ✅ Mana regenerates: 10 → 15 → 20 → ... → 100
- ✅ Takes ~18 seconds to reach 100
- ✅ ManaBar color returns to bright cyan
- ✅ Can use Chrono Rift again

---

### Step 8: Test Rapid Usage
1. Wait for mana = 100
2. Press **Q** 4 times rapidly (spam Q)

**Expected Result:**
- ✅ Only 1st press works (mana: 100 → 70)
- ❌ 2nd, 3rd, 4th presses ignored (cooldown active)
- ✅ ChronoRiftIndicator shows cooldown timer
- ✅ After 5 seconds, can use again

---

## ✅ Test Checklist

Mark each item as you verify:

### ManaBar Display
- [ ] ManaBar visible in StatsPanel
- [ ] Cyan color (#00FFFF)
- [ ] Shows "X / Y" format
- [ ] Text updates in real-time

### Mana Regeneration
- [ ] Regenerates at ~5 mana/sec
- [ ] Continuous regeneration (not jumpy)
- [ ] Stops at max (100)

### Chrono Rift Consumption
- [ ] Consumes 30 mana per use
- [ ] ManaBar updates immediately
- [ ] Cannot use when mana < 30
- [ ] Error message in console when not enough mana

### Visual Feedback
- [ ] ManaBar color changes when low/empty
- [ ] ChronoRiftIndicator shows cooldown
- [ ] Smooth transitions

---

## 🐛 Common Issues

### Issue 1: ManaBar shows "100 / 100" but doesn't change
**Cause:** PlayerStats not emitting signals  
**Fix:**
1. Check player has PlayerStats node
2. Verify player_stats.gd has mana system code
3. Check EventBus.player_mana_changed signal

### Issue 2: Chrono Rift doesn't consume mana
**Cause:** chrono_rift_system not updated  
**Fix:**
1. Verify chrono_rift_system_poc.gd has MANA_COST constant
2. Check activate_slow() calls use_mana()
3. Verify player_stats reference is set

### Issue 3: Mana doesn't regenerate
**Cause:** PlayerStats _process() not running  
**Fix:**
1. Check PlayerStats node is active
2. Verify mana_regen_rate > 0
3. Check _process() method exists

### Issue 4: "Not enough mana" but mana shows 50/100
**Cause:** Display vs actual mana mismatch  
**Fix:**
1. Check Output console for actual mana value
2. Verify signal connections
3. Restart game

---

## 📊 Expected Test Results

| Action | Mana Before | Mana After | Time |
|--------|-------------|------------|------|
| Start game | - | 100 | 0s |
| Use Chrono Rift | 100 | 70 | +0s |
| Wait 6s | 70 | 100 | +6s |
| Use Chrono Rift | 100 | 70 | +0s |
| Use Chrono Rift | 70 | 40 | +5s |
| Use Chrono Rift | 40 | 10 | +5s |
| Try use (fail) | 10 | 10 | +5s |
| Wait 18s | 10 | 100 | +18s |

---

## ✅ Test Pass Criteria

Test PASSES if:
- ✅ ManaBar displays correctly
- ✅ Mana regenerates at 5/sec
- ✅ Chrono Rift consumes 30 mana
- ✅ Cannot use when mana < 30
- ✅ No errors in Output console

Test FAILS if:
- ❌ ManaBar doesn't update
- ❌ Mana doesn't regenerate
- ❌ Chrono Rift doesn't consume mana
- ❌ Can use Chrono Rift with 0 mana
- ❌ Errors in Output console

---

## 📝 Test Report Template

After testing, fill this out:

```
Test Date: ___________
Tester: ___________

ManaBar Display: [ ] PASS [ ] FAIL
Mana Regeneration: [ ] PASS [ ] FAIL
Chrono Rift Consumption: [ ] PASS [ ] FAIL
Low Mana Prevention: [ ] PASS [ ] FAIL

Issues Found:
1. ___________
2. ___________

Overall Result: [ ] PASS [ ] FAIL

Notes:
___________
```

---

**Ready to test?** Follow the steps and check each item! 🚀

**After testing:** Report back with results or any issues found.

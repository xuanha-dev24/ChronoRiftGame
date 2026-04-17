# Task 11 Checkpoint - Manual Test Checklist

**Date:** 2026-04-16  
**Task:** Verify spawning and integration works (Tasks 9-10)  
**Status:** Ready for Manual Testing

---

## Code Review Summary ✅

All implementation code has been reviewed and verified:

### ✅ Spawner Implementation (Task 9)
- **File:** `scripts/world/harvestable_object_spawner.gd`
- Spawns minimum 5 of each object type (trees, rocks, bushes)
- Validates spawn positions within map bounds (960x960 pixels)
- Enforces minimum spacing (80 pixels) between objects
- Includes fallback position logic after 50 failed attempts
- Properly adds objects to YSortRoot for correct visual layering

### ✅ Integration (Task 10)
- **File:** `scenes/world/Prototype_World.tscn`
- HarvestableObjectSpawner node added to Prototype_World
- Tree, Rock, and Bush scenes properly assigned to spawner exports
- YSortRoot node exists and is configured
- Player is in "player" group for interaction detection

### ✅ Scene Configuration (Task 7)
- **Tree.tscn:** resource_type="wood", proper colors, all required nodes
- **Rock.tscn:** resource_type="stone", proper colors, all required nodes
- **Bush.tscn:** resource_type="meat", proper colors, all required nodes

### ✅ Dependencies
- ResourceManager autoload registered and functional
- EventBus autoload registered
- "interact" input action defined (E key)
- HarvestableObject script complete with all state machine logic

---

## Manual Testing Checklist

Since the GUT testing framework is not installed, please perform the following manual tests in the Godot editor:

### Test 1: Object Spawning ✓
**Expected:** When Prototype_World loads, harvestable objects should spawn on the map.

**Steps:**
1. Open `scenes/world/Prototype_World.tscn` in Godot editor
2. Run the scene (F6)
3. Observe the game world

**Verify:**
- [ ] At least 5 brown rectangles (Trees) are visible on the map
- [ ] At least 5 gray rectangles (Rocks) are visible on the map
- [ ] At least 5 green rectangles (Bushes) are visible on the map
- [ ] Objects are distributed across the map (not clustered)
- [ ] Objects don't overlap with each other
- [ ] Objects are within map boundaries (not at edges)

**Expected Result:** 15+ harvestable objects spawn in valid positions

---

### Test 2: Spawn Spacing ✓
**Expected:** Objects maintain minimum 80-pixel spacing from each other.

**Steps:**
1. Run Prototype_World scene
2. Visually inspect object positions
3. Look for any objects that appear too close together

**Verify:**
- [ ] No two objects are touching or overlapping
- [ ] Objects have visible space between them
- [ ] Spacing appears consistent across all object types

**Expected Result:** All objects maintain proper spacing

---

### Test 3: YSort Layering ✓
**Expected:** Objects render in correct visual order based on Y position.

**Steps:**
1. Run Prototype_World scene
2. Move the player character around the map
3. Walk behind and in front of various harvestable objects

**Verify:**
- [ ] Player appears in front of objects when positioned below them (higher Y)
- [ ] Player appears behind objects when positioned above them (lower Y)
- [ ] Objects don't flicker or have z-fighting issues
- [ ] Visual layering feels natural and correct

**Expected Result:** YSort correctly orders player and objects

---

### Test 4: Interaction Detection ✓
**Expected:** Objects show interaction indicator when player is nearby.

**Steps:**
1. Run Prototype_World scene
2. Move player character near a harvestable object (within ~50 pixels)
3. Move away from the object

**Verify:**
- [ ] White indicator bar appears above object when player is close
- [ ] Indicator disappears when player moves away
- [ ] Indicator only shows for objects in range (not all objects)
- [ ] Object color changes to lighter/brighter shade when in range

**Expected Result:** Interaction indicators work correctly

---

### Test 5: Gathering Process ✓
**Expected:** Player can gather resources by pressing E near objects.

**Steps:**
1. Run Prototype_World scene
2. Move player near a Tree (brown rectangle)
3. Press E key when interaction indicator is visible
4. Wait for progress bar to fill (1-3 seconds)
5. Observe what happens

**Verify:**
- [ ] Progress bar appears above object when E is pressed
- [ ] Progress bar fills smoothly from left to right
- [ ] Progress bar completes in 1-3 seconds
- [ ] Object changes to darker color and reduced opacity after completion
- [ ] Object becomes non-interactive after gathering (no indicator)

**Expected Result:** Gathering completes successfully

---

### Test 6: Resource Addition ✓
**Expected:** Resources are added to ResourceManager and HUD updates.

**Steps:**
1. Run Prototype_World scene
2. Note the current wood count in the HUD (top of screen)
3. Gather from a Tree (brown object)
4. Check the wood count in the HUD

**Verify:**
- [ ] Wood count increases by 1-3 after gathering from Tree
- [ ] Stone count increases by 1-3 after gathering from Rock
- [ ] Meat count increases by 1-3 after gathering from Bush
- [ ] HUD updates immediately after gathering completes
- [ ] Console shows ResourceManager log messages

**Expected Result:** Resources are added correctly

---

### Test 7: Gathering Cancellation ✓
**Expected:** Gathering cancels if player moves away.

**Steps:**
1. Run Prototype_World scene
2. Move player near an object and press E to start gathering
3. Immediately move player away (before progress bar completes)
4. Return to the same object

**Verify:**
- [ ] Progress bar disappears when player moves away
- [ ] Object returns to normal state (not depleted)
- [ ] Player can start gathering again from the same object
- [ ] No resources are added when gathering is cancelled

**Expected Result:** Gathering cancels cleanly

---

### Test 8: Respawn System ✓
**Expected:** Objects respawn 30-60 seconds after being harvested.

**Steps:**
1. Run Prototype_World scene
2. Gather from an object until it becomes depleted (dark, semi-transparent)
3. Wait 30-60 seconds (or speed up time in debugger)
4. Observe the object

**Verify:**
- [ ] Object remains depleted for 30-60 seconds
- [ ] Object returns to normal appearance after respawn timer
- [ ] Object becomes interactive again after respawn
- [ ] Player can gather from the object again

**Expected Result:** Objects respawn correctly

---

### Test 9: Multiple Objects ✓
**Expected:** System handles multiple objects simultaneously.

**Steps:**
1. Run Prototype_World scene
2. Gather from multiple different objects in sequence
3. Try to interact with multiple objects at once (stand between two)

**Verify:**
- [ ] Each object maintains its own state independently
- [ ] Gathering from one object doesn't affect others
- [ ] Only one object shows interaction indicator at a time (nearest)
- [ ] Multiple objects can be in depleted state simultaneously

**Expected Result:** Multiple objects work independently

---

### Test 10: Error Handling ✓
**Expected:** System handles edge cases gracefully.

**Steps:**
1. Run Prototype_World scene
2. Try various edge cases:
   - Spam E key rapidly while near object
   - Move in and out of range rapidly
   - Try to interact while object is depleted

**Verify:**
- [ ] No errors appear in console
- [ ] No visual glitches or flickering
- [ ] System remains stable and responsive
- [ ] Depleted objects don't respond to interaction

**Expected Result:** System handles edge cases without errors

---

## Known Limitations

1. **No Automated Tests:** GUT framework is not installed, so automated tests cannot run
2. **Manual Testing Required:** All verification must be done manually in Godot editor
3. **Timing Tests:** Respawn timing (30-60s) requires patience or debugger time manipulation

---

## Completion Criteria

Task 11 checkpoint is considered **PASSED** if:

- ✅ All code review items are verified (completed above)
- ⏳ At least 8 out of 10 manual tests pass
- ⏳ No critical bugs or errors are found
- ⏳ System integrates properly with existing game systems

---

## Next Steps

After completing manual testing:

1. If all tests pass → Proceed to Task 12 (Polish and tuning)
2. If tests fail → Report issues and fix before proceeding
3. Document any bugs or unexpected behavior found during testing

---

## Notes for User

**To run manual tests:**
1. Open Godot 4.x editor
2. Open the ChronoRiftGame project
3. Open `scenes/world/Prototype_World.tscn`
4. Press F6 to run the scene
5. Follow the test steps above
6. Check off items as you verify them

**Console Output:**
- Look for `[ResourceManager]` messages when gathering
- Look for `[HarvestableObjectSpawner]` warnings if spawn fails
- Look for `[HarvestableObject]` errors if nodes are missing

**If you encounter issues:**
- Check the console for error messages
- Verify all scenes are saved
- Ensure ResourceManager autoload is enabled
- Confirm "interact" input action is defined (E key)

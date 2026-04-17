# Resource Gathering System - Manual Testing Checklist
## Tasks 12.1-12.4: Final Verification

**Purpose:** This checklist guides manual testing of the Resource Gathering & Farming System to verify visual feedback, timing, edge cases, and integration.

**How to Use:**
1. Open ChronoRiftGame project in Godot
2. Open `scenes/world/Prototype_World.tscn`
3. Press F5 to run the game
4. Follow each test section below
5. Check off items as you verify them

---

## Setup Verification

Before testing, verify the scene is properly configured:

- [ ] Prototype_World scene opens without errors
- [ ] HarvestableObjectSpawner node exists in scene tree
- [ ] Tree, Rock, Bush scenes are assigned in spawner properties
- [ ] YSortRoot node exists with y_sort_enabled = true
- [ ] Player is in "player" group (check in Node tab)

---

## Task 12.1: Visual Feedback and Colors

### Test 1.1: Object Spawning and Colors

**Steps:**
1. Run the game (F5)
2. Observe the map

**Verify:**
- [ ] At least 5 trees spawn (brown ColorRects)
- [ ] At least 5 rocks spawn (gray ColorRects)
- [ ] At least 5 bushes spawn (green ColorRects)
- [ ] Objects are distributed across the map (not clustered)
- [ ] Objects don't overlap with each other
- [ ] Objects don't overlap with player spawn position

**Expected Colors:**
- Trees: Brown (darker than rocks/bushes)
- Rocks: Gray (neutral color)
- Bushes: Green (vibrant)

### Test 1.2: Interaction Indicator

**Steps:**
1. Walk player near a tree (within ~50 pixels)
2. Observe the tree

**Verify:**
- [ ] White bar appears above tree when player is close
- [ ] White bar disappears when player walks away
- [ ] Indicator is clearly visible against background
- [ ] Tree color changes to lighter brown when in range

**Repeat for:**
- [ ] Rock (should show white bar, lighter gray color)
- [ ] Bush (should show white bar, lighter green color)

### Test 1.3: Progress Bar During Gathering

**Steps:**
1. Walk near a tree
2. Press E key to start gathering
3. Watch the progress bar

**Verify:**
- [ ] Black progress bar appears above tree
- [ ] Green fill starts at 0% (left edge)
- [ ] Green fill smoothly increases from left to right
- [ ] Fill reaches 100% (full width) after 1-3 seconds
- [ ] Progress bar disappears when gathering completes
- [ ] White interaction indicator disappears during gathering

### Test 1.4: Depleted State Visual

**Steps:**
1. Gather from a tree until completion
2. Observe the tree after gathering

**Verify:**
- [ ] Tree color becomes darker brown
- [ ] Tree becomes semi-transparent (50% opacity)
- [ ] No interaction indicator appears when walking near
- [ ] Tree is clearly distinguishable as "depleted"

**Repeat for:**
- [ ] Rock (darker gray, semi-transparent)
- [ ] Bush (darker green, semi-transparent)

### Test 1.5: Color Contrast

**Steps:**
1. Observe all three object types in different states

**Verify:**
- [ ] Normal state colors are clearly different from each other
- [ ] Interactable state is noticeably lighter than normal
- [ ] Depleted state is noticeably darker than normal
- [ ] All states are easily distinguishable at a glance

---

## Task 12.2: Timing Values for Game Feel

### Test 2.1: Gathering Duration

**Steps:**
1. Gather from 5 different trees
2. Time each gathering with a stopwatch or count seconds

**Verify:**
- [ ] Each gathering takes between 1-3 seconds
- [ ] Gathering durations vary (not all the same)
- [ ] Duration feels responsive (not too slow)
- [ ] Duration requires commitment (not instant)

**Subjective Assessment:**
- Does 1-3 seconds feel good? (Too fast? Too slow? Just right?)
- Note: _______________________________________________

### Test 2.2: Respawn Duration

**Steps:**
1. Gather from a tree
2. Wait for it to respawn
3. Time the respawn duration

**Verify:**
- [ ] Tree respawns after 30-60 seconds
- [ ] Respawn time varies between objects
- [ ] Respawned tree returns to normal color and full opacity
- [ ] Respawned tree is immediately harvestable

**Subjective Assessment:**
- Does 30-60 seconds feel balanced? (Too long? Too short?)
- Note: _______________________________________________

### Test 2.3: Interaction Range

**Steps:**
1. Walk toward a tree from a distance
2. Note when the interaction indicator appears
3. Walk away slowly and note when it disappears

**Verify:**
- [ ] Indicator appears at approximately 50 pixels distance
- [ ] Range feels comfortable (not too close, not too far)
- [ ] Player doesn't need pixel-perfect positioning
- [ ] Range is consistent across all object types

**Subjective Assessment:**
- Does 50 pixels feel right? (Too close? Too far?)
- Note: _______________________________________________

### Test 2.4: Overall Game Feel

**Steps:**
1. Gather resources from multiple objects
2. Move around the map naturally

**Verify:**
- [ ] Gathering feels responsive and satisfying
- [ ] Respawn timing encourages exploration
- [ ] Resource availability feels balanced
- [ ] System doesn't feel tedious or grindy

---

## Task 12.3: Edge Cases and Error Handling

### Test 3.1: Multiple Objects in Range

**Steps:**
1. Position player between two trees (both in range)
2. Observe interaction indicators

**Verify:**
- [ ] Both trees show interaction indicators
- [ ] Pressing E interacts with one tree (not both)
- [ ] Can gather from second tree after first completes
- [ ] No errors or unexpected behavior

### Test 3.2: Rapid Enter/Exit of Range

**Steps:**
1. Walk back and forth across interaction range boundary
2. Move quickly in and out of range

**Verify:**
- [ ] Interaction indicator appears/disappears smoothly
- [ ] No flickering or visual glitches
- [ ] State transitions are immediate
- [ ] No errors in console

### Test 3.3: Spamming Interact Key

**Steps:**
1. Walk near a tree
2. Rapidly press E key multiple times

**Verify:**
- [ ] Gathering starts only once
- [ ] No duplicate gathering processes
- [ ] No errors in console
- [ ] System behaves normally

### Test 3.4: Cancelling Gathering

**Steps:**
1. Start gathering from a tree
2. Walk away before completion (at 50% progress)
3. Return to the tree

**Verify:**
- [ ] Progress bar disappears when leaving range
- [ ] Gathering is cancelled (progress resets)
- [ ] Tree returns to interactable state
- [ ] Can start gathering again from 0%

### Test 3.5: Gathering at Edge of Range

**Steps:**
1. Position player at exact edge of interaction range
2. Start gathering
3. Move slightly during gathering

**Verify:**
- [ ] Gathering starts successfully
- [ ] Small movements don't cancel gathering
- [ ] Moving out of range cancels gathering
- [ ] Behavior is consistent and predictable

### Test 3.6: Player Death During Gathering (If Applicable)

**Steps:**
1. Start gathering from a tree
2. Take damage from an enemy to die (if enemies present)

**Verify:**
- [ ] Gathering is cancelled on death
- [ ] No errors occur
- [ ] Tree returns to normal state
- [ ] System recovers gracefully

---

## Task 12.4: Integration with Existing Systems

### Test 4.1: ResourceManager Integration

**Steps:**
1. Note current resource counts in HUD
2. Gather wood from a tree
3. Observe HUD

**Verify:**
- [ ] Wood count increases by 1-3
- [ ] HUD updates immediately after gathering
- [ ] Amount varies between gatherings (1-3 random)
- [ ] No errors in console

**Repeat for:**
- [ ] Stone from rocks (increases stone count)
- [ ] Meat from bushes (increases meat count)

### Test 4.2: EventBus Signal Integration

**Steps:**
1. Open Godot console/output
2. Gather from a tree
3. Check console output

**Verify:**
- [ ] "[ResourceManager] wood changed: X (delta: +Y)" message appears
- [ ] HUD updates match console output
- [ ] No error messages
- [ ] Signal flow works correctly

### Test 4.3: Input Action Integration

**Steps:**
1. Walk near a tree
2. Press E key (interact action)

**Verify:**
- [ ] E key triggers gathering
- [ ] No conflicts with other input actions
- [ ] Input is responsive
- [ ] Works consistently

### Test 4.4: Player Movement Integration

**Steps:**
1. Walk around harvestable objects
2. Try to walk through objects
3. Gather while moving

**Verify:**
- [ ] Player can move freely around objects
- [ ] Objects don't block player movement
- [ ] Player can move during gathering
- [ ] Moving out of range cancels gathering
- [ ] No collision issues

### Test 4.5: YSort Visual Layering

**Steps:**
1. Walk behind a tree (player Y position > tree Y position)
2. Walk in front of a tree (player Y position < tree Y position)
3. Repeat for rocks and bushes

**Verify:**
- [ ] Player renders behind objects when Y position is greater
- [ ] Player renders in front of objects when Y position is less
- [ ] Visual layering is correct and consistent
- [ ] No z-fighting or rendering glitches

### Test 4.6: Enemy AI Integration (If Enemies Present)

**Steps:**
1. Spawn enemies near harvestable objects
2. Observe enemy pathfinding

**Verify:**
- [ ] Enemies navigate around objects correctly
- [ ] Objects don't block enemy pathfinding
- [ ] No AI errors or stuck enemies
- [ ] System doesn't interfere with combat

---

## Performance Testing

### Test 5.1: Spawn Performance

**Steps:**
1. Load Prototype_World scene
2. Observe loading time and frame rate

**Verify:**
- [ ] Scene loads without delay
- [ ] 15+ objects spawn instantly
- [ ] No frame drops during spawn
- [ ] Game runs smoothly (60 FPS)

### Test 5.2: Runtime Performance

**Steps:**
1. Run game for several minutes
2. Gather from multiple objects
3. Monitor frame rate

**Verify:**
- [ ] Frame rate remains stable (60 FPS)
- [ ] No performance degradation over time
- [ ] Multiple objects updating simultaneously works fine
- [ ] No memory leaks or issues

---

## Final Verification

### Overall System Check

- [ ] All visual feedback is clear and intuitive
- [ ] Timing values feel balanced and fun
- [ ] Edge cases are handled gracefully
- [ ] Integration with existing systems is seamless
- [ ] No errors or warnings in console
- [ ] System is ready for production

### Issues Found

List any issues discovered during testing:

1. _______________________________________________
2. _______________________________________________
3. _______________________________________________

### Tuning Recommendations

Based on testing, suggest any tuning adjustments:

**Gathering Time:**
- Current: 1-3 seconds
- Suggested: _______________________________________________

**Respawn Time:**
- Current: 30-60 seconds
- Suggested: _______________________________________________

**Interaction Range:**
- Current: 50 pixels
- Suggested: _______________________________________________

**Visual Adjustments:**
- _______________________________________________

---

## Sign-Off

**Tester:** _______________________________________________

**Date:** _______________________________________________

**Status:** [ ] PASS  [ ] PASS WITH ISSUES  [ ] FAIL

**Notes:**
_______________________________________________
_______________________________________________
_______________________________________________


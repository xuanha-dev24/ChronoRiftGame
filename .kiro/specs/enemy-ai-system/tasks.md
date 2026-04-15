# Implementation Plan: Enemy AI System

## Overview

This implementation plan breaks down the Enemy AI System into actionable coding tasks following a 5-phase approach. The plan prioritizes getting a playable combat loop working quickly (SlimeBasic → Chrono Rift → Player Response) before adding variety (EarthGolem → FireImp).

**Implementation Strategy:**
- Phase 1: Core state machine with SlimeBasic (melee combat foundation)
- Phase 2: Chrono Rift integration (time manipulation effects)
- Phase 3: Player combat response (damage, i-frames, death)
- Phase 4: EarthGolem variant (add variety with minimal code)
- Phase 5: FireImp ranged combat (most complex, deferred)

**Testing Approach:**
- Property-based tests verify universal correctness properties (13 properties defined in design)
- Unit tests validate specific scenarios and edge cases
- Integration tests ensure full combat loop works end-to-end

---

## Tasks

### Phase 1: Core State Machine & SlimeBasic

- [x] 1. Set up base enemy architecture
  - Create `scripts/enemies/` directory structure
  - Create `base_enemy.gd` as abstract CharacterBody2D class
  - Define exported variable groups (Stats, AI Behavior, Loot, Debug)
  - Implement core properties: `current_hp`, `current_speed`, `is_slowed`, `can_attack`, `player_ref`
  - Add to "enemies" group and configure collision layer 2
  - _Requirements: 1.1, 5, 8.1_

- [x] 2. Implement state machine foundation
  - [x] 2.1 Create enemy state machine controller
    - Create `scripts/enemies/enemy_state_machine.gd`
    - Implement `_init(enemy)`, `change_state(new_state)`, `update(delta)`, `get_current_state()`
    - Add state transition logging when `debug_log = true`
    - Store reference to owning enemy
    - _Requirements: 1.1, 8.2_

  - [x] 2.2 Create abstract state base class
    - Create `scripts/enemies/enemy_state.gd`
    - Define interface: `enter()`, `exit()`, `update(delta)`, `get_state_name()`
    - Store reference to enemy and state machine
    - _Requirements: 1.1_

  - [x] 2.3 Create states directory
    - Create `scripts/enemies/states/` directory
    - _Requirements: 1.1_

- [x] 3. Implement IdleState
  - Create `scripts/enemies/states/idle_state.gd` extending EnemyState
  - Implement `enter()`: set velocity to zero, start idle animation
  - Implement `update(delta)`: check for player in aggro range, apply idle pulse effect
  - Implement idle color pulse using `sin(Time.get_ticks_msec())`
  - Transition to CHASE when player enters aggro range
  - _Requirements: 1.2, 1.3, 6.1_

- [x] 4. Implement ChaseState
  - [x] 4.1 Create chase state with movement logic
    - Create `scripts/enemies/states/chase_state.gd` extending EnemyState
    - Implement `enter()`: initialize chase behavior
    - Implement `update(delta)`: calculate direction to player, apply isometric transform, set velocity
    - Use isometric transformation: `iso_x = dir.x - dir.y`, `iso_y = (dir.x + dir.y) * 0.5`
    - Transition to ATTACK when player in attack range
    - Transition to IDLE when player out of aggro range for 2+ seconds
    - _Requirements: 1.3, 1.4, 1.8, 2.1, 2.2_

  - [ ]* 4.2 Write property test for chase direction
    - **Property 5: Chase direction toward player**
    - **Validates: Requirements 2.1, 2.2**
    - Generate random enemy/player positions, verify velocity direction is normalized vector toward player after isometric transform
    - _Requirements: 2.1, 2.2_

  - [ ]* 4.3 Write property test for isometric transformation
    - **Property 6: Isometric transformation correctness**
    - **Validates: Requirements 2.2**
    - Generate random direction vectors, verify transformation produces correct `iso_x` and `iso_y` values
    - _Requirements: 2.2_

- [x] 5. Implement AttackState
  - [x] 5.1 Create attack state with melee logic
    - Create `scripts/enemies/states/attack_state.gd` extending EnemyState
    - Implement `enter()`: stop movement, start windup timer (0.2s)
    - Implement `update(delta)`: handle windup → attack → cooldown sequence
    - Flash sprite red during attack
    - Check player in attack range and call `player.take_damage(damage)`
    - Respect attack cooldown before allowing next attack
    - Transition to CHASE after attack completes (if player in aggro range)
    - _Requirements: 1.4, 1.5, 3.1, 3.2, 3.3, 3.4, 6.2_

  - [ ]* 5.2 Write property test for damage range check
    - **Property 7: Damage dealt only within attack range**
    - **Validates: Requirements 3.2**
    - Generate random enemy/player positions, verify damage only dealt when distance <= attack_range
    - _Requirements: 3.2_

  - [ ]* 5.3 Write unit tests for attack sequence
    - Test windup timer triggers attack
    - Test cooldown prevents rapid attacks
    - Test transition to CHASE after attack
    - Test no damage dealt if player out of range
    - _Requirements: 3.1, 3.2, 3.3_

- [x] 6. Implement DeadState
  - Create `scripts/enemies/states/dead_state.gd` extending EnemyState
  - Implement `enter()`: disable collision, start fade-out animation, emit `EventBus.enemy_killed` signal
  - Implement `update(delta)`: animate modulate alpha from 1.0 to 0.0 over 0.5s
  - Call `queue_free()` after fade completes
  - _Requirements: 1.6, 6.4, 7.1_

- [x] 7. Implement SlimeBasic enemy type
  - [x] 7.1 Create SlimeBasic class and scene
    - Create `scripts/enemies/slime_basic.gd` extending BaseEnemy
    - Override exported variables with SlimeBasic stats (HP: 30, Speed: 60, Damage: 5, etc.)
    - Create `scenes/enemies/SlimeBasic.tscn` with ColorRect (green) and collision shape
    - Initialize state machine with IdleState in `_ready()`
    - _Requirements: 5, 7.4, 7.5_

  - [x] 7.2 Implement core enemy lifecycle
    - Implement `_ready()`: cache player reference, initialize state machine, set up collision
    - Implement `_physics_process(delta)`: update state machine, apply velocity with `move_and_slide()`
    - Implement `take_damage(amount)`: reduce HP, flash red, check for death transition
    - Implement helper methods: `get_player()`, `is_player_in_range(range)`, `get_distance_to_player()`
    - _Requirements: 1.1, 1.6, 6.3_

  - [ ]* 7.3 Write property test for stationary states
    - **Property 1: Stationary states have zero velocity**
    - **Validates: Requirements 1.2, 3.4**
    - Generate random enemies in IDLE or ATTACK state, verify velocity is Vector2.ZERO
    - _Requirements: 1.2, 3.4_

  - [ ]* 7.4 Write property test for state transitions
    - **Property 2: State transitions respect range conditions**
    - **Validates: Requirements 1.3, 1.4, 1.5**
    - Generate random enemy/player positions and ranges, verify transitions occur correctly based on distance
    - _Requirements: 1.3, 1.4, 1.5_

  - [ ]* 7.5 Write property test for death transition
    - **Property 3: Death transition is universal**
    - **Validates: Requirements 1.6**
    - Generate random enemies in various states with HP <= 0, verify all transition to DEAD
    - _Requirements: 1.6_

- [x] 8. Checkpoint - Test SlimeBasic in prototype world
  - Add SlimeBasic spawn to `Prototype_World.tscn`
  - Test full state cycle: IDLE → CHASE → ATTACK → DEAD
  - Verify visual feedback (colors, animations)
  - Verify EventBus signal emission on death
  - Ensure all tests pass, ask the user if questions arise.

---

### Phase 2: Chrono Rift Integration

- [x] 9. Implement slow effect system
  - [x] 9.1 Add slow effect methods to BaseEnemy
    - Implement `apply_slow(factor: float)`: set `is_slowed = true`, multiply `current_speed` by factor, change sprite to magenta
    - Implement `remove_slow()`: set `is_slowed = false`, restore `current_speed` to `base_speed`, restore original sprite color
    - Add safety check to prevent stacking slow effects
    - _Requirements: 4.1, 4.2, 4.3_

  - [ ]* 9.2 Write property test for slow effect round-trip
    - **Property 9: Slow effect round-trip**
    - **Validates: Requirements 4.1, 4.2**
    - Generate random enemies with various base speeds, apply slow then remove, verify speed restored
    - _Requirements: 4.1, 4.2_

  - [ ]* 9.3 Write property test for slow multiplier
    - **Property 10: Slow effect multiplies speed**
    - **Validates: Requirements 4.1**
    - Generate random base speeds and slow factors, verify current_speed = base_speed * factor
    - _Requirements: 4.1_

  - [ ]* 9.4 Write property test for slow visual feedback
    - **Property 11: Slowed enemy visual feedback**
    - **Validates: Requirements 4.3**
    - Apply slow to random enemies, verify sprite color is magenta/pink
    - _Requirements: 4.3_

- [x] 10. Integrate with ChronoRiftSystem
  - Modify `scripts/systems/chrono_rift_system_poc.gd` to call `apply_slow()` on enemies in rift area
  - Call `remove_slow()` when enemies exit rift or rift expires
  - Use `get_tree().get_nodes_in_group("enemies")` to find affected enemies
  - Check distance to rift center for each enemy
  - _Requirements: 4.1, 4.2_

- [x] 11. Verify state machine continues while slowed
  - [ ]* 11.1 Write property test for state transitions while slowed
    - **Property 12: State transitions continue while slowed**
    - **Validates: Requirements 4.4**
    - Generate random slowed enemies, verify state transitions still occur based on range/HP
    - _Requirements: 4.4_

  - [ ]* 11.2 Write integration test for slow effect
    - Spawn enemy, activate rift, verify enemy slows down
    - Verify enemy continues chasing player while slowed
    - Verify enemy returns to normal speed when rift expires
    - _Requirements: 4.1, 4.2, 4.4_

- [x] 12. Checkpoint - Test Chrono Rift effects
  - Spawn multiple SlimeBasic enemies
  - Activate Chrono Rift near enemies
  - Verify enemies slow down and turn magenta
  - Verify enemies continue state transitions while slowed
  - Verify enemies return to normal when rift expires
  - Ensure all tests pass, ask the user if questions arise.

---

### Phase 3: Player Combat Response

- [x] 13. Implement player damage system
  - [x] 13.1 Add damage handling to player controller
    - Add `current_hp` and `max_hp` properties to player
    - Implement `take_damage(amount: int)` method
    - Flash player sprite red when hit (0.1s)
    - Emit `EventBus.player_damaged` signal
    - _Requirements: 3.2_

  - [x] 13.2 Implement invincibility frames (i-frames)
    - Add `is_invincible` flag and `iframe_duration` timer (0.5s)
    - In `take_damage()`, check `is_invincible` and return early if true
    - Set `is_invincible = true` after taking damage
    - Start timer to reset `is_invincible` after duration
    - Add visual feedback (flashing sprite) during i-frames
    - _Requirements: 3.2_

  - [ ]* 13.3 Write unit tests for i-frames
    - Test damage blocked during i-frame window
    - Test damage accepted after i-frames expire
    - Test multiple rapid attacks only deal damage once
    - _Requirements: 3.2_

- [x] 14. Implement player death
  - Add death check in `take_damage()`: if `current_hp <= 0`, transition to death state
  - Implement death animation (fade out, disable input)
  - Emit `EventBus.player_died` signal
  - Display simple death message (console log for now)
  - _Requirements: 1.6_

- [x] 15. Add HP display to HUD
  - Update `scripts/ui/hud.gd` to show current HP / max HP
  - Connect to `EventBus.player_damaged` signal to update display
  - Use simple label for prototype (e.g., "HP: 100/100")
  - _Requirements: 3.2_

- [x] 16. Checkpoint - Test player combat response
  - Spawn SlimeBasic enemy
  - Let enemy attack player
  - Verify player takes damage and HP decreases
  - Verify i-frames prevent damage stacking
  - Verify player dies when HP reaches zero
  - Verify HUD updates correctly
  - Ensure all tests pass, ask the user if questions arise.

---

### Phase 4: EarthGolem Variant (SHOULD Priority)

- [x] 17. Implement EarthGolem enemy type
  - [x] 17.1 Create EarthGolem class and scene
    - Create `scripts/enemies/earth_golem.gd` extending BaseEnemy
    - Override exported variables with EarthGolem stats (HP: 120, Speed: 40, Damage: 15, etc.)
    - Create `scenes/enemies/EarthGolem.tscn` with ColorRect (brown) and collision shape
    - Set sprite scale to 1.5x for larger appearance
    - _Requirements: 5, 7.4_

  - [ ]* 17.2 Write integration test for multiple enemy types
    - Spawn both SlimeBasic and EarthGolem
    - Verify both behave correctly with different stats
    - Verify player can damage both types
    - Verify both types can damage player
    - _Requirements: 5, 7.4_

- [x] 18. Test enemy variety
  - Spawn 3 SlimeBasic and 2 EarthGolem in prototype world
  - Verify visual distinction (color, size)
  - Verify stat differences (speed, damage, HP)
  - Test combat against both types
  - Ensure all tests pass, ask the user if questions arise.

---

### Phase 5: FireImp Ranged Combat (DEFER Priority)

- [ ] 19. Implement projectile system
  - [ ] 19.1 Create Projectile class and scene
    - Create `scripts/enemies/projectile.gd` as Area2D
    - Add properties: `speed`, `damage`, `direction`, `lifetime`
    - Implement `_physics_process(delta)`: move in direction, decrement lifetime
    - Implement `_on_body_entered(body)`: check for player, deal damage, destroy self
    - Create `scenes/enemies/Projectile.tscn` with ColorRect (red) and collision shape
    - _Requirements: 3.5_

  - [ ]* 19.2 Write property test for projectile direction
    - **Property 8: Projectile direction toward target**
    - **Validates: Requirements 3.5**
    - Generate random enemy/player positions, spawn projectile, verify direction is normalized vector toward player
    - _Requirements: 3.5_

  - [ ]* 19.3 Write unit tests for projectile lifecycle
    - Test projectile moves in correct direction
    - Test projectile destroys after lifetime expires
    - Test projectile destroys on player collision
    - Test projectile deals correct damage
    - _Requirements: 3.5_

- [ ] 20. Implement FireImp enemy type
  - [ ] 20.1 Create FireImp class with ranged attack
    - Create `scripts/enemies/fire_imp.gd` extending BaseEnemy
    - Override exported variables with FireImp stats (HP: 50, Speed: 100, Damage: 8, etc.)
    - Override `attack_player()` to spawn projectile instead of melee damage
    - Calculate projectile direction: `normalize(player_position - enemy_position)`
    - Create `scenes/enemies/FireImp.tscn` with ColorRect (red) and collision shape
    - _Requirements: 3.5, 5, 7.4_

  - [ ] 20.2 Modify ChaseState for kiting behavior
    - Add check in FireImp's ChaseState: stop moving when distance to player < 100px
    - Maintain attack range distance while player approaches
    - Transition to ATTACK when player in attack range (120px)
    - _Requirements: 2.1, 3.5_

  - [ ]* 20.3 Write integration test for ranged combat
    - Spawn FireImp and player
    - Verify FireImp maintains distance
    - Verify FireImp shoots projectiles
    - Verify projectiles hit player and deal damage
    - _Requirements: 3.5_

- [ ] 21. Final checkpoint - Test all enemy types
  - Spawn mix of SlimeBasic, EarthGolem, and FireImp
  - Test combat against all three types simultaneously
  - Verify Chrono Rift affects all types
  - Verify player can defeat all types
  - Verify loot signals emitted for all types
  - Ensure all tests pass, ask the user if questions arise.

---

### Phase 6: PatrolState Implementation (SHOULD Priority)

- [x] 22. Implement PatrolState
  - [x] 22.1 Create patrol state with waypoint logic
    - Create `scripts/enemies/states/patrol_state.gd` extending EnemyState
    - Store `spawn_position` in BaseEnemy `_ready()`
    - Implement `enter()`: select random waypoint within patrol_radius of spawn_position
    - Implement `update(delta)`: move toward waypoint, check if reached (distance < 10px)
    - Transition to CHASE if player enters aggro range
    - Transition to IDLE when waypoint reached
    - _Requirements: 1.7, 1.8_

  - [ ]* 22.2 Write property test for patrol waypoints
    - **Property 4: Patrol waypoints within radius**
    - **Validates: Requirements 1.7**
    - Generate random enemies with various patrol radii, verify all waypoints satisfy distance <= patrol_radius
    - _Requirements: 1.7_

  - [ ]* 22.3 Write unit tests for patrol behavior
    - Test waypoint selection within radius
    - Test movement toward waypoint
    - Test transition to IDLE when waypoint reached
    - Test transition to CHASE when player enters range
    - _Requirements: 1.7, 1.8_

- [x] 23. Integrate PatrolState into state machine
  - Modify IdleState to transition to PATROL after random timer (3-5 seconds)
  - Modify ChaseState to return to PATROL (instead of IDLE) when player exits aggro range
  - Test patrol behavior with all enemy types
  - Ensure all tests pass, ask the user if questions arise.

---

### Phase 7: Polish & Debug Tools

- [ ] 24. Implement debug visualization
  - [ ] 24.1 Add debug drawing to BaseEnemy
    - In `_draw()`, check if `debug_log = true`
    - Draw aggro range circle (cyan, radius = aggro_range)
    - Draw attack range circle (red, radius = attack_range)
    - Call `queue_redraw()` each frame when debug enabled
    - _Requirements: 8.3_

  - [ ] 24.2 Add state label display
    - Create Label node as child of enemy
    - Update label text with current state name each frame
    - Position label above enemy sprite
    - Only visible when `debug_log = true`
    - _Requirements: 8.4_

- [ ] 25. Implement aggro loss timeout
  - [ ]* 25.1 Write property test for aggro loss
    - **Property 13: Aggro loss after timeout**
    - **Validates: Requirements 1.8**
    - Generate random enemies in CHASE state with player out of range, verify transition to IDLE/PATROL after 2.0s
    - _Requirements: 1.8_

  - [ ] 25.2 Add timeout logic to ChaseState
    - Track time player has been out of aggro range
    - Transition to PATROL/IDLE after 2.0 seconds
    - Reset timer when player re-enters aggro range
    - _Requirements: 1.8_

- [ ] 26. Final integration test
  - [ ]* 26.1 Write full combat loop integration test
    - Spawn enemy → Player enters range → Enemy chases → Enemy attacks → Player defeats enemy
    - Verify all state transitions occur correctly
    - Verify damage dealt and received correctly
    - Verify loot signal emitted on death
    - _Requirements: 1.1, 1.3, 1.4, 1.5, 1.6, 3.2, 7.1_

  - [ ]* 26.2 Write Chrono Rift integration test
    - Enemy chasing → Rift activated → Enemy slowed → Rift expires → Enemy returns to normal
    - Verify slow effect applied and removed correctly
    - Verify visual feedback (color change)
    - Verify state transitions continue while slowed
    - _Requirements: 4.1, 4.2, 4.3, 4.4_

- [ ] 27. Final checkpoint - Complete system validation
  - Run all property tests (13 properties × 100 iterations)
  - Run all unit tests (~25 scenarios)
  - Run all integration tests (3 full scenarios)
  - Test with 10 enemies simultaneously, verify 60 FPS maintained
  - Verify all requirements met (MUST and SHOULD priorities)
  - Ensure all tests pass, ask the user if questions arise.

---

## Notes

- Tasks marked with `*` are optional testing tasks and can be skipped for faster MVP
- Each task references specific requirements for traceability (e.g., _Requirements: 1.1, 2.2_)
- Checkpoints ensure incremental validation at key milestones
- Property tests validate universal correctness properties across many generated inputs
- Unit tests validate specific examples, edge cases, and integration points
- Implementation follows 5-phase plan: SlimeBasic → Chrono Rift → Player Response → EarthGolem → FireImp
- PatrolState is SHOULD priority and can be implemented after core combat loop works
- Debug tools help with tuning and troubleshooting during development

---

## Testing Summary

**Property-Based Tests** (13 properties):
1. Stationary states have zero velocity
2. State transitions respect range conditions
3. Death transition is universal
4. Patrol waypoints within radius
5. Chase direction toward player
6. Isometric transformation correctness
7. Damage dealt only within attack range
8. Projectile direction toward target
9. Slow effect round-trip
10. Slow effect multiplies speed
11. Slowed enemy visual feedback
12. State transitions continue while slowed
13. Aggro loss after timeout

**Unit Tests** (~25 scenarios):
- Attack sequence (windup, cooldown, transitions)
- I-frames (damage blocking, expiration)
- Projectile lifecycle (movement, collision, lifetime)
- Patrol behavior (waypoint selection, movement, transitions)

**Integration Tests** (3 scenarios):
1. Full combat loop (spawn → chase → attack → death)
2. Chrono Rift interaction (slow → continue behavior → restore)
3. Multiple enemy types (variety, coexistence, combat)

**Performance Targets**:
- 10 enemies @ 60 FPS (required)
- 20 enemies @ 45+ FPS (acceptable for web)

---

## Implementation Priority Summary

**Phase 1 (MUST)**: Core state machine + SlimeBasic melee combat  
**Phase 2 (MUST)**: Chrono Rift integration with slow effects  
**Phase 3 (MUST)**: Player damage, i-frames, death  
**Phase 4 (SHOULD)**: EarthGolem variant for variety  
**Phase 5 (DEFER)**: FireImp ranged combat with projectiles  
**Phase 6 (SHOULD)**: PatrolState for idle wandering  
**Phase 7 (SHOULD)**: Debug tools and polish  

---

**Status**: Ready for Implementation  
**Next Steps**: Begin Phase 1 - Core State Machine & SlimeBasic

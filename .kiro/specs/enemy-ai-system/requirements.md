# ChronoRift

## Enemy AI System

*Requirements Document — Prototype Stage*

| | |
|---|---|
| **Version** | 1.1 — Prototype Revised |
| **Phase** | Phase 7: Enemy AI |
| **Engine** | Godot 4.x / GDScript |
| **Platform** | HTML5 (Web Browser) |
| **Status** | In Development |

---

## 1. Scope & Priority

> ⚠ **Prototype-First Approach**
>
> This document focuses on what must work now to validate combat fun. Requirements are tagged:
> - **MUST** — Blocking. Do not move to Phase 8 without this.
> - **SHOULD** — Adds polish. Implement if time allows.
> - **DEFER** — Save for MVP or later phase.

---

## 2. Recommended Implementation Order

Build in this sequence to get a playable combat loop as fast as possible:

| Step | Task | Why |
|------|------|-----|
| **1** | SlimeBasic State Machine + Chase | Core AI loop. Everything else builds on this. |
| **2** | SlimeBasic Melee Attack | Enemy deals damage → combat loop is complete. |
| **3** | Player i-frames + HP response | Player must react to being hit for combat to feel fair. |
| **4** | Playtest | Validate fun before adding more enemies. |
| **5** | EarthGolem (copy Slime, tweak stats) | Adds variety with minimal new code. |
| **6** | Win/Lose condition (basic) | Makes each session have a clear start/end. |
| **7** | FireImp + Projectile | Most complex; do last when base is solid. |

---

## 3. Requirements

### Req 1 — Enemy State Machine

**User Story:** As a player, I want enemies to exhibit intelligent behavior patterns, so that combat feels dynamic and engaging.

| # | Acceptance Criterion | Priority |
|---|---|---|
| **1.1** | Enemy_State_Machine SHALL manage five states: IDLE, PATROL, CHASE, ATTACK, DEAD | **MUST** |
| **1.2** | In IDLE state, enemy SHALL stay stationary and show idle animation | **MUST** |
| **1.3** | When Player enters Aggro_Range, enemy SHALL transition IDLE/PATROL → CHASE | **MUST** |
| **1.4** | When in CHASE and Player is within Attack_Range, enemy SHALL transition → ATTACK | **MUST** |
| **1.5** | When attack completes and Player still in Aggro_Range, enemy SHALL return → CHASE | **MUST** |
| **1.6** | When HP reaches zero, enemy SHALL transition → DEAD | **MUST** |
| **1.7** | In PATROL state, enemy SHALL move to random waypoints within patrol radius | **SHOULD** |
| **1.8** | When Player exits Aggro_Range for 2+ seconds, enemy SHALL return to PATROL/IDLE | **SHOULD** |

---

### Req 2 — Pathfinding & Navigation

**User Story:** As a player, I want enemies to navigate toward me, so that combat requires movement and positioning.

> 💡 **Prototype Simplification**
>
> Use direct movement toward Player first (normalize direction × speed). Add NavigationAgent2D only if enemies get noticeably stuck on obstacles.

| # | Acceptance Criterion | Priority |
|---|---|---|
| **2.1** | In CHASE state, enemy SHALL move directly toward Player position each frame | **MUST** |
| **2.2** | Enemy movement SHALL use isometric coordinate transformation for correct visual direction | **MUST** |
| **2.3** | Enemy SHALL use NavigationAgent2D to route around obstacles | **DEFER** |
| **2.4** | Navigation path SHALL recalculate every 0.5 seconds to track Player movement | **DEFER** |

---

### Req 3 — Attack Behavior

**User Story:** As a player, I want enemies to attack me when in range, so that positioning and timing matter in combat.

| # | Acceptance Criterion | Priority |
|---|---|---|
| **3.1** | In ATTACK state, enemy SHALL execute its attack pattern | **MUST** |
| **3.2** | Melee attack SHALL check for Player overlap in attack range and deal damage | **MUST** |
| **3.3** | Each enemy type SHALL have its own attack cooldown (see Req 5–7 for values) | **MUST** |
| **3.4** | Enemy SHALL stop moving during attack animation | **MUST** |
| **3.5** | Ranged enemy SHALL spawn a projectile aimed at Player's position | **MUST** |
| **3.6** | Attacks SHALL emit a signal via EventBus for visual/audio feedback | **SHOULD** |

---

### Req 4 — Chrono Rift Integration

**User Story:** As a player, I want Chrono Rift to visibly affect enemy AI, so that time manipulation feels impactful.

| # | Acceptance Criterion | Priority |
|---|---|---|
| **4.1** | apply_slow() SHALL multiply enemy movement speed by the slow factor | **MUST** |
| **4.2** | remove_slow() SHALL restore enemy base movement speed | **MUST** |
| **4.3** | Slowed enemy sprite SHALL change to magenta/pink color | **MUST** |
| **4.4** | State transitions SHALL continue normally while slowed | **MUST** |
| **4.5** | Freeze effect SHALL pause all state transitions until unfrozen | **SHOULD** |

---

### Req 5 — Enemy Stats Reference

**User Story:** As a developer, I want clear stat definitions per enemy type so that balancing is consistent.

| Stat | SlimeBasic | EarthGolem | FireImp |
|---|---|---|---|
| HP | 30 | 120 | 50 |
| Move Speed | 60 px/s | 40 px/s | 100 px/s |
| Aggro Range | 150 px | 180 px | 200 px |
| Attack Range | 30 px | 40 px | 120 px |
| Damage | 5 | 15 | 8 (fireball) |
| Attack Cooldown | 1.5 s | 2.5 s | 2.0 s |
| Patrol Radius | 80 px | 60 px | 100 px |
| Chrono Dust Drop | 5 | 15 | 8 |
| Sprite Color | Green | Brown | Red |
| Attack Type | Melee | Melee | Ranged |
| Priority | Implement first | Implement second | Implement last |

---

### Req 6 — Visual Feedback

**User Story:** As a player, I want clear visual cues of enemy states, so that I can read the battlefield quickly.

| # | Acceptance Criterion | Priority |
|---|---|---|
| **6.1** | IDLE state SHALL show an idle color pulse animation | **MUST** |
| **6.2** | ATTACK state SHALL flash sprite red briefly | **MUST** |
| **6.3** | On taking damage, sprite SHALL flash red for 0.1 seconds | **MUST** |
| **6.4** | DEAD state SHALL play fade-out before removal from scene | **MUST** |
| **6.5** | Y-Sort ordering SHALL be maintained for correct depth rendering | **MUST** |
| **6.6** | PATROL/CHASE states SHALL indicate movement via color change | **SHOULD** |

---

### Req 7 — Loot on Death

**User Story:** As a player, I want enemies to drop loot, so that I am rewarded for defeating them.

| # | Acceptance Criterion | Priority |
|---|---|---|
| **7.1** | On DEAD state, enemy SHALL emit enemy_killed signal via EventBus with type and position | **MUST** |
| **7.2** | Loot drop amounts SHALL match values in Req 5 stats table | **MUST** |
| **7.3** | Until pickup system exists, drops SHALL print to console as placeholder | **MUST** |
| **7.4** | Spawn_System SHALL support SlimeBasic, FireImp, EarthGolem by type name | **MUST** |
| **7.5** | Spawned enemies SHALL be added to 'enemies' group on Layer 2 | **MUST** |

---

### Req 8 — Debug Support

**User Story:** As a developer, I want debug tools to tune AI behavior without guessing.

| # | Acceptance Criterion | Priority |
|---|---|---|
| **8.1** | Exported variables SHALL expose aggro range, attack range, speed, and damage in Inspector | **MUST** |
| **8.2** | State transitions SHALL log to console when debug_log = true | **SHOULD** |
| **8.3** | Debug mode SHALL draw aggro and attack range circles in editor | **SHOULD** |
| **8.4** | Debug mode SHALL show current state label above each enemy | **DEFER** |

---

## 4. Deferred — Not For This Phase

The following are intentionally excluded from Phase 7:

- Full NavigationAgent2D pathfinding — add only if direct movement fails
- Performance benchmarks (20 enemies @ 60fps) — test after all 3 types are working
- FireImp projectile — implement after SlimeBasic and EarthGolem are validated
- Full inventory/pickup system for loot — placeholder prints are sufficient now
- Win/Lose screen — Phase 8 item, but keep in mind for next playtest

---

## 5. Glossary

| Term | Definition |
|---|---|
| Aggro_Range | Detection radius — enemy starts chasing Player when Player enters this area |
| Attack_Range | Distance at which enemy can execute an attack |
| Chrono_Rift_Effect | Time manipulation applied by Player (slow/freeze) affecting enemy speed |
| Enemy_State_Machine | Component managing state transitions: IDLE → PATROL → CHASE → ATTACK → DEAD |
| EventBus | Global signal bus for decoupled communication between game systems |
| I-frames | Invincibility frames — brief window after being hit where Player cannot take damage |
| NavigationAgent2D | Godot pathfinding component; deferred until direct movement proves insufficient |
| Y-Sort | Depth ordering based on Y position for correct 2.5D isometric rendering |

---

*ChronoRift — Enemy AI Requirements v1.1 | Prototype Stage | Phase 7*
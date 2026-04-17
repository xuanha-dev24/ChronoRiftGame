# ChronoRift Game - Project Summary

## 📋 Project Overview

**Game Type:** 2.5D Isometric Adventure + Farming + Base-building  
**Engine:** Godot 4.x  
**Language:** GDScript  
**Platform:** HTML5 (Web Browser)  
**Core Mechanic:** Chrono Rift (Time Manipulation)

---

## 🎯 Development Phases Completed

### ✅ Phase 1: Planning & Setup
- Project structure created
- Autoloads configured (EventBus, GameManager, DataManager)
- Input Map configured (WASD, attack, chrono_rift, inventory, interact)
- Display settings for pixel art (Nearest filter)
- .gitignore for Godot 4.x

### ✅ Phase 2: POC (Proof of Concept)
**Goal:** Validate 3 core mechanics

**Completed:**
- ✅ Player di chuyển isometric 8 hướng với Y-Sort
- ✅ Slime enemy với HP, take damage, death
- ✅ Chrono Rift SLOW mode (làm chậm enemies trong vùng AoE)

**Files Created:**
- `scripts/player/player_controller_poc.gd`
- `scripts/enemies/slime_basic_poc.gd`
- `scripts/systems/chrono_rift_system_poc.gd`
- `scripts/world/poc_world.gd`
- `scenes/world/POC_World.tscn`

**POC Validated:** ✅ Tech stack works!

---

### ✅ Phase 3: Prototype - Animations
**Goal:** Add player animations

**Completed:**
- ✅ AnimationController với 3 animations:
  - **Idle**: Color pulse (xanh lá ↔ vàng-xanh)
  - **Walk**: Color change (cyan ↔ xanh dương) + bounce
  - **Attack**: Flash red + scale up
- ✅ Di chuyển mượt với acceleration/friction
- ✅ Đổi hướng không giật

**Files Created:**
- `scripts/player/player_controller_prototype.gd`
- `scripts/player/player_animation_controller.gd`

---

### ✅ Phase 4: Prototype - State Machine
**Goal:** Clean state management

**Completed:**
- ✅ PlayerStateMachine với 4 states:
  - IDLE, WALK, ATTACK, DEAD
- ✅ Clean transitions
- ✅ Debug output cho state changes

**Files Created:**
- `scripts/player/player_state_machine.gd`

---

### ✅ Phase 5: Prototype - Polish & Feel
**Goal:** Make game "juicy"

**Completed:**
- ✅ Smooth camera follow với look-ahead
- ✅ Screen shake system (attack + chrono rift)
- ✅ Hit particle effects
- ✅ EffectManager quản lý effects

**Files Created:**
- `scripts/camera/smooth_camera.gd`
- `scripts/effects/effect_manager.gd`
- `scripts/effects/hit_effect.gd`
- `scenes/effects/HitEffect.tscn`

---

### ✅ Phase 6: Prototype - Map & World
**Goal:** Better map with variety

**Completed:**
- ✅ Tileset với shading (gradient)
- ✅ Map 30x30 với terrain variety
- ✅ 10 decorations (trees, rocks, bushes)
- ✅ Y-Sort testing với nhiều objects

**Files Updated:**
- `scripts/world/tileset_generator.gd` (improved shading)
- `scripts/world/prototype_world.gd` (30x30 map, more decorations)

---

### ✅ Phase 7: Enemy AI System
**Goal:** Intelligent enemy behaviors  
**Status:** MVP Complete (20/27 tasks, 74%)  
**Spec:** `.kiro/specs/enemy-ai-system/`

**Completed:**
- ✅ 5-state AI system (Idle, Patrol, Chase, Attack, Dead)
- ✅ 2 enemy types implemented:
  - **SlimeBasic:** Melee enemy với basic AI
  - **EarthGolem:** Tanky melee enemy
- ✅ Player combat system với hit detection
- ✅ Chrono Rift integration (enemies affected by time manipulation)
- ✅ Hit effects và death animations
- ✅ Enemy stats loaded từ enemies.json

**Files Created:**
- `scripts/enemies/enemy_state_machine.gd`
- `scripts/enemies/enemy_state.gd`
- `scripts/enemies/enemy_states/` (Idle, Patrol, Chase, Attack, Dead states)
- `scripts/enemies/slime_basic.gd`
- `scripts/enemies/earth_golem.gd`
- `scenes/enemies/SlimeBasic.tscn`
- `scenes/enemies/EarthGolem.tscn`

**Deferred:**
- FireImp (ranged enemy) - Phase 5
- Polish & Debug - Phase 7

---

### ✅ Phase 9: Loot & Progression System
**Goal:** Item drops, pickup, and inventory  
**Status:** MVP Complete (37/37 required tasks, 100%)  
**Spec:** `.kiro/specs/loot-and-progression/`

**Completed:**
- ✅ **LootSystem** (autoload): Spawns items on enemy death với drop tables
- ✅ **PickupItem**: Auto/manual pickup, idle animation, despawn timer (60s)
- ✅ **Player_Inventory** (autoload): 20 slots, item stacking by ID
- ✅ **Inventory_UI**: 6-column grid, centered (CenterContainer + CanvasLayer)
- ✅ **EffectManager** (autoload): Pickup và hit effect spawning
- ✅ **PickupEffect**: Yellow particle burst on item pickup
- ✅ **Data files**: items.json (4 items), enemies.json (loot tables)

**Features:**
- Items drop from enemies với configurable drop rates
- Auto pickup on player contact
- Yellow particle burst effect on pickup
- Inventory UI always centered, follows camera
- Item stacking (multiple same items → single slot)
- Hover tooltips showing item info
- Toggle inventory với I/Tab key

**Files Created:**
- `scripts/systems/loot_system.gd` (autoload)
- `scripts/items/pickup_item.gd`
- `scripts/effects/pickup_effect.gd`
- `scripts/ui/inventory_ui.gd` (enhanced)
- `scripts/player/player_inventory.gd` (autoload)
- `scenes/items/PickupItem.tscn`
- `scenes/effects/PickUpEffect.tscn`
- `scenes/ui/Inventory_UI.tscn`
- `data/items.json` (chrono_dust, health_potion, mana_potion, iron_ore)
- `.kiro/docs/loot-progression/` (6 setup guides)

**Deferred:**
- Property-based tests (optional)
- Item usage system (future spec)
- Rarity system (future spec)

---

### ✅ Phase 10: HUD & Player Stats Display System
**Goal:** Comprehensive HUD với HP, Mana, Resources, Hotbar, Chrono Rift indicator  
**Status:** MVP Complete (16/16 main tasks, 100%)  
**Spec:** `.kiro/specs/hud-player-stats/`

**Completed:**
- ✅ **EventBus signals** (Task 1): 5 new signals added
- ✅ **ResourceManager autoload** (Task 1): Tracks 5 resources
- ✅ **HUD scene structure** (Task 2): StatsPanel, Hotbar, InfoPanel
- ✅ **HPBar component** (Task 3): Color-coded health bar
- ✅ **ManaBar component** (Task 4): Cyan mana bar with empty state
- ✅ **ChronoRiftIndicator** (Task 5): Cooldown timer + pulse animation
- ✅ **Hotbar component** (Task 6): 5 slots with key bindings
- ✅ **InventoryCounter** (Task 7): Color-coded inventory display
- ✅ **ResourceDisplay** (Task 8): 5 resources with color-coded icons
- ✅ **HUD controller** (Task 10): Signal connections + component updates
- ✅ **player_stats integration** (Task 11): Mana signal emissions
- ✅ **chrono_rift_system integration** (Task 12): Cooldown signals
- ✅ **Game scene integration** (Task 13): HUD added to Prototype_World
- ✅ **Window resize handling** (Task 14): Responsive positioning
- ✅ **Visual polish** (Task 15): Pixel art style, consistent colors
- ✅ **End-to-end testing** (Task 16): Manual gameplay testing complete

**Files Created:**
- `scripts/autoloads/resource_manager.gd` (autoload)
- `scenes/ui/components/HPBar.tscn`, `scripts/ui/hp_bar.gd`
- `scenes/ui/components/ManaBar.tscn`, `scripts/ui/mana_bar.gd`
- `scenes/ui/components/ChronoRiftIndicator.tscn`, `scripts/ui/chrono_rift_indicator.gd`
- `scenes/ui/components/Hotbar.tscn`, `scripts/ui/hotbar.gd`
- `scenes/ui/components/InventoryCounter.tscn`, `scripts/ui/inventory_counter.gd`
- `scenes/ui/components/ResourceDisplay.tscn`, `scripts/ui/resource_display.gd`
- `scripts/ui/hud.gd` (complete controller with all signal connections)
- `scenes/ui/HUD.tscn` (updated with all components)

**Testing:**
- ✅ All manual tests passed
- ✅ HP bar updates during combat
- ✅ Mana bar updates during ability usage
- ✅ Chrono Rift cooldown and ready state working
- ✅ Hotbar item assignment functional
- ✅ Inventory counter color warnings working
- ✅ Resource display updates correctly
- ✅ Window resize handling verified

**Deferred:**
- Optional unit tests (marked with `*` in tasks.md)

---

### ✅ Phase 11: Resource Gathering & Farming System
**Goal:** Harvestable objects (trees, rocks, bushes) for resource gathering  
**Status:** MVP Complete (13/13 main tasks, 100%)  
**Spec:** `.kiro/specs/resource-gathering-farming/`

**Completed:**
- ✅ **HarvestableObject state machine**: 4 states (NORMAL, INTERACTABLE, GATHERING, DEPLETED)
- ✅ **3 harvestable object types**:
  - Tree → Wood (brown ColorRect, 1-3 wood per harvest)
  - Rock → Stone (gray ColorRect, 1-3 stone per harvest)
  - Bush → Meat (green ColorRect, 1-3 meat per harvest)
- ✅ **Gathering mechanics**:
  - Player detection (50px range)
  - Interaction indicator (white bar above object)
  - Progress bar (fills over 1-3 seconds)
  - Cancellation on player exit
  - Random gather time (1-3s) and respawn time (30-60s)
- ✅ **Resource integration**:
  - Adds resources to ResourceManager
  - Emits EventBus.resource_changed signal
  - Validates resource types (wood, stone, meat)
- ✅ **Respawn system**:
  - Objects become depleted after harvest (50% opacity, gray color)
  - Respawn after 30-60 seconds
  - Re-randomize timings on respawn
  - Transition to INTERACTABLE if player still in range
- ✅ **HarvestableObjectSpawner**:
  - Spawns minimum 5 of each type (15+ total objects)
  - Position validation (80px minimum spacing)
  - Map bounds checking (50px margin from edges)
  - Fallback position if no valid spot found
  - Adds objects to YSortRoot for proper layering
- ✅ **Visual feedback**:
  - Color changes: normal → interactable → depleted
  - Interaction indicator (visible only when interactable)
  - Progress bar with fill animation
  - Collision disabled when depleted
- ✅ **Integration**:
  - Works with ResourceManager (tracks wood, stone, meat)
  - Uses EventBus for resource_changed signals
  - Responds to "interact" input action (E key)
  - Player must be in "player" group
  - Objects added to YSortRoot for proper rendering order

**Features:**
- Player approaches object → color brightens, indicator appears
- Press E to gather → progress bar fills smoothly
- Complete gathering → receive 1-3 resources, object becomes depleted
- Wait 30-60s → object respawns with new random timings
- 15+ objects spawn on map with proper spacing
- Objects don't overlap with each other (80px spacing)

**Files Created:**
- `scripts/world/harvestable_object.gd` (250 lines, complete state machine)
- `scripts/world/harvestable_object_spawner.gd` (95 lines, spawning logic)
- `scenes/world/harvestable_objects/Tree.tscn` (Area2D + ColorRect + indicators)
- `scenes/world/harvestable_objects/Rock.tscn` (Area2D + ColorRect + indicators)
- `scenes/world/harvestable_objects/Bush.tscn` (Area2D + ColorRect + indicators)
- `tests/test_harvestable_object_state_machine.gd` (15 unit tests)
- `tests/test_harvestable_object_visual_state.gd` (8 unit tests)
- `tests/test_harvestable_object_cancel_gathering.gd` (8 unit tests)
- `tests/test_harvestable_object_resource_integration.gd` (14 unit tests)

**Testing:**
- ✅ Manual testing complete (all mechanics verified)
- ✅ State transitions working correctly
- ✅ Resource integration verified
- ✅ Respawn system functional
- ✅ Spawner creates proper distribution
- ✅ 45 unit tests created (requires GUT addon to run)

**Deferred:**
- Optional unit tests (marked with `*` in tasks.md)
- Tool requirements (future enhancement)
- Gathering animations (future enhancement)
- Sound effects (future enhancement)
- Particle effects (future enhancement)

---

## 📁 Project Structure

```
ChronoRiftGame/
├── .kiro/
│   ├── docs/
│   │   ├── PROJECT_SETUP_GUIDE.md
│   │   ├── POC_INSTRUCTIONS.md
│   │   ├── PROTOTYPE_INSTRUCTIONS.md
│   │   ├── PROTOTYPE_PHASE2_INSTRUCTIONS.md
│   │   ├── PROTOTYPE_PHASE3_INSTRUCTIONS.md
│   │   ├── PROTOTYPE_PHASE4_INSTRUCTIONS.md
│   │   ├── PROTOTYPE_PHASE5_INSTRUCTIONS.md
│   │   ├── enemy-ai/
│   │   │   └── (Enemy AI documentation)
│   │   ├── loot-progression/
│   │   │   ├── QUICK_START.md
│   │   │   ├── TESTING_GUIDE.md
│   │   │   ├── PICKUP_ITEM_SETUP.md
│   │   │   ├── PICKUP_EFFECT_SETUP.md
│   │   │   ├── INVENTORY_UI_SETUP.md
│   │   │   └── CENTER_INVENTORY_GUIDE.md
│   │   └── prototype/
│   └── specs/
│       ├── enemy-ai-system/
│       │   ├── requirements.md
│       │   ├── design.md
│       │   ├── tasks.md
│       │   └── COMPLETION_SUMMARY.md
│       └── loot-and-progression/
│           ├── requirements.md
│           ├── design.md
│           ├── tasks.md
│           ├── .config.kiro
│           └── COMPLETION_SUMMARY.md
├── scripts/
│   ├── player/
│   │   ├── player_controller_poc.gd
│   │   ├── player_controller_prototype.gd
│   │   ├── player_stats.gd
│   │   ├── player_inventory.gd (autoload)
│   │   ├── player_animation_controller.gd
│   │   └── player_state_machine.gd
│   ├── enemies/
│   │   ├── base_enemy.gd
│   │   ├── slime_basic_poc.gd
│   │   ├── slime_basic.gd
│   │   ├── earth_golem.gd
│   │   ├── enemy_state_machine.gd
│   │   ├── enemy_state.gd
│   │   └── enemy_states/
│   │       ├── idle_state.gd
│   │       ├── patrol_state.gd
│   │       ├── chase_state.gd
│   │       ├── attack_state.gd
│   │       └── dead_state.gd
│   ├── items/
│   │   └── pickup_item.gd
│   ├── systems/
│   │   ├── chrono_rift_system_poc.gd
│   │   ├── loot_system.gd (autoload)
│   │   ├── time_echo_system.gd
│   │   ├── element_system.gd
│   │   ├── farming_system.gd
│   │   └── save_system.gd
│   ├── world/
│   │   ├── poc_world.gd
│   │   ├── prototype_world.gd
│   │   ├── tileset_generator.gd
│   │   ├── world_manager.gd
│   │   └── biome_manager.gd
│   ├── camera/
│   │   └── smooth_camera.gd
│   ├── effects/
│   │   ├── effect_manager.gd (autoload)
│   │   ├── hit_effect.gd
│   │   └── pickup_effect.gd
│   └── ui/
│       ├── hud.gd
│       └── inventory_ui.gd
├── scenes/
│   ├── world/
│   │   ├── POC_World.tscn
│   │   └── Prototype_World.tscn
│   ├── enemies/
│   │   ├── SlimeBasic.tscn
│   │   └── EarthGolem.tscn
│   ├── items/
│   │   └── PickupItem.tscn
│   ├── effects/
│   │   ├── HitEffect.tscn
│   │   └── PickUpEffect.tscn
│   ├── ui/
│   │   ├── HUD.tscn
│   │   └── Inventory_UI.tscn
│   └── player/
│       └── player.tscn
├── autoloads/
│   ├── EventBus.gd
│   ├── GameManager.gd
│   └── DataManager.gd
├── data/
│   ├── items.json (4 items)
│   ├── enemies.json (with loot tables)
│   ├── elements.json
│   └── biomes.json
├── assets/
│   └── (sprites, audio folders)
├── project.godot
└── .gitignore
```

---

## 🎮 Core Systems Implemented

### 1. Player System
- **Movement:** 8-directional isometric với acceleration/friction
- **Combat:** Attack với cooldown, hit detection
- **Animations:** Idle, Walk, Attack với color changes
- **State Machine:** IDLE, WALK, ATTACK, DEAD
- **Inventory:** 20-slot inventory với stacking, toggle I/Tab ✅

### 2. Enemy System
- **SlimeBasic:** HP, take damage, death, slow effect, AI states
- **EarthGolem:** Tanky enemy với AI states
- **AI States:** Idle, Patrol, Chase, Attack, Dead ✅
- **Groups:** "enemies" group cho detection
- **Collision:** Layer 2 cho enemies
- **Loot Drops:** Items spawn on death với drop tables ✅

### 3. Chrono Rift System
- **SLOW Mode:** Làm chậm enemies trong radius 80px
- **Visual:** Cyan circle hiện khi active
- **Cooldown:** 5 giây
- **Duration:** 3 giây
- **Enemy Integration:** Enemies affected by time manipulation ✅

### 4. Camera System
- **Smooth Follow:** Lerp với follow_speed = 5.0
- **Look-ahead:** Camera nhìn trước hướng di chuyển
- **Screen Shake:** Shake khi attack/rift

### 5. Effects System
- **Hit Particles:** CPUParticles2D spawn khi hit enemy
- **Pickup Particles:** Yellow burst khi nhặt item ✅
- **Screen Shake:** Quản lý bởi EffectManager
- **Event-driven:** Dùng EventBus signals

### 6. Loot System ✅
- **LootSystem (autoload):** Spawns items on enemy death
- **Drop Tables:** Configurable chance/quantity per enemy type
- **PickupItem:** Auto/manual pickup, idle animation, despawn timer
- **Circular Offset:** Multiple items spawn in circle pattern
- **Max Pickups:** 50 active items limit

### 7. Inventory System ✅
- **Player_Inventory (autoload):** 20 slots, item stacking by ID
- **Inventory_UI:** 6-column grid, centered (CenterContainer + CanvasLayer)
- **Features:** Add/remove items, tooltips, I/Tab toggle
- **UI Architecture:** Always centered, follows camera

### 8. World System
- **Tileset:** 4 tile types (Grass, Dirt, Stone, Water) với shading
- **Map:** 30x30 với terrain variety
- **Decorations:** Trees, rocks, bushes với Y-Sort
- **Y-Sort:** Hoạt động đúng với decorations

---

## 🔧 Technical Details

### Input Map
- `move_up/down/left/right`: WASD + Arrow keys
- `attack`: Space + Left Mouse
- `use_chrono_rift`: Q (hoặc X)
- `open_inventory`: I + Tab
- `interact`: E

### Autoloads (Thứ tự quan trọng)
1. **EventBus** - Global signal bus
2. **GameManager** - Game state management
3. **DataManager** - JSON data loader
4. **LootSystem** - Loot drop system ✅
5. **EffectManager** - Effect spawning và management ✅
6. **Player_Inventory** - Player inventory (20 slots) ✅
7. **ResourceManager** - Resource tracking (fire_shard, gold, stone, wood, meat) ✅

### Collision Layers
- **Layer 1:** Player
- **Layer 2:** Enemies

### Key Constants
- Player speed: 150
- Player acceleration: 2500
- Player friction: 1800
- Attack cooldown: 0.6s
- Chrono Rift cooldown: 5s
- Chrono Rift duration: 3s
- Slow factor: 0.2 (20% speed)

---

## 🚀 Next Steps (Roadmap)

### ✅ Phase 7: Enemy AI (Completed)
- ✅ Enemy State Machine (Idle, Patrol, Chase, Attack, Dead)
- ✅ 2 enemy types (SlimeBasic, EarthGolem)
- ⏸️ Deferred: FireImp (ranged enemy), Polish & Debug

### Phase 8: Chrono Rift Expansion (Future Priority)
- **REWIND mode:** Quay ngược 3 giây
- **ACCELERATE mode:** Tăng tốc player
- Polish visual effects
- Better VFX cho time manipulation

### ✅ Phase 9: Loot & Progression (Completed)
- ✅ Enemy drops (chrono dust, health potion, mana potion, iron_ore)
- ✅ Pickup system (auto/manual)
- ✅ Inventory UI (20 slots, stacking, tooltips)
- ⏸️ Deferred: Item usage, Rarity system

### 🔄 Phase 10: HUD & Player Stats Display (IN PROGRESS - 19% Complete)
- ✅ EventBus signals (5 new signals)
- ✅ ResourceManager autoload (5 resources)
- ✅ HUD scene structure (StatsPanel, Hotbar, InfoPanel)
- ✅ HPBar component (color-coded health bar)
- ✅ Inventory counter (integrated into HUD)
- ⏸️ ManaBar component (Task 4)
- ⏸️ ChronoRiftIndicator component (Task 5)
- ⏸️ Hotbar component (Task 6)
- ⏸️ ResourceDisplay component (Task 8)
- ⏸️ Integration & testing (Tasks 9-16)

### Phase 11: Base Building (Future)
- Build structures (walls, turrets, crafting stations)
- Resource management
- Defend base from waves

### Phase 12: MVP Preparation
- Complete HUD với all stats
- Death screen + respawn
- Victory condition (survive 5 waves)
- Save/Load system
- Sound effects

---

## 🎨 Art Style

**Current:** Placeholder ColorRects với màu sắc rõ ràng
- Player: Cyan/Blue khi walk, Green khi idle, Red khi attack
- Enemies: Green (normal), Pink (slowed), Red (hit)
- Tiles: Gradient shading cho depth

**Future:** Import tileset isometric thật (Kenney hoặc custom)

---

## 📝 Important Notes

### Workflow
- **Planning → POC → Prototype → MVP**
- POC validated tech stack ✅
- Prototype đang refine mechanics và polish

### Code Style
- Typed GDScript (var hp: int = 100)
- Comments bằng tiếng Anh
- Signal-driven architecture (EventBus)
- Modular systems (easy to expand)

### Testing
- F6 để chạy scene hiện tại
- Output console để debug
- State transitions được log ra console

---

## 🐛 Known Issues / Limitations

- Chưa có proper sprites (dùng ColorRect)
- Chưa có sound effects
- Enemy AI: FireImp (ranged) chưa implement
- Chỉ có SLOW mode cho Chrono Rift (REWIND, ACCELERATE chưa có)
- Item usage system chưa có (potions không dùng được)
- Rarity system chưa implement
- Enemies occasionally clip into player during chase
- **HUD system incomplete:**
  - ✅ HPBar working
  - ✅ Inventory counter working
  - ⏸️ ManaBar chưa có
  - ⏸️ ChronoRiftIndicator chưa có
  - ⏸️ Hotbar chưa có
  - ⏸️ ResourceDisplay chưa có

---

## 💡 Design Decisions

### Tại sao dùng ColorRect thay vì sprites?
- Nhanh để prototype
- Dễ thay đổi màu sắc
- Không cần asset thật
- Focus vào mechanics trước

### Tại sao dùng EventBus?
- Decoupling systems
- Dễ expand
- Clean architecture
- Easy debugging

### Tại sao POC trước Prototype?
- Validate tech stack sớm
- Tránh waste time nếu tech không work
- Iterative development

---

## 🎯 Success Criteria

### POC Success ✅
- Player movement works
- Combat works
- Chrono Rift works

### Prototype Success (Current)
- Animations smooth ✅
- State machine clean ✅
- Camera feels good ✅
- Effects juicy ✅
- Map has variety ✅
- Enemy AI working ✅
- Loot system functional ✅
- Inventory system complete ✅

### MVP Success (Future)
- Playable từ đầu đến cuối
- Win/lose conditions
- Save/load works
- Fun to play!

---

## 📚 Documentation

Tất cả docs nằm trong `.kiro/docs/`:
- Setup guides
- Phase instructions
- Troubleshooting
- Checklists

**Enemy AI Documentation:**
- `.kiro/specs/enemy-ai-system/` - Full spec với requirements, design, tasks
- `.kiro/docs/enemy-ai/` - Setup và implementation guides

**Loot & Progression Documentation:**
- `.kiro/specs/loot-and-progression/` - Full spec với requirements, design, tasks
- `.kiro/docs/loot-progression/` - 6 setup guides:
  - QUICK_START.md
  - TESTING_GUIDE.md
  - PICKUP_ITEM_SETUP.md
  - PICKUP_EFFECT_SETUP.md
  - INVENTORY_UI_SETUP.md
  - CENTER_INVENTORY_GUIDE.md

**HUD & Player Stats Documentation:**
- `.kiro/specs/hud-player-stats/` - Full spec với requirements, design, tasks
- `.kiro/docs/guide/hud-player-stats/` - 4 implementation guides:
  - README.md (overview, quick start, progress tracking)
  - TASK_01_EVENTBUS_RESOURCEMANAGER.md
  - TASK_02_HUD_SCENE_STRUCTURE.md
  - TASK_03_HPBAR_COMPONENT.md

---

## 🤝 Collaboration Notes

**User Preferences:**
- Tiếng Việt cho communication
- Tiếng Anh cho code/comments
- Làm từng phase, không skip
- Test kỹ trước khi next phase
- Placeholder OK, focus mechanics

**Agent Approach:**
- Tạo instructions chi tiết
- Code sẵn, user setup trong Godot
- Fix issues nhanh
- Explain decisions
- Iterative improvements

---

**Last Updated:** Phase 11 (Resource Gathering & Farming System) + Phase 10 (HUD System) Complete ✅  
**Completed Phases:** Enemy AI (74%), Loot System (100%), HUD System (100%), Resource Gathering (100%)  
**Next Phase:** Phase 8 (Chrono Rift Expansion) or new feature spec  
**Status:** Prototype đang phát triển tốt! 4 major systems hoạt động! 🚀

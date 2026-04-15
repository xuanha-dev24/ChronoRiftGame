# ChronoRiftGame - Cấu Trúc Dự Án

## Tổng Quan
ChronoRiftGame là một game roguelike 2D được phát triển bằng Godot Engine, có cơ chế thao túng thời gian và hệ thống nguyên tố.

---

## Cấu Trúc Thư Mục

```
ChronoRiftGame/
│
├── .git/                           # Git version control repository
├── .godot/                         # Godot engine cache và metadata (auto-generated)
│   ├── editor/                     # Editor settings và cache
│   ├── imported/                   # Imported assets cache
│   └── shader_cache/               # Compiled shader cache
│
├── .kiro/                          # Kiro AI assistant configuration và documentation
│   ├── docs/                       # Project documentation
│   │   ├── enemy-ai/               # Enemy AI system documentation
│   │   ├── loot-progression/       # Loot và progression system docs
│   │   └── prototype/              # Prototype phase documentation
│   └── specs/                      # Feature specifications
│       ├── enemy-ai-system/        # Enemy AI implementation specs
│       └── loot-and-progression/   # Loot system implementation specs
│
├── assets/                         # Game assets (sprites, audio, tilesets)
│   ├── audio/                      # Sound effects và music
│   │   ├── music/                  # Background music files
│   │   └── sfx/                    # Sound effects
│   ├── sprites/                    # 2D sprite assets
│   │   ├── enemies/                # Enemy sprites
│   │   ├── player/                 # Player character sprites
│   │   ├── tiles/                  # Tile sprites cho world
│   │   └── ui/                     # UI element sprites
│   └── tilesets/                   # Tileset definitions
│
├── autoloads/                      # Godot autoload singletons (global scripts)
│   ├── DataManager.gd              # Quản lý game data (enemies, items, biomes)
│   ├── EventBus.gd                 # Global event system
│   ├── GameManager.gd              # Core game state management
│   ├── EffectManager.gd            # Effect spawning và management (pickup, hit effects)
│   ├── LootSystem.gd               # Loot drop system (spawns items on enemy death)
│   └── Player_Inventory.gd         # Player inventory management (20 slots, stacking)
│
├── data/                           # JSON data files cho game configuration
│   ├── biomes.json                 # Biome definitions và properties
│   ├── elements.json               # Element system data
│   ├── enemies.json                # Enemy stats, behaviors, và loot drop tables
│   └── items.json                  # Item definitions (chrono_dust, health_potion, mana_potion, iron_ore)
│
├── scenes/                         # Godot scene files (.tscn)
│   ├── effects/                    # Visual effects scenes
│   │   ├── HitEffect.tscn          # Hit impact effect
│   │   └── PickUpEffect.tscn       # Pickup item effect (yellow particles)
│   ├── enemies/                    # Enemy character scenes
│   │   ├── EarthGolem.tscn         # Earth element golem enemy
│   │   └── SlimeBasic.tscn         # Basic slime enemy
│   ├── items/                      # Item và pickup scenes
│   │   └── PickupItem.tscn         # Collectible item scene (ColorRect + Label + Area2D)
│   ├── player/                     # Player character scenes
│   │   └── player.tscn             # Main player scene
│   ├── systems/                    # Game system scenes
│   ├── ui/                         # User interface scenes
│   │   ├── HUD.tscn                # Heads-up display
│   │   └── Inventory_UI.tscn       # Inventory UI (6-column grid, centered, CanvasLayer)
│   └── world/                      # World và level scenes
│       ├── poc_world.tscn          # Proof of concept world
│       └── Prototype_World.tscn    # Prototype world scene
│
├── scripts/                        # GDScript source files
│   ├── camera/                     # Camera control scripts
│   │   └── smooth_camera.gd        # Smooth camera follow system
│   ├── effects/                    # Visual effect scripts
│   │   ├── effect_manager.gd       # Effect spawning và management (autoload)
│   │   ├── hit_effect.gd           # Hit effect behavior
│   │   └── pickup_effect.gd        # Pickup effect behavior (yellow particle burst)
│   ├── enemies/                    # Enemy AI và behavior scripts
│   │   ├── enemy_states/           # Enemy state machine states
│   │   ├── states/                 # Additional state implementations
│   │   ├── base_enemy.gd           # Base enemy class
│   │   ├── enemy_state_machine.gd  # Enemy AI state machine
│   │   ├── enemy_state.gd          # Base state class
│   │   ├── earth_golem.gd          # Earth golem specific logic
│   │   └── slime_basic.gd          # Slime enemy logic
│   ├── items/                      # Item và pickup scripts
│   │   └── pickup_item.gd          # Pickup item behavior (auto/manual, animation, despawn)
│   ├── player/                     # Player control và systems
│   │   ├── player_controller.gd    # Main player input controller
│   │   ├── player_animation_controller.gd  # Animation state management
│   │   ├── player_inventory.gd     # Inventory system (autoload, 20 slots, stacking)
│   │   ├── player_state_machine.gd # Player state machine
│   │   └── player_stats.gd         # Player stats và progression
│   ├── systems/                    # Core game systems
│   │   ├── chrono_rift_system.gd   # Time manipulation mechanics
│   │   ├── element_system.gd       # Elemental interaction system
│   │   ├── farming_system.gd       # Resource farming mechanics
│   │   ├── loot_system.gd          # Loot generation và drops (autoload, drop tables)
│   │   ├── save_system.gd          # Save/load functionality
│   │   └── time_echo_system.gd     # Time echo replay system
│   ├── ui/                         # UI control scripts
│   │   ├── hud.gd                  # HUD display logic
│   │   └── inventory_ui.gd         # Inventory UI controller (grid, tooltips, I/Tab toggle)
│   └── world/                      # World generation và management
│       ├── biome_manager.gd        # Biome system management
│       ├── tileset_generator.gd    # Procedural tileset generation
│       └── world_manager.gd        # World state management
│
├── tests/                          # Unit tests và integration tests
│   └── test_data_manager_loot.gd   # DataManager loot system tests
│
├── .gitignore                      # Git ignore rules
├── export_presets.cfg              # Godot export configuration
├── GAME_PLAN.md                    # Game design document
├── icon.svg                        # Project icon
├── project.godot                   # Godot project configuration file
└── README.md                       # Project readme
```

---

## Mô Tả Chi Tiết Các Thư Mục Chính

### `/autoloads/` - Global Singletons
Chứa các script được load tự động khi game khởi động, có thể truy cập từ bất kỳ đâu trong game:
- **DataManager**: Quản lý và load data từ JSON files
- **EventBus**: Hệ thống event global cho communication giữa các nodes
- **GameManager**: Quản lý game state, pause, transitions
- **EffectManager**: Spawn và quản lý visual effects (pickup, hit)
- **LootSystem**: Spawn items khi enemies chết, quản lý drop tables
- **Player_Inventory**: Quản lý inventory của player (20 slots, stacking)

### `/data/` - Game Configuration
Chứa các file JSON định nghĩa game content:
- **biomes.json**: Các biome khác nhau (Forest, Desert, Ice, etc.)
- **elements.json**: Hệ thống nguyên tố (Fire, Water, Earth, Air)
- **enemies.json**: Stats, behaviors, và loot drop tables của enemies
- **items.json**: Item definitions (chrono_dust, health_potion, mana_potion, iron_ore)

### `/scenes/` - Godot Scenes
Chứa các scene files (.tscn) - prefabs của Godot:
- **effects/**: Visual effects như hit impacts, explosions
- **enemies/**: Enemy character scenes với sprites và collision
- **items/**: Pickup items và collectibles
- **player/**: Player character scene
- **ui/**: User interface elements
- **world/**: Level và world scenes

### `/scripts/` - Game Logic
Chứa tất cả GDScript source code:
- **camera/**: Camera control và follow logic
- **effects/**: Effect spawning và management
- **enemies/**: Enemy AI, state machines, behaviors
- **items/**: Item pickup và usage logic
- **player/**: Player movement, combat, inventory
- **systems/**: Core game systems (time manipulation, elements, loot)
- **ui/**: UI controllers và display logic
- **world/**: World generation, biome management

### `/assets/` - Game Assets
Chứa tất cả media files:
- **audio/**: Music và sound effects
- **sprites/**: 2D artwork cho characters, tiles, UI
- **tilesets/**: Tileset definitions cho world rendering

### `/.kiro/` - Development Documentation
Chứa documentation và specs cho development:
- **docs/**: Design documents, instructions, guides
  - **enemy-ai/**: Enemy AI system documentation
  - **loot-progression/**: Loot system setup guides (6 guides)
    - QUICK_START.md
    - TESTING_GUIDE.md
    - PICKUP_ITEM_SETUP.md
    - PICKUP_EFFECT_SETUP.md
    - INVENTORY_UI_SETUP.md
    - CENTER_INVENTORY_GUIDE.md
  - **prototype/**: Prototype phase documentation
- **specs/**: Feature specifications với requirements và tasks
  - **enemy-ai-system/**: Enemy AI spec (requirements, design, tasks, completion summary)
  - **loot-and-progression/**: Loot system spec (requirements, design, tasks, completion summary)

---

## Các File Quan Trọng

- **project.godot**: Godot project configuration, autoload settings, input mappings
- **GAME_PLAN.md**: Game design document với mechanics và features
- **README.md**: Project overview và setup instructions
- **export_presets.cfg**: Build và export settings cho các platforms

---

## Quy Ước Đặt Tên

- **Scenes**: PascalCase (VD: `Prototype_World.tscn`, `EarthGolem.tscn`)
- **Scripts**: snake_case (VD: `player_controller.gd`, `enemy_state_machine.gd`)
- **Folders**: lowercase với dashes (VD: `enemy-ai-system/`)
- **Data files**: lowercase với underscores (VD: `enemies.json`, `biomes.json`)

---

## Completed Features & Systems

### ✅ Enemy AI System (Phase 1-6)
**Status:** MVP Complete (20/27 tasks, 74%)  
**Spec:** `.kiro/specs/enemy-ai-system/`

**Implemented:**
- 5-state AI system (Idle, Patrol, Chase, Attack, Dead)
- 2 enemy types: SlimeBasic (melee), EarthGolem (melee)
- Player combat system với hit detection
- Chrono Rift integration (enemies affected by time manipulation)
- Hit effects và death animations
- Enemy stats từ enemies.json

**Deferred:**
- FireImp (ranged enemy) - Phase 5
- Polish & Debug - Phase 7

### ✅ Loot & Progression System
**Status:** MVP Complete (37/37 required tasks, 100%)  
**Spec:** `.kiro/specs/loot-and-progression/`

**Implemented:**
- **LootSystem** (autoload): Spawns items on enemy death, drop table system
- **PickupItem**: Auto/manual pickup, idle animation, despawn timer, effects
- **Player_Inventory** (autoload): 20 slots, stacking by item ID
- **Inventory_UI**: 6-column grid, centered (CenterContainer + CanvasLayer), tooltips, I/Tab toggle
- **EffectManager** (autoload): Pickup và hit effect spawning
- **Data files**: items.json (4 items), enemies.json (loot tables)

**Features:**
- Items drop from enemies với configurable drop rates
- Auto pickup on player contact
- Yellow particle burst effect on pickup
- Inventory UI always centered, follows camera
- Item stacking (multiple same items → single slot)
- Hover tooltips showing item info

**Deferred:**
- Property-based tests (optional)
- Item usage system (future spec)
- Rarity system (future spec)

---

## Game Systems Overview

### Core Systems
1. **Chrono Rift System**: Time manipulation mechanics
2. **Element System**: Elemental interactions (Fire, Water, Earth, Air)
3. **Loot System**: Item drops với drop tables, spawn on enemy death ✅
4. **Farming System**: Resource gathering mechanics
5. **Time Echo System**: Replay của player actions
6. **Inventory System**: 20-slot inventory với stacking, UI toggle (I/Tab) ✅
7. **Effect System**: Visual effects (pickup, hit) với EffectManager ✅

### Character Systems
- **Player Controller**: Input handling, movement, combat
- **Player Inventory**: 20-slot inventory với stacking, EventBus integration ✅
- **Enemy AI**: State machine-based AI với multiple behaviors (Idle, Patrol, Chase, Attack, Dead) ✅
- **Animation Controllers**: Animation state management

### World Systems
- **Biome Manager**: Biome generation và transitions
- **World Manager**: World state và persistence
- **Tileset Generator**: Procedural tileset generation

---

## Development Workflow

1. **Data Definition**: Define game content trong `/data/` JSON files
2. **Scene Creation**: Tạo scenes trong `/scenes/` với appropriate structure
3. **Script Implementation**: Implement logic trong `/scripts/`
4. **Testing**: Write tests trong `/tests/`
5. **Documentation**: Update docs trong `/.kiro/docs/`

---

## Key Technical Patterns

### UI Architecture
- **CanvasLayer**: Sử dụng cho UI elements cần follow camera (inventory, HUD)
- **CenterContainer**: Auto-centering UI panels, responsive to window resize
- **custom_minimum_size**: Fixed-size panels để prevent shifting khi content thay đổi

### Event System
- **EventBus** (autoload): Signal-based communication giữa systems
- Key signals:
  - `enemy_killed(enemy_type, position)`: Triggered khi enemy chết
  - `item_picked_up(item_id, quantity)`: Triggered khi player nhặt item
  - `spawn_effect(effect_name, position)`: Request spawn visual effect

### Autoload Pattern
- Global singletons accessible từ anywhere: `/root/AutoloadName`
- Examples: `/root/LootSystem`, `/root/Player_Inventory`, `/root/EffectManager`

### State Machine Pattern
- Enemy AI: 5 states (Idle, Patrol, Chase, Attack, Dead)
- Player: State machine cho movement và combat
- Clean separation of concerns, easy to extend

### Data-Driven Design
- JSON files cho game configuration (enemies, items, biomes)
- DataManager loads và caches data at startup
- Easy to modify game content without code changes

---

## Notes

- Godot version: 4.x
- Language: GDScript
- Architecture: Scene-based với autoload singletons
- State Management: State machine pattern cho player và enemies
- Data-driven design: JSON files cho game configuration
- Current Phase: **Prototype** (MVP features implemented)
- Development Approach: Planning → POC → Prototype → MVP
- Testing: Manual testing in Godot editor, user tests each phase

### Current Status (2026-04-15)
- ✅ Enemy AI System: 74% complete (MUST priorities done)
- ✅ Loot & Progression System: 100% complete (MVP)
- 🔄 Next: Phase 8 (Chrono Rift Expansion) or Phase 10 (Base Building)

### Known Issues
- Enemies occasionally clip into player during chase
- No sound effects yet (audio files not created)
- Inventory capacity warning not implemented
- Manual pickup mode implemented but not tested

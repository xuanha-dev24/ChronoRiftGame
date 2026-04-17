# ChronoRift Game

A 2.5D Isometric Adventure + Farming + Base-building game with Time Manipulation mechanics.

## 🎮 Game Overview

ChronoRift combines action-adventure gameplay with farming and base-building elements, featuring unique time manipulation mechanics.

### Core Features
- ⚔️ **Combat System** - Fight enemies with weapons and abilities
- 🌾 **Resource Gathering** - Harvest wood, stone, and other materials
- 🏗️ **Building System** - Construct defensive structures and facilities
- ⏰ **Time Manipulation** - Use Chrono Rift abilities to control time
- 📦 **Inventory System** - Manage items and resources
- 🎯 **Enemy AI** - Intelligent enemies with state machines

---

## 🚀 Getting Started

### Requirements
- **Godot Engine 4.6+**
- **Operating System:** Windows, Linux, or macOS

### Opening the Project
1. Download/Clone the repository
2. Open Godot Engine
3. Click "Import"
4. Navigate to `ChronoRiftGame/` folder
5. Select `project.godot`
6. Click "Import & Edit"

### Running the Game
1. Press `F5` or click "Run Project" button
2. Game will start in Prototype_World scene

---

## 🎯 Controls

### Movement
- `W` / `↑` - Move Up
- `S` / `↓` - Move Down
- `A` / `←` - Move Left
- `D` / `→` - Move Right

### Actions
- `Space` / `Left Click` / `Z` - Attack
- `E` - Interact (harvest resources)
- `I` / `Tab` - Toggle Inventory
- `Q` / `X` - Use Chrono Rift ability

### Building System
- `B` - Toggle Build Mode
- `Left Click` - Place structure
- `Right Click` / `ESC` - Cancel selection
- `X` + `Left Click` - Demolish structure

---

## 🏗️ Building System

### Available Structures

| Structure | Size | Cost | Description |
|-----------|------|------|-------------|
| **Wall** | 1x1 | 10 wood + 5 stone | Basic defensive structure |
| **Turret** | 1x1 | 15 wood + 10 stone | Automated enemy targeting |
| **Crafting Station** | 2x2 | 20 wood + 15 stone | Crafting facility |
| **Storage Chest** | 1x1 | 15 wood + 10 stone | Item storage |

### How to Build
1. Press `B` to enter Build Mode
2. Click structure button in UI
3. Move mouse to desired location
4. Green preview = valid, Red = invalid
5. Left click to place

### Demolition
- Hold `X` + Left click on structure
- Receive 50% of resources back

**See [BUILDING_SYSTEM_COMPLETE.md](BUILDING_SYSTEM_COMPLETE.md) for detailed documentation.**

---

## 📦 Resource Gathering

### Harvestable Objects

| Object | Resource | Amount | Respawn Time |
|--------|----------|--------|--------------|
| 🌳 Tree | Wood | 50 | 30-60 seconds |
| 🪨 Rock | Stone | 50 | 30-60 seconds |
| 🌿 Bush | Meat | 50 | 30-60 seconds |

### How to Harvest
1. Walk near harvestable object
2. Yellow indicator appears
3. Press `E` to start gathering
4. Wait for progress bar to complete
5. Resources added to inventory

---

## 🧪 Testing

### Unit Tests
The project includes comprehensive unit tests using GUT (Godot Unit Test) framework.

**Total Tests:** 153
**Test Coverage:**
- Building System
- Structure Placement
- Resource Management
- Combat System
- Inventory System
- Enemy AI

### Running Tests
1. Open GUT panel (bottom panel, "GUT" tab)
2. Click "Run All" button
3. View results in panel

**See [TESTING_SETUP.md](TESTING_SETUP.md) for detailed testing guide.**

---

## 📁 Project Structure

```
ChronoRiftGame/
├── addons/              # Third-party addons (GUT testing)
├── autoloads/           # Global singletons
│   ├── EventBus.gd
│   ├── GameManager.gd
│   └── DataManager.gd
├── data/                # Game data (JSON configs)
│   └── structures.json
├── scenes/              # Scene files (.tscn)
│   ├── enemies/
│   ├── items/
│   ├── player/
│   ├── structures/
│   ├── ui/
│   └── world/
├── scripts/             # GDScript files
│   ├── autoloads/
│   ├── camera/
│   ├── effects/
│   ├── enemies/
│   ├── items/
│   ├── player/
│   ├── structures/
│   ├── systems/
│   ├── ui/
│   └── world/
├── tests/               # Unit tests
│   └── unit/
├── textures/            # Game assets
└── project.godot        # Project configuration
```

---

## 🔧 Systems Overview

### Core Systems

**Building System** (`scripts/systems/building_system.gd`)
- Structure placement and validation
- Resource cost management
- Demolition with refunds
- Spatial partitioning optimization

**Resource Manager** (`scripts/autoloads/resource_manager.gd`)
- Tracks wood, stone, meat resources
- Provides add/spend/check methods
- Emits signals on resource changes

**Inventory System** (`scripts/player/player_inventory.gd`)
- Item storage and management
- Stack-based system
- UI integration

**Combat System** (`scripts/player/player_combat.gd`)
- Attack mechanics
- Damage calculation
- Hit detection

**Enemy AI** (`scripts/enemies/`)
- State machine (Idle, Patrol, Chase, Attack)
- Pathfinding
- Target selection

**Chrono Rift System** (`scripts/systems/chrono_rift_system.gd`)
- Time manipulation abilities
- Slow effect on enemies
- Cooldown management

---

## 📚 Documentation

- **[BUILDING_SYSTEM_COMPLETE.md](BUILDING_SYSTEM_COMPLETE.md)** - Complete building system guide
- **[TESTING_SETUP.md](TESTING_SETUP.md)** - Testing framework setup
- **[QUICK_TEST_GUIDE.md](QUICK_TEST_GUIDE.md)** - Quick testing reference
- **[CURRENT_STATUS.md](CURRENT_STATUS.md)** - Current implementation status
- **[TEST_ERROR_FIXES.md](TEST_ERROR_FIXES.md)** - Test error solutions

---

## 🎨 Art Style

- **Perspective:** 2.5D Isometric
- **Graphics:** Placeholder colored rectangles (ready for sprite replacement)
- **Grid Size:** 16x16 pixels
- **Map Size:** 30x30 grid (480x480 pixels)

---

## 🔮 Planned Features

### Phase 1: Core Gameplay ✅
- [x] Player movement and combat
- [x] Resource gathering
- [x] Building system
- [x] Basic enemy AI

### Phase 2: Content Expansion 🚧
- [ ] More structure types
- [ ] Crafting system
- [ ] More enemy types
- [ ] Boss battles

### Phase 3: Time Mechanics 🚧
- [x] Basic Chrono Rift ability
- [ ] Time Echo system
- [ ] Time rewind mechanics
- [ ] Temporal puzzles

### Phase 4: Polish 📋
- [ ] Save/Load system
- [ ] Settings menu
- [ ] Sound effects
- [ ] Music
- [ ] Particle effects
- [ ] Better visuals

---

## 🐛 Known Issues

### Gameplay
- Placement preview follows mouse smoothly (intentional design)
- Some test errors in console (testing error handling - expected)

### Performance
- Optimized for 100+ structures
- 60 FPS target maintained

---

## 🤝 Contributing

This is a learning/portfolio project. Contributions, suggestions, and feedback are welcome!

### Development Setup
1. Clone repository
2. Open in Godot 4.6+
3. Install GUT addon (included)
4. Run tests to verify setup

---

## 📝 Version History

### v0.1.0 - Current
- ✅ Building System complete
- ✅ Resource gathering implemented
- ✅ Basic combat system
- ✅ Enemy AI with state machines
- ✅ Inventory system
- ✅ 153 unit tests

---

## 📄 License

[Add your license here]

---

## 🙏 Credits

**Game Engine:** Godot Engine 4.6
**Testing Framework:** GUT (Godot Unit Test)
**Developer:** [Your Name]

---

## 📞 Contact

[Add your contact information]

---

**Press `B` to start building! 🏗️**

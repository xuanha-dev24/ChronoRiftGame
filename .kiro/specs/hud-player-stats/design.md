# Design Document: HUD & Player Stats Display

## Overview

The HUD & Player Stats Display system provides real-time visual feedback about player status through a screen-space UI overlay. The system extends the existing basic HUD to include comprehensive stat tracking, resource display, ability cooldowns, and quick-access item slots. The design uses event-driven architecture for efficient updates and CanvasLayer for consistent screen-space rendering.

## Architecture

### High-Level Architecture

```
HUD (CanvasLayer)
├── StatsPanel (VBoxContainer) - Top-Left
│   ├── HPBar (ProgressBar + Label)
│   ├── ManaBar (ProgressBar + Label)
│   └── ChronoRiftIndicator (Panel + Label)
├── Hotbar (HBoxContainer) - Bottom-Center
│   ├── Slot1 (Panel + TextureRect + Label)
│   ├── Slot2 (Panel + TextureRect + Label)
│   ├── Slot3 (Panel + TextureRect + Label)
│   ├── Slot4 (Panel + TextureRect + Label)
│   └── Slot5 (Panel + TextureRect + Label)
└── InfoPanel (VBoxContainer) - Top-Right
    ├── InventoryCounter (Label)
    └── ResourceDisplay (VBoxContainer)
        ├── FireShardRow (HBoxContainer)
        ├── GoldRow (HBoxContainer)
        ├── StoneRow (HBoxContainer)
        ├── WoodRow (HBoxContainer)
        └── MeatRow (HBoxContainer)
```

### Component Responsibilities

**HUD Controller (hud.gd)**
- Manages all HUD child components
- Connects to EventBus signals
- Coordinates updates across components
- Handles layout and positioning

**HPBar Component**
- Displays current/max HP as progress bar
- Shows numerical text "X/Y"
- Changes color based on HP percentage (green/yellow/red)

**ManaBar Component**
- Displays current/max mana as progress bar
- Shows numerical text "X/Y"
- Uses distinct color (cyan/blue)

**ChronoRiftIndicator Component**
- Shows cooldown timer when on cooldown
- Displays "READY" when available
- Emits visual pulse when ready

**Hotbar Component**
- 5 slots for quick item access (keys 1-5)
- Displays item icon/name and quantity
- Shows key binding for each slot
- Updates when items assigned/used

**InventoryCounter Component**
- Shows "Inventory: X/Y" format
- Color-codes when approaching capacity (orange at 90%, red at 100%)

**ResourceDisplay Component**
- Shows 5 resources with icons and quantities
- Fire Element Shard, Gold, Stone, Wood, Meat
- Compact list format with color-coded icons

## Data Models

### Player Stats Data

```gdscript
# Player stats tracked by HUD
{
	"current_hp": int,
	"max_hp": int,
	"current_mana": int,
	"max_mana": int,
	"chrono_rift_cooldown": float,
	"chrono_rift_ready": bool
}
```

### Resource Data

```gdscript
# Resources tracked by HUD
{
	"fire_shard": int,
	"gold": int,
	"stone": int,
	"wood": int,
	"meat": int
}
```

### Hotbar Data

```gdscript
# Hotbar slot structure
{
	"slot_index": int,  # 0-4
	"item_id": String,  # "" if empty
	"item_name": String,
	"quantity": int
}
```

## Data Flow

### Event-Driven Updates

**HP Updates:**
```
Player takes damage
→ EventBus.player_damaged(current_hp, max_hp)
→ HUD._on_player_damaged()
→ HPBar updates display
```

**Mana Updates:**
```
Player uses ability
→ EventBus.player_mana_changed(current_mana, max_mana)
→ HUD._on_mana_changed()
→ ManaBar updates display
```

**Chrono Rift Cooldown:**
```
Chrono Rift used
→ EventBus.chrono_rift_cooldown_started(duration)
→ HUD._on_chrono_rift_cooldown()
→ ChronoRiftIndicator starts countdown
→ Timer updates every 0.1s
→ EventBus.chrono_rift_ready()
→ ChronoRiftIndicator shows READY + pulse
```

**Inventory Updates:**
```
Item added/removed
→ Player_Inventory.inventory_updated signal
→ HUD._on_inventory_updated()
→ InventoryCounter updates count
```

**Resource Updates:**
```
Resource gained/spent
→ EventBus.resource_changed(resource_type, amount)
→ HUD._on_resource_changed()
→ ResourceDisplay updates specific resource
```

**Hotbar Updates:**
```
Item assigned to hotbar
→ EventBus.hotbar_slot_changed(slot_index, item_data)
→ HUD._on_hotbar_changed()
→ Hotbar updates specific slot
```

## UI Layout

### Screen Positioning

**Top-Left (StatsPanel):**
- Position: (10, 10)
- HP Bar: 200px wide, 30px tall
- Mana Bar: 200px wide, 30px tall
- Chrono Rift Indicator: 200px wide, 40px tall
- Vertical spacing: 5px between elements

**Bottom-Center (Hotbar):**
- Position: (screen_width/2 - 150, screen_height - 70)
- 5 slots: 50x50px each
- Horizontal spacing: 10px between slots
- Key labels: centered below each slot

**Top-Right (InfoPanel):**
- Position: (screen_width - 210, 10)
- Inventory Counter: 200px wide
- Resource Display: 200px wide, 150px tall
- Each resource row: 200px wide, 25px tall
- Vertical spacing: 3px between resources

### Visual Style

**Colors:**
- HP Bar: Green (#00FF00) → Yellow (#FFFF00) → Red (#FF0000)
- Mana Bar: Cyan (#00FFFF)
- Chrono Rift Ready: Bright Cyan (#00FFFF) with pulse
- Chrono Rift Cooldown: Gray (#808080)
- Inventory Warning: Orange (#FFA500) at 90%, Red (#FF0000) at 100%
- Resource Icons: Color-coded (Fire=Red, Gold=Yellow, Stone=Gray, Wood=Brown, Meat=Pink)

**Fonts:**
- Use pixel art font or system font with nearest-neighbor filtering
- HP/Mana labels: 16px
- Chrono Rift: 14px
- Hotbar quantities: 12px
- Resource quantities: 14px

**Backgrounds:**
- Semi-transparent dark panels (Color(0, 0, 0, 0.7))
- 2px padding inside panels
- Rounded corners (optional, if supported)

## Integration with Existing Systems

### Player Stats Integration

**Current System:**
- `scripts/player/player_stats.gd` or player controller tracks HP/mana
- Currently emits `EventBus.player_damaged` signal

**Required Changes:**
- Add `EventBus.player_mana_changed(current, max)` signal
- Add `EventBus.player_healed(current, max)` signal (optional)
- Ensure signals emit on all stat changes

### Player Inventory Integration

**Current System:**
- `Player_Inventory` autoload tracks items
- Has `inventory_updated` signal (needs verification)

**Required Changes:**
- Ensure `inventory_updated` signal emits with item count
- Add hotbar slot assignment methods if not present
- Add `get_item_count()` method

### Chrono Rift Integration

**Current System:**
- `scripts/systems/chrono_rift_system_poc.gd` handles ability
- Has cooldown timer

**Required Changes:**
- Add `EventBus.chrono_rift_cooldown_started(duration)` signal
- Add `EventBus.chrono_rift_ready()` signal
- Emit signals when ability used and when ready

### Resource System Integration

**New System Required:**
- Create `ResourceManager` autoload or extend `Player_Inventory`
- Track 5 resources: fire_shard, gold, stone, wood, meat
- Emit `EventBus.resource_changed(resource_type, new_amount)` signal
- Provide `get_resource(type)` and `add_resource(type, amount)` methods

## Component Details

### HPBar Component

**Node Structure:**
```
HPBar (Panel)
├── ProgressBar (ProgressBar)
└── Label (Label)
```

**Properties:**
- `current_hp: int`
- `max_hp: int`
- `bar_color: Color` (dynamic based on percentage)

**Methods:**
- `update_hp(current: int, max: int) -> void`
- `_get_hp_color(percentage: float) -> Color`

### ManaBar Component

**Node Structure:**
```
ManaBar (Panel)
├── ProgressBar (ProgressBar)
└── Label (Label)
```

**Properties:**
- `current_mana: int`
- `max_mana: int`

**Methods:**
- `update_mana(current: int, max: int) -> void`

### ChronoRiftIndicator Component

**Node Structure:**
```
ChronoRiftIndicator (Panel)
├── Label (Label)
└── AnimationPlayer (AnimationPlayer) - for pulse effect
```

**Properties:**
- `is_ready: bool`
- `cooldown_remaining: float`

**Methods:**
- `start_cooldown(duration: float) -> void`
- `set_ready() -> void`
- `_update_cooldown_display() -> void`
- `_play_ready_pulse() -> void`

### Hotbar Component

**Node Structure:**
```
Hotbar (HBoxContainer)
├── Slot1 (Panel)
│   ├── ItemIcon (TextureRect or ColorRect)
│   ├── QuantityLabel (Label)
│   └── KeyLabel (Label) - "1"
├── Slot2 (Panel) ...
... (5 slots total)
```

**Properties:**
- `slots: Array[HotbarSlot]` (5 elements)

**Methods:**
- `update_slot(index: int, item_id: String, quantity: int) -> void`
- `clear_slot(index: int) -> void`
- `get_slot_item(index: int) -> Dictionary`

### ResourceDisplay Component

**Node Structure:**
```
ResourceDisplay (VBoxContainer)
├── FireShardRow (HBoxContainer)
│   ├── Icon (ColorRect) - Red
│   └── Label (Label) - "Fire Shard: 0"
├── GoldRow (HBoxContainer) ...
... (5 resources total)
```

**Properties:**
- `resources: Dictionary` - {fire_shard: 0, gold: 0, stone: 0, wood: 0, meat: 0}

**Methods:**
- `update_resource(type: String, amount: int) -> void`
- `_get_resource_color(type: String) -> Color`

## Error Handling

### Null Checks
- All node references checked before access
- Graceful degradation if components missing
- Error messages logged to console

### Signal Connection Failures
- Try-catch or null checks on signal connections
- Log warnings if signals not available
- Continue functioning with available signals

### Invalid Data
- Clamp HP/mana values to 0-max range
- Handle negative resource amounts (treat as 0)
- Validate hotbar slot indices (0-4)

## Performance Considerations

### Update Frequency
- Update only on signal events (not every frame)
- Cooldown timer updates at 10 FPS (every 0.1s)
- Batch multiple resource updates if possible

### Memory Management
- Reuse existing UI nodes (no dynamic instantiation during gameplay)
- Cache node references in _ready()
- Use object pooling for temporary effects (pulse animations)

## Testing Strategy

### Unit Tests
- Test HP bar color changes at thresholds (30%, 60%)
- Test mana bar updates
- Test cooldown countdown accuracy
- Test hotbar slot updates
- Test resource display updates
- Test inventory counter color changes (90%, 100%)

### Integration Tests
- Test signal flow from Player_Stats to HUD
- Test signal flow from Player_Inventory to HUD
- Test signal flow from chrono_rift_system to HUD
- Test window resize behavior
- Test all components visible and positioned correctly

### Manual Testing
- Visual inspection of layout at different resolutions
- Test color changes during gameplay
- Test cooldown timer accuracy
- Test hotbar item assignment and usage
- Test resource gain/loss display

## Future Enhancements

### Phase 2 (Out of Scope)
- Animated HP/mana bar transitions (smooth fill/drain)
- Damage numbers floating above HP bar
- Status effect icons (buffs/debuffs)
- Minimap
- Quest tracker
- Advanced tooltips on hover

### Phase 3 (Out of Scope)
- Customizable HUD layout
- HUD scaling options
- Color-blind mode
- Accessibility options

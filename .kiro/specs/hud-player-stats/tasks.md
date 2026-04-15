# Implementation Plan: HUD & Player Stats Display

## Overview

This implementation plan creates a comprehensive HUD system for displaying player stats, resources, ability cooldowns, and quick-access item slots. The system uses event-driven architecture with EventBus signals for efficient updates and CanvasLayer for screen-space rendering. Implementation follows a bottom-up approach: signals and data systems first, then UI components, then integration.

## Tasks

- [x] 1. Set up EventBus signals and ResourceManager autoload
  - [x] 1.1 Add new signals to EventBus
    - Add `player_mana_changed(current: int, max: int)` signal
    - Add `chrono_rift_cooldown_started(duration: float)` signal
    - Add `chrono_rift_ready()` signal
    - Add `resource_changed(resource_type: String, amount: int)` signal
    - Add `hotbar_slot_changed(slot_index: int, item_data: Dictionary)` signal
    - _Requirements: 8.4, 8.5, 8.7_
  
  - [x] 1.2 Create ResourceManager autoload
    - Create `scripts/autoloads/resource_manager.gd`
    - Implement resource tracking for: fire_shard, gold, stone, wood, meat
    - Add `get_resource(type: String) -> int` method
    - Add `add_resource(type: String, amount: int) -> void` method
    - Add `set_resource(type: String, amount: int) -> void` method
    - Emit `EventBus.resource_changed` signal on resource changes
    - Register as autoload in project settings
    - _Requirements: 6.1, 6.2, 8.7_

- [x] 2. Update HUD scene structure
  - [x] 2.1 Extend existing HUD scene with new components
    - Open `scenes/ui/HUD.tscn` or create if not exists
    - Ensure root is CanvasLayer node
    - Add StatsPanel (VBoxContainer) at top-left position (10, 10)
    - Add Hotbar (HBoxContainer) at bottom-center
    - Add InfoPanel (VBoxContainer) at top-right
    - Set up anchors and margins for responsive positioning
    - _Requirements: 7.1, 7.4, 10.1, 10.3, 10.4, 10.6_

- [x] 3. Implement HPBar component
  - [x] 3.1 Create HPBar scene and script
    - Create `scenes/ui/components/HPBar.tscn` with Panel root
    - Add ProgressBar child node (200px wide, 30px tall)
    - Add Label child node for "X/Y" text display
    - Create `scripts/ui/hp_bar.gd` script
    - Implement `update_hp(current: int, max: int)` method
    - Implement `_get_hp_color(percentage: float) -> Color` method
    - Set color to green (>60%), yellow (30-60%), red (<30%)
    - Update progress bar value and label text
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6_
  
  - [ ]* 3.2 Write unit tests for HPBar
    - Test color changes at 30% and 60% thresholds
    - Test numerical display format "X/Y"
    - Test progress bar value updates
    - _Requirements: 1.1, 1.4, 1.5, 1.6_

- [ ] 4. Implement ManaBar component
  - [ ] 4.1 Create ManaBar scene and script
    - Create `scenes/ui/components/ManaBar.tscn` with Panel root
    - Add ProgressBar child node (200px wide, 30px tall)
    - Add Label child node for "X/Y" text display
    - Create `scripts/ui/mana_bar.gd` script
    - Implement `update_mana(current: int, max: int)` method
    - Set progress bar color to cyan (#00FFFF)
    - Update progress bar value and label text
    - Handle empty state (mana = 0) display
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_
  
  - [ ]* 4.2 Write unit tests for ManaBar
    - Test mana updates and display format
    - Test empty state (mana = 0) rendering
    - Test distinct color from HPBar
    - _Requirements: 2.1, 2.4, 2.5_

- [ ] 5. Implement ChronoRiftIndicator component
  - [ ] 5.1 Create ChronoRiftIndicator scene and script
    - Create `scenes/ui/components/ChronoRiftIndicator.tscn` with Panel root
    - Add Label child node for cooldown/ready text
    - Add AnimationPlayer for pulse effect
    - Create `scripts/ui/chrono_rift_indicator.gd` script
    - Implement `start_cooldown(duration: float)` method
    - Implement `set_ready()` method with pulse animation
    - Implement `_update_cooldown_display()` method (updates every 0.1s)
    - Display remaining time in seconds during cooldown
    - Display "READY" with bright cyan color when available
    - Create pulse animation in AnimationPlayer
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_
  
  - [ ]* 5.2 Write unit tests for ChronoRiftIndicator
    - Test cooldown countdown accuracy
    - Test "READY" state display
    - Test cooldown timer updates every 100ms
    - _Requirements: 3.2, 3.3, 3.4_

- [ ] 6. Implement Hotbar component
  - [ ] 6.1 Create Hotbar scene and script
    - Create `scenes/ui/components/Hotbar.tscn` with HBoxContainer root
    - Add 5 Panel child nodes (Slot1 through Slot5)
    - Each slot: 50x50px with 10px spacing
    - Add TextureRect/ColorRect for item icon in each slot
    - Add Label for quantity in each slot
    - Add Label for key binding (1-5) below each slot
    - Create `scripts/ui/hotbar.gd` script
    - Implement `update_slot(index: int, item_id: String, quantity: int)` method
    - Implement `clear_slot(index: int)` method
    - Implement `get_slot_item(index: int) -> Dictionary` method
    - Display empty slot indicator when slot is empty
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6_
  
  - [ ]* 6.2 Write unit tests for Hotbar
    - Test slot updates with item assignment
    - Test empty slot display
    - Test quantity updates
    - Test slot clearing when item depleted
    - _Requirements: 4.2, 4.3, 4.4, 4.6_

- [ ] 7. Implement InventoryCounter component
  - [ ] 7.1 Create InventoryCounter scene and script
    - Create `scenes/ui/components/InventoryCounter.tscn` with Label root
    - Create `scripts/ui/inventory_counter.gd` script
    - Implement `update_count(current: int, max: int)` method
    - Display format: "Inventory: X/Y"
    - Set color to orange when >= 90% capacity
    - Set color to red when at 100% capacity
    - Set color to white when < 90% capacity
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_
  
  - [ ]* 7.2 Write unit tests for InventoryCounter
    - Test color changes at 90% and 100% thresholds
    - Test display format "Inventory: X/Y"
    - _Requirements: 5.1, 5.3, 5.4_

- [ ] 8. Implement ResourceDisplay component
  - [ ] 8.1 Create ResourceDisplay scene and script
    - Create `scenes/ui/components/ResourceDisplay.tscn` with VBoxContainer root
    - Add 5 HBoxContainer rows (FireShardRow, GoldRow, StoneRow, WoodRow, MeatRow)
    - Each row: ColorRect icon (color-coded) + Label for name and quantity
    - Set row dimensions: 200px wide, 25px tall, 3px spacing
    - Create `scripts/ui/resource_display.gd` script
    - Implement `update_resource(type: String, amount: int)` method
    - Implement `_get_resource_color(type: String) -> Color` method
    - Color mapping: Fire=Red, Gold=Yellow, Stone=Gray, Wood=Brown, Meat=Pink
    - Display format: "Resource Name: X"
    - Show "0" when resource quantity is zero
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6_
  
  - [ ]* 8.2 Write unit tests for ResourceDisplay
    - Test resource updates for all 5 resource types
    - Test color coding for each resource
    - Test zero quantity display
    - _Requirements: 6.1, 6.2, 6.5_

- [ ] 9. Checkpoint - Verify all UI components render correctly
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 10. Update HUD controller script
  - [ ] 10.1 Create or update hud.gd controller
    - Create/update `scripts/ui/hud.gd` attached to HUD CanvasLayer
    - Cache references to all child components in `_ready()`
    - Add null checks for all component references
    - Implement error logging for missing components
    - _Requirements: 7.1, 7.2, 7.4_
  
  - [ ] 10.2 Connect EventBus signals to HUD controller
    - Connect `EventBus.player_damaged` to `_on_player_damaged(current, max)`
    - Connect `EventBus.player_mana_changed` to `_on_mana_changed(current, max)`
    - Connect `EventBus.chrono_rift_cooldown_started` to `_on_chrono_rift_cooldown(duration)`
    - Connect `EventBus.chrono_rift_ready` to `_on_chrono_rift_ready()`
    - Connect `EventBus.resource_changed` to `_on_resource_changed(type, amount)`
    - Connect `EventBus.hotbar_slot_changed` to `_on_hotbar_changed(slot_index, item_data)`
    - Connect `Player_Inventory.inventory_updated` to `_on_inventory_updated()`
    - Add error handling for signal connection failures
    - _Requirements: 8.1, 8.2, 8.4, 8.5, 8.6, 8.7_
  
  - [ ] 10.3 Implement signal handler methods
    - Implement `_on_player_damaged(current: int, max: int)` - calls HPBar.update_hp()
    - Implement `_on_mana_changed(current: int, max: int)` - calls ManaBar.update_mana()
    - Implement `_on_chrono_rift_cooldown(duration: float)` - calls ChronoRiftIndicator.start_cooldown()
    - Implement `_on_chrono_rift_ready()` - calls ChronoRiftIndicator.set_ready()
    - Implement `_on_resource_changed(type: String, amount: int)` - calls ResourceDisplay.update_resource()
    - Implement `_on_hotbar_changed(slot_index: int, item_data: Dictionary)` - calls Hotbar.update_slot()
    - Implement `_on_inventory_updated()` - calls InventoryCounter.update_count()
    - Add null checks before calling component methods
    - _Requirements: 8.1, 8.2, 8.4, 8.5, 8.6, 8.7_

- [ ] 11. Update player_stats to emit mana signals
  - [ ] 11.1 Add mana signal emissions to player_stats
    - Open `scripts/player/player_stats.gd` or player controller script
    - Locate mana/stamina modification code
    - Add `EventBus.player_mana_changed.emit(current_mana, max_mana)` after mana changes
    - Ensure signal emits on ability usage, mana regeneration, and max mana changes
    - _Requirements: 8.5_

- [ ] 12. Update chrono_rift_system to emit cooldown signals
  - [ ] 12.1 Add cooldown signals to chrono_rift_system
    - Open `scripts/systems/chrono_rift_system_poc.gd`
    - Locate ability activation code
    - Add `EventBus.chrono_rift_cooldown_started.emit(cooldown_duration)` when ability used
    - Locate cooldown completion code
    - Add `EventBus.chrono_rift_ready.emit()` when cooldown completes
    - _Requirements: 8.7_

- [ ] 13. Integrate HUD with existing game scene
  - [ ] 13.1 Add HUD to main game scene
    - Open main game scene (e.g., `scenes/poc_world.tscn` or `Prototype_World.tscn`)
    - Instance HUD.tscn as child of root node
    - Verify HUD renders above all world elements
    - Test HUD visibility during gameplay
    - _Requirements: 7.1, 7.2, 7.4_
  
  - [ ] 13.2 Initialize HUD with current player stats
    - In HUD `_ready()`, query current player stats
    - Call HPBar.update_hp() with initial values
    - Call ManaBar.update_mana() with initial values
    - Call InventoryCounter.update_count() with initial values
    - Call ResourceDisplay.update_resource() for all resources
    - _Requirements: 1.1, 2.1, 5.1, 6.1_

- [ ] 14. Implement window resize handling
  - [ ] 14.1 Add responsive positioning to HUD
    - In hud.gd, connect to `get_viewport().size_changed` signal
    - Implement `_on_viewport_size_changed()` method
    - Recalculate Hotbar position: (viewport_width/2 - 150, viewport_height - 70)
    - Recalculate InfoPanel position: (viewport_width - 210, 10)
    - Update positions within 200ms of resize event
    - _Requirements: 7.3_
  
  - [ ]* 14.2 Write integration tests for window resize
    - Test HUD repositioning at different resolutions
    - Test all components remain visible after resize
    - _Requirements: 7.3_

- [ ] 15. Apply visual styling and polish
  - [ ] 15.1 Apply pixel art style to all components
    - Set texture filter to Nearest for all UI elements
    - Apply semi-transparent dark backgrounds: Color(0, 0, 0, 0.7)
    - Set font sizes: HP/Mana=16px, ChronoRift=14px, Hotbar=12px, Resources=14px
    - Apply 2px padding inside all panels
    - Ensure 10px minimum padding from screen edges
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 10.6_
  
  - [ ] 15.2 Verify color palette consistency
    - Verify HP colors: Green (#00FF00), Yellow (#FFFF00), Red (#FF0000)
    - Verify Mana color: Cyan (#00FFFF)
    - Verify Chrono Rift colors: Gray (#808080) cooldown, Cyan (#00FFFF) ready
    - Verify Inventory colors: White, Orange (#FFA500), Red (#FF0000)
    - Verify Resource colors: Fire=Red, Gold=Yellow, Stone=Gray, Wood=Brown, Meat=Pink
    - _Requirements: 9.5_

- [ ] 16. Final checkpoint - End-to-end integration testing
  - [ ]* 16.1 Write integration tests for complete signal flow
    - Test Player_Stats → EventBus → HUD → HPBar flow
    - Test Player_Stats → EventBus → HUD → ManaBar flow
    - Test chrono_rift_system → EventBus → HUD → ChronoRiftIndicator flow
    - Test ResourceManager → EventBus → HUD → ResourceDisplay flow
    - Test Player_Inventory → HUD → InventoryCounter flow
    - Test Player_Inventory → EventBus → HUD → Hotbar flow
    - _Requirements: 8.1, 8.2, 8.4, 8.5, 8.6, 8.7_
  
  - [ ] 16.2 Manual gameplay testing
    - Test HP bar updates during combat (take damage, heal)
    - Test Mana bar updates during ability usage
    - Test Chrono Rift cooldown countdown and ready state
    - Test Hotbar item assignment and usage
    - Test Inventory counter updates and color warnings
    - Test Resource display updates when gaining/spending resources
    - Test HUD visibility and positioning at different resolutions
    - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Implementation follows bottom-up approach: signals → data systems → UI components → integration
- All UI components use event-driven updates (no frame polling)
- GDScript is used for all implementation (matching design document)
- ResourceManager is a new autoload that needs to be registered in project settings
- Existing EventBus will be extended with new signals
- Existing player_stats and chrono_rift_system will be updated to emit new signals

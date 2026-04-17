# Resource Gathering & Farming System - Requirements Document

**Version:** 1.0  
**Date:** 2026-04-16  
**Status:** Draft

---

## 1. Introduction

The Resource Gathering & Farming System adds harvestable objects to the existing 30x30 game map, allowing players to gather resources (wood, stone, meat) by interacting with environmental objects (trees, rocks, bushes). This system integrates with the existing ResourceManager autoload and provides visual feedback during gathering operations. Objects respawn after being harvested to ensure continuous resource availability.

---

## 2. Glossary

| Term | Definition |
|------|------------|
| **Harvestable_Object** | An environmental object (tree, rock, or bush) that players can interact with to gather resources |
| **Tree** | A harvestable object that yields wood resources when gathered |
| **Rock** | A harvestable object that yields stone resources when gathered |
| **Bush** | A harvestable object that yields meat resources when gathered |
| **ResourceManager** | The existing autoload singleton that tracks player resources (fire_shard, gold, stone, wood, meat) |
| **EventBus** | The existing autoload singleton that emits game-wide signals including resource_changed |
| **Gathering** | The process of extracting resources from a harvestable object, which takes time and displays visual feedback |
| **Respawn** | The process of a harvested object reappearing after a cooldown period |
| **Interaction_Range** | The maximum distance between the player and a harvestable object that allows interaction |
| **Prototype_World** | The existing 30x30 game map scene where harvestable objects spawn |

---

## 3. Requirements

### 3.1 Harvestable Object Spawning

**REQ-001: Harvestable Object Spawning**

**User Story:**  
*As a player, I want harvestable objects to appear on the map, so that I can gather resources from the environment.*

**Acceptance Criteria:**
1. WHEN Prototype_World loads, THE Harvestable_Object_Spawner SHALL spawn trees, rocks, and bushes at random valid positions on the 30x30 map
2. THE Harvestable_Object_Spawner SHALL ensure spawned objects do not overlap with existing entities or obstacles
3. THE Harvestable_Object_Spawner SHALL spawn at least 5 trees, 5 rocks, and 5 bushes per map instance
4. THE Tree SHALL be visually represented as a ColorRect placeholder with a distinct color
5. THE Rock SHALL be visually represented as a ColorRect placeholder with a distinct color different from trees
6. THE Bush SHALL be visually represented as a ColorRect placeholder with a distinct color different from trees and rocks

---

### 3.2 Player Interaction Detection

**REQ-002: Player Interaction Detection**

**User Story:**  
*As a player, I want to know when I can interact with harvestable objects, so that I understand when gathering is possible.*

**Acceptance Criteria:**
1. WHEN the player is within Interaction_Range of a Harvestable_Object, THE Harvestable_Object SHALL display a visual indicator showing interaction is available
2. THE Interaction_Range SHALL be 50 pixels or less from the player's center to the object's center
3. WHEN the player moves outside Interaction_Range, THE Harvestable_Object SHALL hide the visual indicator
4. THE visual indicator SHALL be clearly distinguishable from the object's normal appearance

---

### 3.3 Resource Gathering Interaction

**REQ-003: Resource Gathering Interaction**

**User Story:**  
*As a player, I want to gather resources by pressing the interact key near harvestable objects, so that I can collect materials for crafting and progression.*

**Acceptance Criteria:**
1. WHEN the player presses the "interact" input action (E key) while within Interaction_Range of a Harvestable_Object, THE Harvestable_Object SHALL begin the gathering process
2. THE gathering process SHALL take between 1 and 3 seconds to complete
3. WHILE gathering is in progress, THE Harvestable_Object SHALL display a visual progress indicator
4. WHILE gathering is in progress, THE player SHALL remain able to move and cancel the gathering by moving outside Interaction_Range
5. IF the player moves outside Interaction_Range during gathering, THEN THE Harvestable_Object SHALL cancel the gathering process and reset progress to zero
6. WHEN gathering completes successfully, THE Harvestable_Object SHALL add resources to ResourceManager and enter the harvested state

---

### 3.4 Resource Distribution

**REQ-004: Resource Distribution**

**User Story:**  
*As a player, I want different object types to give different resources, so that I can gather specific materials I need.*

**Acceptance Criteria:**
1. WHEN a Tree is successfully harvested, THE Tree SHALL call ResourceManager.add_resource with type "wood" and amount between 1 and 3
2. WHEN a Rock is successfully harvested, THE Rock SHALL call ResourceManager.add_resource with type "stone" and amount between 1 and 3
3. WHEN a Bush is successfully harvested, THE Bush SHALL call ResourceManager.add_resource with type "meat" and amount between 1 and 3
4. WHEN any Harvestable_Object adds resources, THE ResourceManager SHALL emit EventBus.resource_changed signal with the resource type and new total amount

---

### 3.5 Object Respawn System

**REQ-005: Object Respawn System**

**User Story:**  
*As a player, I want harvested objects to respawn after some time, so that I can continue gathering resources without exhausting the map.*

**Acceptance Criteria:**
1. WHEN a Harvestable_Object is successfully harvested, THE Harvestable_Object SHALL enter a depleted state and become non-interactive
2. WHILE in depleted state, THE Harvestable_Object SHALL display a visual indication that it is depleted (reduced opacity or different color)
3. WHEN a Harvestable_Object enters depleted state, THE Harvestable_Object SHALL start a respawn timer between 30 and 60 seconds
4. WHEN the respawn timer expires, THE Harvestable_Object SHALL return to its normal harvestable state with full visual appearance
5. WHEN a Harvestable_Object respawns, THE Harvestable_Object SHALL be immediately available for gathering again

---

### 3.6 Visual Feedback During Gathering

**REQ-006: Visual Feedback During Gathering**

**User Story:**  
*As a player, I want clear visual feedback during gathering, so that I know the system is working and how long I need to wait.*

**Acceptance Criteria:**
1. WHEN gathering begins, THE Harvestable_Object SHALL display a progress bar or progress indicator at 0% completion
2. WHILE gathering is in progress, THE progress indicator SHALL update smoothly to reflect elapsed time as a percentage of total gathering time
3. WHEN gathering reaches 100% completion, THE progress indicator SHALL disappear
4. WHEN gathering is cancelled, THE progress indicator SHALL disappear immediately

---

### 3.7 Integration with Existing Systems

**REQ-007: Integration with Existing Systems**

**User Story:**  
*As a developer, I want the gathering system to integrate seamlessly with existing game systems, so that it doesn't break current functionality.*

**Acceptance Criteria:**
1. THE Harvestable_Object_Spawner SHALL spawn objects in Prototype_World without modifying the existing 30x30 map size
2. THE gathering system SHALL use the existing "interact" input action defined in the project input map
3. WHEN resources are added via gathering, THE ResourceManager SHALL emit EventBus.resource_changed signal exactly as it does for existing resource additions
4. THE Harvestable_Objects SHALL not interfere with existing enemy AI pathfinding or player movement
5. THE Harvestable_Objects SHALL be added to the YSortRoot node to ensure proper visual layering with player and enemies

---

### 3.8 Gathering Animation State

**REQ-008: Gathering Animation State**

**User Story:**  
*As a player, I want to see a gathering animation or effect, so that the action feels responsive and engaging.*

**Acceptance Criteria:**
1. WHEN gathering begins, THE Harvestable_Object SHALL play a visual effect or animation indicating active gathering
2. WHILE gathering is in progress, THE visual effect SHALL continue playing
3. WHEN gathering completes successfully, THE Harvestable_Object SHALL play a completion effect or animation
4. WHEN gathering is cancelled, THE visual effect SHALL stop immediately
5. THE gathering visual effects SHALL be implemented using ColorRect transformations or simple animations (no sprite assets required)

---

## 4. Summary

**Total Requirements:** 8  
**Total Acceptance Criteria:** 36

**Key Features:**
- 🌳 Trees → Wood (1-3 per harvest)
- 🪨 Rocks → Stone (1-3 per harvest)
- 🌿 Bushes → Meat (1-3 per harvest)
- Spawn: Minimum 5 of each type
- Interaction range: 50 pixels
- Gathering time: 1-3 seconds
- Respawn time: 30-60 seconds
- Visual feedback: Progress bars and animations
- Integration: ResourceManager, EventBus, YSort

---

**Next Steps:**
1. Review requirements with stakeholders
2. Create design document
3. Create implementation tasks
4. Begin development

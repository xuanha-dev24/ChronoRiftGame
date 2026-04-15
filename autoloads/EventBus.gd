# EventBus.gd
# Global signal bus for game-wide events
extends Node

# Player signals
signal player_died(position: Vector2)
signal player_respawned()
signal player_health_changed(current_hp: int, max_hp: int)
signal player_damaged(current_hp: int, max_hp: int)
signal player_mana_changed(current_mana: int, max_mana: int)

# Chrono Rift signals
signal chrono_rift_used(type: String)
signal chrono_rift_cooldown_started(duration: float)
signal chrono_rift_ready()
signal time_echo_spawned(position: Vector2, items: Array)
signal chrono_dust_collected(amount: int)

# Combat signals
signal enemy_killed(enemy_type: String, position: Vector2)
signal damage_dealt(target: Node, amount: int)

# Item/Inventory signals
signal item_picked_up(item_id: String, quantity: int)
signal item_used(item_id: String)
signal inventory_changed()
signal hotbar_slot_changed(slot_index: int, item_data: Dictionary)

# Resource signals
signal resource_changed(resource_type: String, amount: int)

# Effect signals
signal spawn_effect(effect_name: String, position: Vector2)

# World signals
signal biome_entered(biome_name: String)
signal day_night_cycle_changed(time_of_day: float)

# UI signals
signal ui_opened(ui_name: String)
signal ui_closed(ui_name: String)

# player_stats.gd
# Manages player stats: HP, stamina, chrono resources
extends Node

signal health_changed(current_hp: int, max_hp: int)
signal stamina_changed(current_stamina: float, max_stamina: float)
signal died()
signal chrono_rift_count_changed(count: int)

@export var max_hp: int = 100
@export var max_stamina: float = 100.0
@export var stamina_regen_rate: float = 10.0

var current_hp: int = 100
var current_stamina: float = 100.0
var chrono_dust_count: int = 0
var chrono_rift_count: int = 3
var is_alive: bool = true

func _ready() -> void:
	current_hp = max_hp
	current_stamina = max_stamina
	health_changed.emit(current_hp, max_hp)

func _process(delta: float) -> void:
	# Regenerate stamina over time
	if current_stamina < max_stamina:
		current_stamina = min(current_stamina + stamina_regen_rate * delta, max_stamina)
		stamina_changed.emit(current_stamina, max_stamina)

func take_damage(amount: int) -> void:
	if not is_alive:
		return
	
	current_hp = max(current_hp - amount, 0)
	health_changed.emit(current_hp, max_hp)
	EventBus.player_health_changed.emit(current_hp, max_hp)
	
	if current_hp <= 0:
		die()

func heal(amount: int) -> void:
	if not is_alive:
		return
	
	current_hp = min(current_hp + amount, max_hp)
	health_changed.emit(current_hp, max_hp)
	EventBus.player_health_changed.emit(current_hp, max_hp)

func use_stamina(amount: float) -> bool:
	if current_stamina >= amount:
		current_stamina -= amount
		stamina_changed.emit(current_stamina, max_stamina)
		return true
	return false

func use_chrono_rift() -> bool:
	if chrono_rift_count > 0:
		chrono_rift_count -= 1
		chrono_rift_count_changed.emit(chrono_rift_count)
		return true
	return false

func add_chrono_rift(amount: int = 1) -> void:
	chrono_rift_count += amount
	chrono_rift_count_changed.emit(chrono_rift_count)

func add_chrono_dust(amount: int) -> void:
	chrono_dust_count += amount
	EventBus.chrono_dust_collected.emit(amount)

func die() -> void:
	if not is_alive:
		return
	
	is_alive = false
	died.emit()
	GameManager.set_game_state(GameManager.GameState.DEAD)

func respawn() -> void:
	current_hp = max_hp
	current_stamina = max_stamina
	is_alive = true
	health_changed.emit(current_hp, max_hp)
	EventBus.player_respawned.emit()

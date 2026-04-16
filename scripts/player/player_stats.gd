# player_stats.gd
# Manages player stats: HP, stamina, chrono resources
extends Node

signal health_changed(current_hp: int, max_hp: int)
signal stamina_changed(current_stamina: float, max_stamina: float)
signal mana_changed(current_mana: int, max_mana: int)
signal died()
signal chrono_rift_count_changed(count: int)

@export var max_hp: int = 100
@export var max_stamina: float = 100.0
@export var max_mana: int = 100
@export var stamina_regen_rate: float = 10.0
@export var mana_regen_rate: float = 10.0  # Increased from 5.0 to 10.0 for faster regen

var current_hp: int = 100
var current_stamina: float = 100.0
var current_mana: int = 100
var mana_accumulator: float = 0.0  # Accumulator for fractional mana regen
var chrono_dust_count: int = 0
var chrono_rift_count: int = 3
var is_alive: bool = true

func _ready() -> void:
	current_hp = max_hp
	current_stamina = max_stamina
	current_mana = max_mana
	health_changed.emit(current_hp, max_hp)
	mana_changed.emit(current_mana, max_mana)
	EventBus.player_mana_changed.emit(current_mana, max_mana)

func _process(delta: float) -> void:
	# Regenerate stamina over time
	if current_stamina < max_stamina:
		current_stamina = min(current_stamina + stamina_regen_rate * delta, max_stamina)
		stamina_changed.emit(current_stamina, max_stamina)
	
	# Regenerate mana over time (with accumulator for smooth regen)
	if current_mana < max_mana:
		mana_accumulator += mana_regen_rate * delta
		
		# Only update when we have at least 1 mana to add
		if mana_accumulator >= 1.0:
			var mana_to_add = int(mana_accumulator)
			current_mana = min(current_mana + mana_to_add, max_mana)
			mana_accumulator -= mana_to_add
			
			# Emit signals
			mana_changed.emit(current_mana, max_mana)
			EventBus.player_mana_changed.emit(current_mana, max_mana)
			
			# Debug output
			print("[PlayerStats] Mana regen: %d/%d (+%d)" % [current_mana, max_mana, mana_to_add])

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

func use_mana(amount: int) -> bool:
	"""Use mana for abilities. Returns true if successful."""
	if current_mana >= amount:
		current_mana -= amount
		mana_changed.emit(current_mana, max_mana)
		EventBus.player_mana_changed.emit(current_mana, max_mana)
		return true
	return false

func restore_mana(amount: int) -> void:
	"""Restore mana (e.g., from potions)."""
	if not is_alive:
		return
	
	current_mana = min(current_mana + amount, max_mana)
	mana_changed.emit(current_mana, max_mana)
	EventBus.player_mana_changed.emit(current_mana, max_mana)

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
	current_mana = max_mana
	is_alive = true
	health_changed.emit(current_hp, max_hp)
	mana_changed.emit(current_mana, max_mana)
	EventBus.player_mana_changed.emit(current_mana, max_mana)
	EventBus.player_respawned.emit()

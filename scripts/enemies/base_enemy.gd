# base_enemy.gd
# Abstract base class for all enemy types in ChronoRift
# Provides common functionality: stats, state machine, combat, Chrono Rift integration
class_name BaseEnemy
extends CharacterBody2D

# ============================================================================
# EXPORTED VARIABLES
# ============================================================================

@export_group("Stats")
@export var max_hp: int = 30
@export var base_speed: float = 60.0
@export var damage: int = 5

@export_group("AI Behavior")
@export var aggro_range: float = 150.0
@export var attack_range: float = 30.0
@export var attack_cooldown: float = 1.5
@export var patrol_radius: float = 80.0

@export_group("Loot")
@export var chrono_dust_drop: int = 5
@export var enemy_type: String = "base_enemy"

@export_group("Debug")
@export var debug_log: bool = false

# ============================================================================
# INTERNAL STATE
# ============================================================================

var current_hp: int
var current_speed: float
var is_slowed: bool = false
var can_attack: bool = true
var player_ref: Node2D = null
var spawn_position: Vector2

# State machine reference (initialized by subclasses)
var state_machine: EnemyStateMachine = null

# Node references
@onready var sprite: ColorRect = $Sprite
@onready var hp_label: Label = $HPLabel
@onready var attack_timer: Timer = $AttackCooldown

# ============================================================================
# LIFECYCLE
# ============================================================================

func _ready() -> void:
	# Initialize stats
	current_hp = max_hp
	current_speed = base_speed
	spawn_position = global_position
	
	# Add to enemies group for detection
	add_to_group("enemies")
	
	# Configure collision layer (Layer 2 for enemies)
	collision_layer = 2
	collision_mask = 1  # Detect player on Layer 1
	
	# Cache player reference
	player_ref = get_tree().get_first_node_in_group("player")
	if player_ref == null and debug_log:
		push_warning("BaseEnemy: Player not found in scene tree")
	
	# Update HP display
	_update_hp_display()
	
	# Setup attack cooldown timer
	if attack_timer:
		attack_timer.timeout.connect(_on_attack_cooldown_timeout)
	
	if debug_log:
		print("[%s] Enemy spawned at %s" % [enemy_type, spawn_position])

func _physics_process(delta: float) -> void:
	# Update state machine (if initialized by subclass)
	if state_machine:
		state_machine.update(delta)
	
	# Apply velocity and move
	move_and_slide()
	
	# Debug visualization
	if debug_log:
		queue_redraw()

# ============================================================================
# COMBAT
# ============================================================================

func take_damage(amount: int) -> void:
	if current_hp <= 0:
		return  # Already dead, ignore damage
	
	current_hp -= amount
	_update_hp_display()
	
	if debug_log:
		print("[%s] Took %d damage, HP: %d/%d" % [enemy_type, amount, current_hp, max_hp])
	
	# Flash red for feedback
	_flash_damage()
	
	# Check for death
	if current_hp <= 0:
		_die()

func attack_player() -> void:
	"""Execute attack on player. Override in subclasses for custom attack logic."""
	if not can_attack:
		return
	
	if not is_player_in_range(attack_range):
		if debug_log:
			print("[%s] Player out of attack range" % enemy_type)
		return
	
	# Default melee attack
	can_attack = false
	attack_timer.start(attack_cooldown)
	
	if debug_log:
		print("[%s] Attacking player for %d damage" % [enemy_type, damage])
	
	# Deal damage to player
	if player_ref and player_ref.has_method("take_damage"):
		player_ref.take_damage(damage)

func _die() -> void:
	"""Handle enemy death. Transitions to DEAD state."""
	if debug_log:
		print("[%s] Died at position %s" % [enemy_type, global_position])
	
	# Emit loot signal
	EventBus.enemy_killed.emit(enemy_type, global_position)
	EventBus.generated_enemy_killed.emit(self, enemy_type, global_position)
	
	# Print loot drop (placeholder until pickup system exists)
	print("%s died — dropped %d chrono dust" % [enemy_type, chrono_dust_drop])
	
	# Transition to DEAD state (handled by state machine)
	if state_machine:
		state_machine.change_state(state_machine.dead_state)

# ============================================================================
# CHRONO RIFT INTEGRATION
# ============================================================================

func apply_slow(factor: float) -> void:
	"""Apply slow effect from Chrono Rift. Factor should be in range [0.0, 1.0]."""
	if is_slowed:
		if debug_log:
			print("[%s] Already slowed, updating factor to %f" % [enemy_type, factor])
	
	is_slowed = true
	current_speed = base_speed * factor
	
	# Visual feedback: change to magenta/pink
	if sprite:
		sprite.color = Color(1.0, 0.0, 1.0)  # Magenta
	
	if debug_log:
		print("[%s] Slowed: speed %f -> %f (factor: %f)" % [enemy_type, base_speed, current_speed, factor])

func remove_slow() -> void:
	"""Remove slow effect and restore normal speed."""
	if not is_slowed:
		return
	
	is_slowed = false
	current_speed = base_speed
	
	# Restore original color (override in subclasses for specific colors)
	if sprite:
		sprite.color = Color(0.2, 0.8, 0.2)  # Default green
	
	if debug_log:
		print("[%s] Slow removed: speed restored to %f" % [enemy_type, current_speed])

# ============================================================================
# HELPER METHODS
# ============================================================================

func get_player() -> Node2D:
	"""Get cached player reference. Re-query if lost."""
	if player_ref == null or not is_instance_valid(player_ref):
		player_ref = get_tree().get_first_node_in_group("player")
		if player_ref == null and debug_log:
			push_warning("BaseEnemy: Player reference lost and could not be re-acquired")
	return player_ref

func is_player_in_range(range: float) -> bool:
	"""Check if player is within specified range."""
	var player = get_player()
	if player == null:
		return false
	
	var distance_squared = global_position.distance_squared_to(player.global_position)
	return distance_squared <= range * range

func get_distance_to_player() -> float:
	"""Get distance to player. Returns -1 if player not found."""
	var player = get_player()
	if player == null:
		return -1.0
	
	return global_position.distance_to(player.global_position)

func get_direction_to_player() -> Vector2:
	"""Get normalized direction vector toward player."""
	var player = get_player()
	if player == null:
		return Vector2.ZERO
	
	return (player.global_position - global_position).normalized()

# ============================================================================
# INTERNAL HELPERS
# ============================================================================

func _update_hp_display() -> void:
	"""Update HP label text."""
	if hp_label:
		hp_label.text = "%d / %d" % [current_hp, max_hp]

func _flash_damage() -> void:
	"""Flash sprite red when taking damage."""
	if not sprite:
		return
	
	var original_color = sprite.color
	sprite.color = Color.RED
	
	await get_tree().create_timer(0.1).timeout
	
	# Restore color (check if slowed)
	if is_slowed:
		sprite.color = Color(1.0, 0.0, 1.0)  # Magenta if slowed
	else:
		sprite.color = original_color

func _on_attack_cooldown_timeout() -> void:
	"""Reset attack cooldown."""
	can_attack = true
	if debug_log:
		print("[%s] Attack ready" % enemy_type)

# ============================================================================
# DEBUG VISUALIZATION
# ============================================================================

func _draw() -> void:
	"""Draw debug visualization when debug_log is enabled."""
	if not debug_log:
		return
	
	# Draw aggro range (cyan circle)
	draw_arc(Vector2.ZERO, aggro_range, 0, TAU, 32, Color.CYAN, 2.0)
	
	# Draw attack range (red circle)
	draw_arc(Vector2.ZERO, attack_range, 0, TAU, 32, Color.RED, 2.0)

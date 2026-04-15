# enemy_state.gd
# Abstract base class for all enemy AI states
# Defines the interface that all state implementations must follow
class_name EnemyState
extends Node

# ============================================================================
# REFERENCES
# ============================================================================

var enemy: BaseEnemy = null
var state_machine: EnemyStateMachine = null

# ============================================================================
# INITIALIZATION
# ============================================================================

func _init(owner_enemy: BaseEnemy, owner_state_machine: EnemyStateMachine) -> void:
	enemy = owner_enemy
	state_machine = owner_state_machine

# ============================================================================
# STATE INTERFACE (Override in subclasses)
# ============================================================================

func enter() -> void:
	"""Called when entering this state. Override in subclasses."""
	pass

func exit() -> void:
	"""Called when exiting this state. Override in subclasses."""
	pass

func update(delta: float) -> void:
	"""Called every frame while in this state. Override in subclasses."""
	pass

func get_state_name() -> String:
	"""Return the name of this state. Override in subclasses."""
	return "BaseState"

# ============================================================================
# HELPER METHODS (Available to all states)
# ============================================================================

func transition_to(new_state: EnemyState) -> void:
	"""Helper method to transition to another state."""
	if state_machine:
		state_machine.change_state(new_state)
	else:
		push_error("[EnemyState] state_machine reference is null")

func is_player_in_aggro_range() -> bool:
	"""Check if player is within aggro range."""
	if enemy:
		return enemy.is_player_in_range(enemy.aggro_range)
	return false

func is_player_in_attack_range() -> bool:
	"""Check if player is within attack range."""
	if enemy:
		return enemy.is_player_in_range(enemy.attack_range)
	return false

func get_distance_to_player() -> float:
	"""Get distance to player."""
	if enemy:
		return enemy.get_distance_to_player()
	return -1.0

func get_direction_to_player() -> Vector2:
	"""Get normalized direction vector toward player."""
	if enemy:
		return enemy.get_direction_to_player()
	return Vector2.ZERO

func apply_isometric_transform(direction: Vector2) -> Vector2:
	"""Apply isometric coordinate transformation to direction vector."""
	if direction == Vector2.ZERO:
		return Vector2.ZERO
	
	var iso_x = direction.x - direction.y
	var iso_y = (direction.x + direction.y) * 0.5
	return Vector2(iso_x, iso_y).normalized()

func log_debug(message: String) -> void:
	"""Log debug message if debug_log is enabled."""
	if enemy and enemy.debug_log:
		print("[%s - %s] %s" % [enemy.enemy_type, get_state_name(), message])

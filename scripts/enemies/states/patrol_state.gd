# patrol_state.gd
# PATROL state - Enemy wanders within patrol radius
# Transitions to CHASE when player enters aggro range, or IDLE when waypoint reached
class_name PatrolState
extends EnemyState

# ============================================================================
# PATROL BEHAVIOR
# ============================================================================

var current_waypoint: Vector2 = Vector2.ZERO
var waypoint_reached: bool = false
const WAYPOINT_THRESHOLD: float = 10.0  # Distance to consider waypoint "reached"

# ============================================================================
# STATE LIFECYCLE
# ============================================================================

func enter() -> void:
	log_debug("Entering PATROL state")
	
	# Select random waypoint within patrol radius
	_select_new_waypoint()

func exit() -> void:
	log_debug("Exiting PATROL state")

func update(delta: float) -> void:
	# Check for player in aggro range (highest priority)
	if is_player_in_aggro_range():
		log_debug("Player detected in aggro range! Transitioning to CHASE")
		transition_to(state_machine.chase_state)
		return
	
	# Check if waypoint reached
	var distance_to_waypoint = enemy.global_position.distance_to(current_waypoint)
	if distance_to_waypoint < WAYPOINT_THRESHOLD:
		log_debug("Waypoint reached, returning to IDLE")
		transition_to(state_machine.idle_state)
		return
	
	# Move toward waypoint
	_move_toward_waypoint()

func get_state_name() -> String:
	return "PATROL"

# ============================================================================
# WAYPOINT LOGIC
# ============================================================================

func _select_new_waypoint() -> void:
	"""Select random waypoint within patrol_radius of spawn_position."""
	if not enemy:
		return
	
	# Generate random offset within patrol radius
	var angle = randf() * TAU  # Random angle (0 to 2π)
	var distance = randf() * enemy.patrol_radius  # Random distance (0 to patrol_radius)
	
	var offset = Vector2(cos(angle), sin(angle)) * distance
	current_waypoint = enemy.spawn_position + offset
	
	log_debug("New waypoint selected at %s (distance: %.1f from spawn)" % [current_waypoint, distance])

func _move_toward_waypoint() -> void:
	"""Calculate direction to waypoint and apply isometric movement."""
	
	# Get direction to waypoint
	var direction = (current_waypoint - enemy.global_position).normalized()
	
	if direction == Vector2.ZERO:
		enemy.velocity = Vector2.ZERO
		return
	
	# Apply isometric transformation
	var iso_direction = apply_isometric_transform(direction)
	
	# Apply speed (respects slow effects via current_speed)
	enemy.velocity = iso_direction * enemy.current_speed
	
	# Debug visualization
	if enemy.debug_log:
		var distance = enemy.global_position.distance_to(current_waypoint)
		log_debug("Moving to waypoint | Distance: %.1f | Speed: %.1f" % [distance, enemy.current_speed])

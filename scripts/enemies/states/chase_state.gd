# chase_state.gd
# CHASE state - Enemy pursues player using isometric movement
# Transitions to ATTACK when in range, or back to IDLE if player escapes
class_name ChaseState
extends EnemyState

# ============================================================================
# CHASE BEHAVIOR
# ============================================================================

var out_of_range_timer: float = 0.0
var out_of_range_timeout: float = 2.0  # Seconds before returning to IDLE

# ============================================================================
# STATE LIFECYCLE
# ============================================================================

func enter() -> void:
	log_debug("Entering CHASE state")
	
	# Reset out of range timer
	out_of_range_timer = 0.0

func exit() -> void:
	log_debug("Exiting CHASE state")

func update(delta: float) -> void:
	# Check if player is in attack range
	if is_player_in_attack_range():
		log_debug("Player in attack range! Transitioning to ATTACK")
		transition_to(state_machine.attack_state)
		return
	
	# Check if player is still in aggro range
	if not is_player_in_aggro_range():
		out_of_range_timer += delta
		
		if out_of_range_timer >= out_of_range_timeout:
			# Return to PATROL if available, otherwise IDLE
			if state_machine.patrol_state != null:
				log_debug("Player out of aggro range for %.1fs. Returning to PATROL" % out_of_range_timeout)
				transition_to(state_machine.patrol_state)
			else:
				log_debug("Player out of aggro range for %.1fs. Returning to IDLE" % out_of_range_timeout)
				transition_to(state_machine.idle_state)
			return
	else:
		# Player is in range, reset timer
		out_of_range_timer = 0.0
	
	# Move toward player
	_move_toward_player()

func get_state_name() -> String:
	return "CHASE"

# ============================================================================
# MOVEMENT
# ============================================================================

func _move_toward_player() -> void:
	"""Calculate direction to player and apply isometric movement."""
	
	# Get direction to player
	var direction = get_direction_to_player()
	
	if direction == Vector2.ZERO:
		# Player not found, stop moving
		enemy.velocity = Vector2.ZERO
		return
	
	# Apply isometric transformation
	var iso_direction = apply_isometric_transform(direction)
	
	# Apply speed (respects slow effects via current_speed)
	enemy.velocity = iso_direction * enemy.current_speed
	
	# Debug visualization
	if enemy.debug_log:
		var distance = get_distance_to_player()
		log_debug("Chasing player | Distance: %.1f | Speed: %.1f" % [distance, enemy.current_speed])

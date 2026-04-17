# chase_state.gd
# CHASE state - Enemy pursues player and structures using isometric movement
# Transitions to ATTACK when in range, or back to IDLE if targets escape
class_name ChaseState
extends EnemyState

# ============================================================================
# CHASE BEHAVIOR
# ============================================================================

var out_of_range_timer: float = 0.0
var out_of_range_timeout: float = 2.0  # Seconds before returning to IDLE
var current_target: Node2D = null  # Current target (player or structure)
const STRUCTURE_DETECTION_RANGE: float = 100.0

# ============================================================================
# STATE LIFECYCLE
# ============================================================================

func enter() -> void:
	log_debug("Entering CHASE state")
	
	# Reset out of range timer
	out_of_range_timer = 0.0
	
	# Detect initial targets
	current_target = _select_target()

func exit() -> void:
	log_debug("Exiting CHASE state")

func update(delta: float) -> void:
	# Update current target
	current_target = _select_target()
	
	# Check if we have a valid target
	if current_target == null:
		out_of_range_timer += delta
		
		if out_of_range_timer >= out_of_range_timeout:
			# Return to PATROL if available, otherwise IDLE
			if state_machine.patrol_state != null:
				log_debug("No targets for %.1fs. Returning to PATROL" % out_of_range_timeout)
				transition_to(state_machine.patrol_state)
			else:
				log_debug("No targets for %.1fs. Returning to IDLE" % out_of_range_timeout)
				transition_to(state_machine.idle_state)
			return
	else:
		# Target found, reset timer
		out_of_range_timer = 0.0
		
		# Check if target is in attack range
		var distance_to_target = enemy.global_position.distance_to(current_target.global_position)
		if distance_to_target <= enemy.attack_range:
			log_debug("Target in attack range! Transitioning to ATTACK")
			transition_to(state_machine.attack_state)
			return
	
	# Move toward current target
	_move_toward_target()

func get_state_name() -> String:
	return "CHASE"

# ============================================================================
# MOVEMENT
# ============================================================================

func _move_toward_target() -> void:
	"""Calculate direction to current target and apply isometric movement."""
	
	if current_target == null:
		enemy.velocity = Vector2.ZERO
		return
	
	# Get direction to target
	var direction = (current_target.global_position - enemy.global_position).normalized()
	
	if direction == Vector2.ZERO:
		enemy.velocity = Vector2.ZERO
		return
	
	# Apply isometric transformation
	var iso_direction = apply_isometric_transform(direction)
	
	# Apply speed (respects slow effects via current_speed)
	enemy.velocity = iso_direction * enemy.current_speed
	
	# Debug visualization
	if enemy.debug_log:
		var distance = enemy.global_position.distance_to(current_target.global_position)
		var target_type = "Player" if current_target.is_in_group("player") else "Structure"
		log_debug("Chasing %s | Distance: %.1f | Speed: %.1f" % [target_type, distance, enemy.current_speed])

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

# ============================================================================
# TARGET DETECTION
# ============================================================================

func detect_targets() -> Array:
	"""Detect all potential targets (player and structures) within range."""
	var targets = []
	
	# Check if enemy exists
	if enemy == null:
		return targets
	
	# Detect player
	var player = enemy.get_player()
	if player and is_instance_valid(player):
		var distance_to_player = enemy.global_position.distance_to(player.global_position)
		if distance_to_player < enemy.aggro_range:
			targets.append({"node": player, "distance": distance_to_player})
	
	# Detect structures within STRUCTURE_DETECTION_RANGE
	# Check if this node is inside the scene tree before calling get_tree()
	if not is_inside_tree():
		return targets
	
	var tree = get_tree()
	if tree == null:
		return targets
	
	var structures = tree.get_nodes_in_group("structures")
	if structures == null:
		return targets
	
	for structure in structures:
		if not is_instance_valid(structure):
			continue
		
		var distance_to_structure = enemy.global_position.distance_to(structure.global_position)
		if distance_to_structure < STRUCTURE_DETECTION_RANGE:
			targets.append({"node": structure, "distance": distance_to_structure})
	
	return targets

func select_closest_target(targets: Array) -> Node2D:
	"""Select the closest target from the array of targets."""
	if targets.is_empty():
		return null
	
	# Sort by distance (ascending)
	targets.sort_custom(func(a, b): return a["distance"] < b["distance"])
	
	return targets[0]["node"]

func _select_target() -> Node2D:
	"""Detect targets and select the closest one."""
	var targets = detect_targets()
	return select_closest_target(targets)

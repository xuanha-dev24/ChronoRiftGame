# attack_state.gd
# ATTACK state - Enemy stops and executes attack on player or structures
# Handles windup, damage dealing, cooldown, and transitions
class_name AttackState
extends EnemyState

# ============================================================================
# ATTACK SEQUENCE
# ============================================================================

enum AttackPhase {
	WINDUP,      # Brief delay before attack
	EXECUTE,     # Deal damage
	COOLDOWN,    # Wait for cooldown
	COMPLETE     # Ready to transition
}

var current_phase: AttackPhase = AttackPhase.WINDUP
var phase_timer: float = 0.0
var current_target: Node2D = null  # Current target (player or structure)

const WINDUP_DURATION: float = 0.2
const FLASH_DURATION: float = 0.15
const STRUCTURE_DETECTION_RANGE: float = 100.0

# ============================================================================
# STATE LIFECYCLE
# ============================================================================

func enter() -> void:
	log_debug("Entering ATTACK state")
	
	# Stop movement
	enemy.velocity = Vector2.ZERO
	
	# Select initial target
	current_target = _select_target()
	
	# Start windup phase
	current_phase = AttackPhase.WINDUP
	phase_timer = 0.0

func exit() -> void:
	log_debug("Exiting ATTACK state")

func update(delta: float) -> void:
	# Ensure enemy stays still during attack
	enemy.velocity = Vector2.ZERO
	
	# Update attack sequence
	phase_timer += delta
	
	match current_phase:
		AttackPhase.WINDUP:
			_handle_windup()
		
		AttackPhase.EXECUTE:
			_handle_execute()
		
		AttackPhase.COOLDOWN:
			_handle_cooldown()
		
		AttackPhase.COMPLETE:
			_handle_complete()

func get_state_name() -> String:
	return "ATTACK"

# ============================================================================
# ATTACK PHASES
# ============================================================================

func _handle_windup() -> void:
	"""Wait for windup duration before executing attack."""
	if phase_timer >= WINDUP_DURATION:
		log_debug("Windup complete, executing attack")
		current_phase = AttackPhase.EXECUTE
		phase_timer = 0.0
		_execute_attack()

func _handle_execute() -> void:
	"""Flash sprite red and wait for flash duration."""
	if phase_timer >= FLASH_DURATION:
		# Restore sprite color
		_restore_sprite_color()
		
		# Move to cooldown phase
		current_phase = AttackPhase.COOLDOWN
		phase_timer = 0.0
		log_debug("Attack executed, waiting for cooldown")

func _handle_cooldown() -> void:
	"""Wait for attack cooldown to complete."""
	if enemy.can_attack:
		# Cooldown complete (managed by BaseEnemy's attack_timer)
		current_phase = AttackPhase.COMPLETE
		log_debug("Cooldown complete")

func _handle_complete() -> void:
	"""Attack sequence complete, transition to next state."""
	# Update target
	current_target = _select_target()
	
	# Check if we have any targets in range
	if current_target != null:
		log_debug("Target still in range, returning to CHASE")
		transition_to(state_machine.chase_state)
	else:
		log_debug("No targets in range, returning to IDLE")
		transition_to(state_machine.idle_state)

# ============================================================================
# ATTACK EXECUTION
# ============================================================================

func _execute_attack() -> void:
	"""Execute the actual attack - check range and deal damage to current target."""
	
	# Flash sprite red
	if enemy.sprite:
		enemy.sprite.color = Color.RED
	
	# Update target (in case it was destroyed)
	current_target = _select_target()
	
	# Check if we have a valid target in range
	if current_target == null:
		log_debug("No valid target in range, attack missed")
		return
	
	var distance_to_target = enemy.global_position.distance_to(current_target.global_position)
	if distance_to_target > enemy.attack_range:
		log_debug("Target moved out of attack range, attack missed")
		return
	
	# Deal damage based on target type
	if current_target.is_in_group("player"):
		# Attack player
		enemy.attack_player()
		log_debug("Attacked player for %d damage" % enemy.damage)
	elif current_target.is_in_group("structures"):
		# Attack structure
		if current_target.has_method("take_damage"):
			# Use same attack cooldown as player attacks
			enemy.can_attack = false
			enemy.attack_timer.start(enemy.attack_cooldown)
			
			current_target.take_damage(enemy.damage)
			log_debug("Attacked structure for %d damage" % enemy.damage)
	
	log_debug("Attack executed successfully")

func _restore_sprite_color() -> void:
	"""Restore sprite to original color after attack flash."""
	if not enemy.sprite:
		return
	
	# Check if slowed (magenta) or normal color
	if enemy.is_slowed:
		enemy.sprite.color = Color(1.0, 0.0, 1.0)  # Magenta
	else:
		# Restore to enemy's base color (override in subclasses if needed)
		enemy.sprite.color = Color(0.2, 0.8, 0.2)  # Default green

# ============================================================================
# TARGET DETECTION
# ============================================================================

func detect_targets() -> Array:
	"""Detect all potential targets (player and structures) within range."""
	var targets = []
	
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

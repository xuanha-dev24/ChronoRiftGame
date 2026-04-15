# attack_state.gd
# ATTACK state - Enemy stops and executes attack on player
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

const WINDUP_DURATION: float = 0.2
const FLASH_DURATION: float = 0.15

# ============================================================================
# STATE LIFECYCLE
# ============================================================================

func enter() -> void:
	log_debug("Entering ATTACK state")
	
	# Stop movement
	enemy.velocity = Vector2.ZERO
	
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
	# Check if player still in aggro range
	if is_player_in_aggro_range():
		log_debug("Player still in range, returning to CHASE")
		transition_to(state_machine.chase_state)
	else:
		log_debug("Player out of range, returning to IDLE")
		transition_to(state_machine.idle_state)

# ============================================================================
# ATTACK EXECUTION
# ============================================================================

func _execute_attack() -> void:
	"""Execute the actual attack - check range and deal damage."""
	
	# Flash sprite red
	if enemy.sprite:
		enemy.sprite.color = Color.RED
	
	# Check if player is still in attack range
	if not is_player_in_attack_range():
		log_debug("Player moved out of attack range, attack missed")
		return
	
	# Call enemy's attack_player method (handles damage and cooldown)
	enemy.attack_player()
	
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

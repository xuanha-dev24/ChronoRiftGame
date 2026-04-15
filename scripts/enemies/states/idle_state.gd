# idle_state.gd
# IDLE state - Enemy remains stationary and watches for player
# Transitions to CHASE when player enters aggro range, or PATROL after idle timeout
class_name IdleState
extends EnemyState

# ============================================================================
# IDLE ANIMATION
# ============================================================================

var pulse_time: float = 0.0
var base_color: Color = Color(0.2, 0.8, 0.2)  # Default green

# Patrol transition
var idle_timer: float = 0.0
var idle_duration: float = 3.0  # Seconds before transitioning to PATROL

# ============================================================================
# STATE LIFECYCLE
# ============================================================================

func enter() -> void:
	log_debug("Entering IDLE state")
	
	# Stop movement
	enemy.velocity = Vector2.ZERO
	
	# Reset pulse animation
	pulse_time = 0.0
	
	# Reset idle timer with random duration (3-5 seconds)
	idle_timer = 0.0
	idle_duration = randf_range(3.0, 5.0)
	
	# Set base color (will be overridden by subclasses)
	if enemy.sprite:
		base_color = enemy.sprite.color

func exit() -> void:
	log_debug("Exiting IDLE state")

func update(delta: float) -> void:
	# Ensure velocity stays zero
	enemy.velocity = Vector2.ZERO
	
	# Apply idle pulse animation
	_apply_idle_pulse(delta)
	
	# Check for player in aggro range (highest priority)
	if is_player_in_aggro_range():
		log_debug("Player detected in aggro range! Transitioning to CHASE")
		transition_to(state_machine.chase_state)
		return
	
	# Update idle timer
	idle_timer += delta
	
	# Transition to PATROL after idle duration (if patrol state exists)
	if idle_timer >= idle_duration and state_machine.patrol_state != null:
		log_debug("Idle timeout (%.1fs), transitioning to PATROL" % idle_duration)
		transition_to(state_machine.patrol_state)

func get_state_name() -> String:
	return "IDLE"

# ============================================================================
# IDLE ANIMATION
# ============================================================================

func _apply_idle_pulse(delta: float) -> void:
	"""Apply subtle color pulse animation while idle."""
	if not enemy.sprite:
		return
	
	# Don't override slow color
	if enemy.is_slowed:
		return
	
	pulse_time += delta
	
	# Pulse between base color and slightly brighter version
	# Using sine wave for smooth oscillation
	var pulse_factor = (sin(pulse_time * 2.0) + 1.0) * 0.5  # Range [0, 1]
	var brightness_boost = 0.2 * pulse_factor  # Subtle brightness change
	
	var pulsed_color = Color(
		base_color.r + brightness_boost,
		base_color.g + brightness_boost,
		base_color.b + brightness_boost
	)
	
	enemy.sprite.color = pulsed_color

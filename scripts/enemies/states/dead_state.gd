# dead_state.gd
# DEAD state - Enemy plays death animation and cleans up
# Fades out sprite, emits loot signal, and removes enemy from scene
class_name DeadState
extends EnemyState

# ============================================================================
# DEATH ANIMATION
# ============================================================================

const FADE_DURATION: float = 0.5
var fade_timer: float = 0.0
var is_fading: bool = false

# ============================================================================
# STATE LIFECYCLE
# ============================================================================

func enter() -> void:
	log_debug("Entering DEAD state")
	
	# Stop all movement
	enemy.velocity = Vector2.ZERO
	
	# Disable collision immediately to prevent further damage
	enemy.set_collision_layer_value(2, false)  # Disable Layer 2
	enemy.set_collision_mask_value(1, false)   # Disable Layer 1 detection
	
	# Start fade animation
	fade_timer = 0.0
	is_fading = true
	
	# Note: EventBus.enemy_killed signal already emitted in BaseEnemy._die()
	# Loot drop message already printed in BaseEnemy._die()

func exit() -> void:
	log_debug("Exiting DEAD state (should not happen)")

func update(delta: float) -> void:
	if not is_fading:
		return
	
	# Update fade timer
	fade_timer += delta
	
	# Calculate fade progress (0.0 to 1.0)
	var fade_progress = clamp(fade_timer / FADE_DURATION, 0.0, 1.0)
	
	# Apply fade to sprite
	_apply_fade(fade_progress)
	
	# Check if fade complete
	if fade_timer >= FADE_DURATION:
		_complete_death()

func get_state_name() -> String:
	return "DEAD"

# ============================================================================
# DEATH ANIMATION
# ============================================================================

func _apply_fade(progress: float) -> void:
	"""Fade sprite alpha from 1.0 to 0.0."""
	if not enemy.sprite:
		return
	
	# Fade alpha (1.0 -> 0.0)
	var alpha = 1.0 - progress
	enemy.sprite.modulate.a = alpha
	
	# Also fade HP label if it exists
	if enemy.hp_label:
		enemy.hp_label.modulate.a = alpha

func _complete_death() -> void:
	"""Death animation complete, remove enemy from scene."""
	is_fading = false
	
	log_debug("Death animation complete, removing enemy")
	
	# Remove enemy from scene
	enemy.queue_free()

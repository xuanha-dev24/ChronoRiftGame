# enemy_state_machine.gd
# State machine controller for enemy AI
# Manages state transitions and delegates behavior to state objects
class_name EnemyStateMachine
extends Node

# ============================================================================
# STATE REFERENCES
# ============================================================================

var current_state: EnemyState = null
var previous_state: EnemyState = null

# State instances (initialized by enemy)
var idle_state: EnemyState = null
var patrol_state: EnemyState = null
var chase_state: EnemyState = null
var attack_state: EnemyState = null
var dead_state: EnemyState = null

# ============================================================================
# ENEMY REFERENCE
# ============================================================================

var enemy: BaseEnemy = null

# ============================================================================
# INITIALIZATION
# ============================================================================

func _init(owner_enemy: BaseEnemy) -> void:
	enemy = owner_enemy
	
	if enemy.debug_log:
		print("[StateMachine] Initialized for enemy: %s" % enemy.enemy_type)

# ============================================================================
# STATE MANAGEMENT
# ============================================================================

func change_state(new_state: EnemyState) -> void:
	"""Transition to a new state. Calls exit() on old state and enter() on new state."""
	
	# Validate new state
	if new_state == null:
		push_error("[StateMachine] Attempted to change to null state")
		return
	
	# Exit current state
	if current_state != null:
		if enemy.debug_log:
			print("[StateMachine] Exiting state: %s" % current_state.get_state_name())
		current_state.exit()
	
	# Store previous state
	previous_state = current_state
	
	# Enter new state
	current_state = new_state
	
	if enemy.debug_log:
		var prev_name = previous_state.get_state_name() if previous_state else "None"
		print("[StateMachine] State transition: %s -> %s" % [prev_name, current_state.get_state_name()])
	
	current_state.enter()

func update(delta: float) -> void:
	"""Update current state. Called every frame from enemy's _physics_process."""
	
	# Safety check
	if current_state == null:
		push_error("[StateMachine] No current state! Initializing to idle_state")
		if idle_state != null:
			change_state(idle_state)
		return
	
	# Update current state
	current_state.update(delta)

func get_current_state() -> EnemyState:
	"""Get the current active state."""
	return current_state

func get_current_state_name() -> String:
	"""Get the name of the current active state."""
	if current_state == null:
		return "None"
	return current_state.get_state_name()

# ============================================================================
# STATE INITIALIZATION HELPERS
# ============================================================================

func initialize_states(idle: EnemyState, patrol: EnemyState, chase: EnemyState, attack: EnemyState, dead: EnemyState) -> void:
	"""Initialize all state references. Called by enemy after creating state instances."""
	idle_state = idle
	patrol_state = patrol
	chase_state = chase
	attack_state = attack
	dead_state = dead
	
	if enemy.debug_log:
		print("[StateMachine] All states initialized")
	
	# Start in idle state
	if idle_state != null:
		change_state(idle_state)
	else:
		push_error("[StateMachine] idle_state is null, cannot initialize")

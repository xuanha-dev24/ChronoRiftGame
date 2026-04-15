# earth_golem.gd
# EarthGolem enemy - Tanky melee attacker
# Slow movement, high HP, high damage
class_name EarthGolem
extends BaseEnemy

# ============================================================================
# EARTH GOLEM STATS (Override BaseEnemy defaults)
# ============================================================================

func _init() -> void:
	# Stats
	max_hp = 120
	base_speed = 40.0
	damage = 15
	
	# AI Behavior
	aggro_range = 180.0
	attack_range = 40.0
	attack_cooldown = 2.5
	patrol_radius = 60.0
	
	# Loot
	chrono_dust_drop = 15
	enemy_type = "earth_golem"

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready() -> void:
	# Call parent _ready() first
	super._ready()
	
	# Set sprite color to brown
	if sprite:
		sprite.color = Color(0.6, 0.4, 0.2)  # Brown
	
	# Initialize state machine with all states
	_initialize_state_machine()
	
	if debug_log:
		print("[EarthGolem] Initialized at %s" % global_position)

# ============================================================================
# STATE MACHINE SETUP
# ============================================================================

func _initialize_state_machine() -> void:
	"""Create and initialize all state instances."""
	
	# Create state machine
	state_machine = EnemyStateMachine.new(self)
	add_child(state_machine)
	
	# Create state instances
	var idle = IdleState.new(self, state_machine)
	var patrol = PatrolState.new(self, state_machine)
	var chase = ChaseState.new(self, state_machine)
	var attack = AttackState.new(self, state_machine)
	var dead = DeadState.new(self, state_machine)
	
	# Initialize state machine with all states
	state_machine.initialize_states(idle, patrol, chase, attack, dead)
	
	if debug_log:
		print("[EarthGolem] State machine initialized with PatrolState")

# ============================================================================
# VISUAL OVERRIDES
# ============================================================================

func remove_slow() -> void:
	"""Override to restore brown color instead of green."""
	if not is_slowed:
		return
	
	is_slowed = false
	current_speed = base_speed
	
	# Restore brown color
	if sprite:
		sprite.color = Color(0.6, 0.4, 0.2)  # Brown
	
	if debug_log:
		print("[%s] Slow removed: speed restored to %f" % [enemy_type, current_speed])

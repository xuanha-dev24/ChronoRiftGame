# slime_basic.gd
# SlimeBasic enemy - Simple melee attacker
# First enemy type for prototype validation
class_name SlimeBasic
extends BaseEnemy

# ============================================================================
# SLIME STATS (Override BaseEnemy defaults)
# ============================================================================

func _init() -> void:
	# Stats
	max_hp = 30
	base_speed = 60.0
	damage = 5
	
	# AI Behavior
	aggro_range = 150.0
	attack_range = 30.0
	attack_cooldown = 1.5
	patrol_radius = 80.0
	
	# Loot
	chrono_dust_drop = 5
	enemy_type = "slime_basic"

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready() -> void:
	# Call parent _ready() first
	super._ready()
	
	# Set sprite color to green
	if sprite:
		sprite.color = Color(0.2, 0.8, 0.2)  # Green
	
	# Initialize state machine with all states
	_initialize_state_machine()
	
	if debug_log:
		print("[SlimeBasic] Initialized at %s" % global_position)

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
		print("[SlimeBasic] State machine initialized with PatrolState")

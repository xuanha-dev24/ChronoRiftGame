# chrono_rift_system.gd
# Manages Chrono Rift time manipulation mechanics
extends Node

enum RiftMode {
	REWIND,      # Rewind player position 3 seconds
	SLOW,        # Slow down time in area
	ACCELERATE   # Speed up player
}

@export var rewind_duration: float = 3.0
@export var slow_time_scale: float = 0.3
@export var accelerate_multiplier: float = 2.0
@export var cooldown_duration: float = 10.0

var position_history: Array[Dictionary] = []
var max_history_size: int = 180  # 3 seconds at 60 FPS
var is_on_cooldown: bool = false
var current_cooldown: float = 0.0

func _ready() -> void:
	EventBus.chrono_rift_used.connect(_on_chrono_rift_used)

func _process(delta: float) -> void:
	# Update cooldown
	if is_on_cooldown:
		current_cooldown -= delta
		if current_cooldown <= 0:
			is_on_cooldown = false
			current_cooldown = 0.0
	
	# Record player position for rewind
	if GameManager.player != null:
		record_player_position()

func record_player_position() -> void:
	if position_history.size() >= max_history_size:
		position_history.pop_front()
	
	position_history.append({
		"position": GameManager.player.global_position,
		"timestamp": Time.get_ticks_msec()
	})

func use_chrono_rift(mode: RiftMode) -> bool:
	if is_on_cooldown:
		print("Chrono Rift on cooldown!")
		return false
	
	match mode:
		RiftMode.REWIND:
			activate_rewind()
		RiftMode.SLOW:
			activate_slow_time()
		RiftMode.ACCELERATE:
			activate_accelerate()
	
	start_cooldown()
	EventBus.chrono_rift_used.emit(RiftMode.keys()[mode])
	return true

func activate_rewind() -> void:
	if position_history.is_empty() or GameManager.player == null:
		return
	
	# Rewind to position from 3 seconds ago
	var target_index = max(0, position_history.size() - int(rewind_duration * 60))
	var rewind_data = position_history[target_index]
	
	GameManager.player.global_position = rewind_data.position
	print("Rewound to position: ", rewind_data.position)
	
	# TODO: Create time echo at current position before rewind

func activate_slow_time() -> void:
	# TODO: Implement area-based time slow effect
	print("Slow time activated!")
	# This would affect enemies and projectiles in a radius

func activate_accelerate() -> void:
	# TODO: Implement player speed boost
	print("Accelerate activated!")
	# This would temporarily increase player move_speed

func start_cooldown() -> void:
	is_on_cooldown = true
	current_cooldown = cooldown_duration

func _on_chrono_rift_used(_type: String) -> void:
	# Prefix unused parameter with underscore to suppress warning
	pass  # Event handler for chrono rift usage

# player_controller.gd
# Main player controller for 8-directional isometric movement
extends CharacterBody2D

@export var move_speed: float = 200.0
@export var acceleration: float = 1500.0
@export var friction: float = 1200.0

var input_vector: Vector2 = Vector2.ZERO
var stats: Node = null

# Isometric direction mapping (for 2.5D)
const ISO_TRANSFORM = Vector2(1, 0.5)

func _ready() -> void:
	# Get PlayerStats node
	stats = get_node_or_null("PlayerStats")
	if stats:
		stats.died.connect(_on_player_died)
	
	# Register with GameManager
	GameManager.register_player(self)

func _physics_process(delta: float) -> void:
	handle_input()
	apply_movement(delta)
	move_and_slide()

func handle_input() -> void:
	input_vector = Vector2.ZERO
	
	if Input.is_action_pressed("move_right"):
		input_vector.x += 1
	if Input.is_action_pressed("move_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("move_down"):
		input_vector.y += 1
	if Input.is_action_pressed("move_up"):
		input_vector.y -= 1
	
	input_vector = input_vector.normalized()
	
	# TODO: Handle attack input
	if Input.is_action_just_pressed("attack"):
		perform_attack()
	
	# TODO: Handle chrono rift input
	if Input.is_action_just_pressed("use_chrono_rift"):
		use_chrono_rift()

func apply_movement(delta: float) -> void:
	if input_vector != Vector2.ZERO:
		# Apply isometric transformation
		var iso_direction = Vector2(
			input_vector.x - input_vector.y,
			(input_vector.x + input_vector.y) * 0.5
		).normalized()
		
		velocity = velocity.move_toward(iso_direction * move_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

func perform_attack() -> void:
	# Placeholder for attack logic
	print("Attack performed!")

func use_chrono_rift() -> void:
	# Placeholder for Chrono Rift integration
	if stats and stats.has_method("use_chrono_rift"):
		stats.use_chrono_rift()
	print("Chrono Rift used!")

func _on_player_died() -> void:
	EventBus.player_died.emit(global_position)
	print("Player died at position: ", global_position)
	# TODO: Trigger death animation and respawn logic

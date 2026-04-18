extends Area2D
class_name HarvestableObject

## Base script for all harvestable objects (trees, rocks, bushes)
## Manages state machine, interaction detection, gathering process, and respawn logic

# State enum for the harvestable object
enum State { NORMAL, INTERACTABLE, GATHERING, DEPLETED }

# Exported properties - resource configuration
@export var resource_type: String = "wood"  ## "wood", "stone", or "meat"
@export var min_resource_amount: int = 50
@export var max_resource_amount: int = 50

# Exported properties - timing configuration
@export var gathering_time: float = 2.0  ## Seconds (randomized 1-3 on spawn)
@export var respawn_time: float = 45.0  ## Seconds (randomized 30-60 on harvest)
@export var interaction_range: float = 50.0  ## Pixels

# Exported properties - visual configuration
@export var normal_color: Color = Color.GREEN
@export var interactable_color: Color = Color.YELLOW
@export var depleted_color: Color = Color.GRAY

# Internal state variables
var current_state: State = State.NORMAL
var player_in_range: bool = false
var player_ref: Node2D = null
var gathering_progress: float = 0.0
var gathering_timer: float = 0.0
var respawn_timer: float = 0.0

# Node references (will be assigned in _ready)
@onready var visual: CanvasItem = $Visual
@onready var interaction_indicator: ColorRect = $InteractionIndicator
@onready var progress_bar: ColorRect = $ProgressBar
@onready var progress_fill: ColorRect = $ProgressBar/Fill
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	# Validate required child nodes exist
	if not has_node("Visual"):
		push_error("[HarvestableObject] Missing Visual node")
		queue_free()
		return
	
	if not has_node("ProgressBar/Fill"):
		push_error("[HarvestableObject] Missing ProgressBar/Fill node")
		queue_free()
		return
	
	if not has_node("InteractionIndicator"):
		push_error("[HarvestableObject] Missing InteractionIndicator node")
		queue_free()
		return
	
	if not has_node("CollisionShape2D"):
		push_error("[HarvestableObject] Missing CollisionShape2D node")
		queue_free()
		return

	_ensure_interaction_shape()
	
	# Randomize gathering and respawn times for variety
	gathering_time = randf_range(1.0, 3.0)
	respawn_time = randf_range(30.0, 60.0)
	
	# Connect Area2D signals for player detection (check if not already connected)
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)
	
	# Initialize visual state
	update_visual_state()
	interaction_indicator.visible = false
	progress_bar.visible = false


func _ensure_interaction_shape() -> void:
	var circle_shape := collision_shape.shape as CircleShape2D
	if circle_shape == null:
		circle_shape = CircleShape2D.new()
		collision_shape.shape = circle_shape
	circle_shape.radius = interaction_range


func _process(delta: float) -> void:
	"""Process state-based logic each frame"""
	match current_state:
		State.INTERACTABLE:
			check_for_interact_input()
		State.GATHERING:
			update_gathering(delta)
		State.DEPLETED:
			update_respawn(delta)


func _on_body_entered(body: Node2D) -> void:
	"""Handle when a body enters the interaction area"""
	if body.is_in_group("player") and current_state == State.NORMAL:
		player_in_range = true
		player_ref = body
		transition_to_state(State.INTERACTABLE)


func _on_body_exited(body: Node2D) -> void:
	"""Handle when a body exits the interaction area"""
	if body.is_in_group("player"):
		player_in_range = false
		player_ref = null
		if current_state == State.INTERACTABLE:
			transition_to_state(State.NORMAL)
		elif current_state == State.GATHERING:
			cancel_gathering()


func transition_to_state(new_state: State) -> void:
	"""Transition to a new state and update visuals"""
	current_state = new_state
	update_visual_state()


func _apply_visual_state(color: Color, alpha: float) -> void:
	if visual is ColorRect:
		var color_rect := visual as ColorRect
		color_rect.color = color
		color_rect.modulate.a = alpha
		return
	visual.modulate = Color(color.r, color.g, color.b, alpha)


func update_visual_state() -> void:
	"""Update visual appearance based on current state"""
	match current_state:
		State.NORMAL:
			_apply_visual_state(normal_color, 1.0)
			interaction_indicator.visible = false
			collision_shape.disabled = false
		State.INTERACTABLE:
			_apply_visual_state(interactable_color, 1.0)
			interaction_indicator.visible = true
			collision_shape.disabled = false
		State.GATHERING:
			_apply_visual_state(interactable_color, 1.0)
			interaction_indicator.visible = false
			collision_shape.disabled = false
		State.DEPLETED:
			_apply_visual_state(depleted_color, 0.5)
			interaction_indicator.visible = false
			collision_shape.disabled = true


func check_for_interact_input() -> void:
	"""Check if the player pressed the interact key"""
	if Input.is_action_just_pressed("interact"):
		start_gathering()


func start_gathering() -> void:
	"""Start the gathering process"""
	transition_to_state(State.GATHERING)
	gathering_progress = 0.0
	gathering_timer = 0.0
	progress_bar.visible = true
	update_progress_bar()


func update_gathering(delta: float) -> void:
	"""Update the gathering process each frame"""
	# Increment gathering timer by delta
	gathering_timer += delta
	
	# Calculate gathering progress as timer / gathering_time
	gathering_progress = gathering_timer / gathering_time
	
	# Update progress bar visual
	update_progress_bar()
	
	# Check if player moved out of range, cancel gathering if true
	if not player_in_range:
		cancel_gathering()
		return
	
	# Check if gathering is complete
	if gathering_progress >= 1.0:
		complete_gathering()


func update_progress_bar() -> void:
	"""Update the progress bar visual to reflect current gathering progress"""
	var fill_width = progress_bar.size.x * gathering_progress
	progress_fill.size.x = fill_width


func cancel_gathering() -> void:
	"""Cancel the gathering process and reset progress"""
	transition_to_state(State.NORMAL)
	gathering_progress = 0.0
	gathering_timer = 0.0
	progress_bar.visible = false


func complete_gathering() -> void:
	"""Complete the gathering process and add resources"""
	# Generate random amount between min and max
	var amount = randi_range(min_resource_amount, max_resource_amount)
	
	# Validate resource_type is one of the valid types
	var valid_types = ["wood", "stone", "gold", "meat"]
	if not resource_type in valid_types:
		print("[HarvestableObject] Invalid resource type: %s" % resource_type)
		# Still transition to depleted state even if resource type is invalid
		transition_to_state(State.DEPLETED)
		progress_bar.visible = false
		respawn_timer = 0.0
		return
	
	# Call ResourceManager to add the resource
	ResourceManager.add_resource(resource_type, amount)
	
	# Transition to DEPLETED state
	transition_to_state(State.DEPLETED)
	
	# Hide progress bar
	progress_bar.visible = false
	
	# Reset respawn timer to 0
	respawn_timer = 0.0


func update_respawn(delta: float) -> void:
	"""Update the respawn timer and respawn when ready"""
	# Increment respawn_timer by delta
	respawn_timer += delta
	
	# Check if respawn_timer >= respawn_time
	if respawn_timer >= respawn_time:
		# Call respawn() when timer expires
		respawn()



func respawn() -> void:
	"""Respawn the harvestable object and return to normal state"""
	# Check if player is still in range and transition to appropriate state
	if player_in_range:
		transition_to_state(State.INTERACTABLE)
	else:
		transition_to_state(State.NORMAL)
	
	# Re-randomize gathering_time (1-3 seconds) for next harvest
	gathering_time = randf_range(1.0, 3.0)
	
	# Re-randomize respawn_time (30-60 seconds) for next respawn
	respawn_time = randf_range(30.0, 60.0)

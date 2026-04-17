extends Structure

## Crafting Station structure - Enables access to crafting recipes
## Players can interact with this structure to open crafting UI

# Interaction state
var player_in_range: bool = false

# Node references
@onready var interaction_indicator: ColorRect = $InteractionIndicator

func _ready() -> void:
	# Set structure properties
	structure_type = "crafting_station"
	max_health = 200
	grid_size = Vector2i(2, 2)
	resource_costs = {"wood": 20, "stone": 15}
	
	# Call parent _ready
	super._ready()
	
	# Validate interaction indicator exists
	if not has_node("InteractionIndicator"):
		push_error("[CraftingStation] Missing InteractionIndicator node")
		return
	
	# Hide interaction indicator initially
	interaction_indicator.visible = false

func _process(_delta: float) -> void:
	# Check for interact input when player is in range
	if player_in_range and Input.is_action_just_pressed("interact"):
		open_crafting_ui()

func _on_body_entered(body: Node2D) -> void:
	"""Handle when a body enters the interaction area"""
	if body.is_in_group("player"):
		player_in_range = true
		if interaction_indicator:
			interaction_indicator.visible = true

func _on_body_exited(body: Node2D) -> void:
	"""Handle when a body exits the interaction area"""
	if body.is_in_group("player"):
		player_in_range = false
		if interaction_indicator:
			interaction_indicator.visible = false

func open_crafting_ui() -> void:
	"""Open the crafting UI (placeholder for now)"""
	EventBus.crafting_station_opened.emit()
	print("[CraftingStation] Crafting UI - Coming Soon")

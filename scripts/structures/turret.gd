extends Structure

## Turret structure - Automated defensive structure with AI targeting
## Automatically scans for and attacks enemies within range

# Reference to AI component
@onready var turret_ai: TurretAI = $TurretAI

func _ready() -> void:
	# Set structure properties
	structure_type = "turret"
	max_health = 150
	grid_size = Vector2i(1, 1)
	resource_costs = {"wood": 15, "stone": 10}
	
	# Call parent _ready
	super._ready()
	
	# Initialize turret AI
	if turret_ai:
		turret_ai.turret = self

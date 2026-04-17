extends Structure

## Wall structure - Basic defensive barrier
## Blocks enemy movement, can be damaged by enemies

func _ready() -> void:
	# Set structure properties
	structure_type = "wall"
	max_health = 100
	grid_size = Vector2i(1, 1)
	resource_costs = {"wood": 10}
	
	# Call parent _ready
	super._ready()

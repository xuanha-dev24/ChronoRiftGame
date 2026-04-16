# inventory_counter.gd
# Inventory counter component for HUD
extends Label

func _ready() -> void:
	# Initialize with default values
	update_count(0, 30)

func update_count(current: int, max: int) -> void:
	"""Update inventory counter display with current and max capacity."""
	text = "Inventory: %d/%d" % [current, max]
	
	# Calculate percentage
	var percentage = float(current) / float(max) if max > 0 else 0.0
	
	# Color code based on capacity
	if percentage >= 1.0:  # 100% full
		modulate = Color.RED
	elif percentage >= 0.9:  # 90% or more
		modulate = Color.ORANGE
	else:  # Less than 90%
		modulate = Color.WHITE

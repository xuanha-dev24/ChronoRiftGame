# resource_display.gd
# Resource display component for HUD
extends VBoxContainer

# Resource row references
var resource_rows: Dictionary = {}

func _ready() -> void:
	# Cache resource row references
	resource_rows["fire_shard"] = get_node_or_null("FireShardRow")
	resource_rows["gold"] = get_node_or_null("GoldRow")
	resource_rows["stone"] = get_node_or_null("StoneRow")
	resource_rows["wood"] = get_node_or_null("WoodRow")
	resource_rows["meat"] = get_node_or_null("MeatRow")
	
	# Initialize all resources to 0
	for resource_type in resource_rows.keys():
		update_resource(resource_type, 0)

func update_resource(type: String, amount: int) -> void:
	"""Update resource display for given type."""
	if not resource_rows.has(type):
		push_error("[ResourceDisplay] Unknown resource type: %s" % type)
		return
	
	var row = resource_rows[type]
	if not row:
		return
	
	# Get row components
	var icon = row.get_node_or_null("Icon")
	var label = row.get_node_or_null("Label")
	
	# Update icon color
	if icon:
		icon.color = _get_resource_color(type)
	
	# Update label text
	if label:
		var resource_name = _get_resource_name(type)
		label.text = "%s: %d" % [resource_name, amount]

func _get_resource_color(type: String) -> Color:
	"""Get color for resource icon."""
	match type:
		"fire_shard":
			return Color.RED
		"gold":
			return Color.YELLOW
		"stone":
			return Color.GRAY
		"wood":
			return Color(0.6, 0.4, 0.2, 1.0)  # Brown
		"meat":
			return Color(1.0, 0.75, 0.8, 1.0)  # Pink
		_:
			return Color.WHITE

func _get_resource_name(type: String) -> String:
	"""Get display name for resource type."""
	match type:
		"fire_shard":
			return "Fire Shard"
		"gold":
			return "Gold"
		"stone":
			return "Stone"
		"wood":
			return "Wood"
		"meat":
			return "Meat"
		_:
			return type.capitalize()

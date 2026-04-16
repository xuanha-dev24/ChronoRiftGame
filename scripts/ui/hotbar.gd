# hotbar.gd
# Hotbar component for quick-access items
extends HBoxContainer

# Cache slot references
var slots: Array[PanelContainer] = []

func _ready() -> void:
	# Cache all slot references
	for i in range(5):
		var slot = get_node_or_null("Slot%d" % (i + 1))
		if slot:
			slots.append(slot)
		else:
			push_error("[Hotbar] Slot%d not found!" % (i + 1))
	
	# Initialize all slots as empty
	for i in range(slots.size()):
		clear_slot(i)

func update_slot(index: int, item_id: String, quantity: int) -> void:
	"""Update hotbar slot with item data."""
	if index < 0 or index >= slots.size():
		push_error("[Hotbar] Invalid slot index: %d" % index)
		return
	
	var slot = slots[index]
	if not slot:
		return
	
	# Get slot components
	var icon = slot.get_node_or_null("Icon")
	var quantity_label = slot.get_node_or_null("QuantityLabel")
	
	if icon:
		# TODO: Load actual item icon texture
		# For now, show colored rect based on item_id
		icon.visible = true
		icon.color = _get_item_color(item_id)
	
	if quantity_label:
		quantity_label.visible = true
		quantity_label.text = str(quantity)

func clear_slot(index: int) -> void:
	"""Clear hotbar slot (set to empty state)."""
	if index < 0 or index >= slots.size():
		return
	
	var slot = slots[index]
	if not slot:
		return
	
	# Get slot components
	var icon = slot.get_node_or_null("Icon")
	var quantity_label = slot.get_node_or_null("QuantityLabel")
	
	if icon:
		icon.visible = false
	
	if quantity_label:
		quantity_label.visible = false
		quantity_label.text = ""

func get_slot_item(index: int) -> Dictionary:
	"""Get item data from slot (placeholder for future implementation)."""
	if index < 0 or index >= slots.size():
		return {}
	
	# TODO: Implement actual item data retrieval
	return {}

func _get_item_color(item_id: String) -> Color:
	"""Get color for item icon (placeholder until we have real icons)."""
	match item_id:
		"health_potion":
			return Color.RED
		"mana_potion":
			return Color.CYAN
		"chrono_dust":
			return Color.YELLOW
		"iron_ore":
			return Color.GRAY
		_:
			return Color.WHITE

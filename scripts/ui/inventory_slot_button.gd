extends Button

var inventory_ui: Control
var slot_owner: String = "player"
var slot_index: int = -1
var item_id: String = ""
var quantity: int = 0
var can_drag_slot: bool = false
var can_drop_slot: bool = false

func _get_drag_data(_at_position: Vector2) -> Variant:
	if not can_drag_slot or item_id.is_empty() or quantity <= 0:
		return null

	if inventory_ui != null and inventory_ui.has_method("begin_slot_drag"):
		inventory_ui.begin_slot_drag(item_id)

	if inventory_ui != null and inventory_ui.has_method("create_drag_preview"):
		var preview = inventory_ui.create_drag_preview(item_id, quantity)
		if preview != null:
			set_drag_preview(preview)

	return {
		"source_owner": slot_owner,
		"source_index": slot_index,
		"item_id": item_id,
		"quantity": quantity
	}

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if not can_drop_slot or inventory_ui == null or not inventory_ui.has_method("can_drop_on_slot"):
		return false
	return inventory_ui.can_drop_on_slot(slot_owner, slot_index, data)

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if inventory_ui != null and inventory_ui.has_method("drop_on_slot"):
		inventory_ui.drop_on_slot(slot_owner, slot_index, data)

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END and inventory_ui != null and inventory_ui.has_method("finish_slot_drag"):
		inventory_ui.finish_slot_drag()
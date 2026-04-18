# player_inventory.gd
# Manages player inventory system
extends Node

signal inventory_updated()

const MAX_INVENTORY_SIZE: int = 30

var inventory: Array = []

func _ready() -> void:
	initialize_inventory()
	if not EventBus.item_picked_up.is_connected(_on_item_picked_up):
		EventBus.item_picked_up.connect(_on_item_picked_up)

func initialize_inventory() -> void:
	inventory.resize(MAX_INVENTORY_SIZE)
	for i in range(MAX_INVENTORY_SIZE):
		inventory[i] = null

func add_item(item_id: String, quantity: int = 1) -> bool:
	if quantity <= 0:
		return false

	var existing_slot := _find_slot_with_item(item_id)
	if existing_slot != -1:
		inventory[existing_slot]["quantity"] += quantity
		notify_inventory_changed()
		return true

	var empty_slot := _find_first_empty_slot()
	if empty_slot != -1:
		inventory[empty_slot] = {
			"id": item_id,
			"quantity": quantity
		}
		notify_inventory_changed()
		return true

	print("Inventory full!")
	return false

func remove_item(item_id: String, quantity: int = 1) -> bool:
	if quantity <= 0:
		return false

	var remaining := quantity
	for i in range(MAX_INVENTORY_SIZE):
		var slot_data = inventory[i]
		if slot_data == null or slot_data.get("id", "") != item_id:
			continue

		var removed_amount: int= min(remaining, int(slot_data.get("quantity", 0)))
		slot_data["quantity"] -= removed_amount
		remaining -= removed_amount
		if slot_data["quantity"] <= 0:
			inventory[i] = null
		if remaining <= 0:
			notify_inventory_changed()
			return true

	return false

func has_item(item_id: String, quantity: int = 1) -> bool:
	for item in inventory:
		if item != null and item.get("id", "") == item_id and item.get("quantity", 0) >= quantity:
			return true
	return false

func get_item_count(item_id: String) -> int:
	var total := 0
	for item in inventory:
		if item != null and item.get("id", "") == item_id:
			total += int(item.get("quantity", 0))
	return total

func get_item(slot_index: int) -> Dictionary:
	if not _is_valid_slot(slot_index):
		return {}
	if inventory[slot_index] == null:
		return {}
	return inventory[slot_index].duplicate(true)

func set_item(slot_index: int, item_data: Dictionary, emit_change: bool = true) -> bool:
	if not _is_valid_slot(slot_index):
		return false

	if item_data.is_empty():
		inventory[slot_index] = null
	else:
		var item_id := str(item_data.get("id", item_data.get("item_id", "")))
		var quantity := int(item_data.get("quantity", 0))
		if item_id.is_empty() or quantity <= 0:
			inventory[slot_index] = null
		else:
			inventory[slot_index] = {
				"id": item_id,
				"quantity": quantity
			}

	if emit_change:
		notify_inventory_changed()
	return true

func clear_slot(slot_index: int, emit_change: bool = true) -> bool:
	return set_item(slot_index, {}, emit_change)

func move_slot_item(from_index: int, to_index: int, emit_change: bool = true) -> bool:
	if not _is_valid_slot(from_index) or not _is_valid_slot(to_index):
		return false
	if from_index == to_index:
		return false

	var source_item = inventory[from_index]
	if source_item == null:
		return false

	var target_item = inventory[to_index]
	if target_item == null:
		inventory[to_index] = source_item.duplicate(true)
		inventory[from_index] = null
	elif target_item.get("id", "") == source_item.get("id", ""):
		target_item["quantity"] += int(source_item.get("quantity", 0))
		inventory[from_index] = null
	else:
		inventory[to_index] = source_item.duplicate(true)
		inventory[from_index] = target_item.duplicate(true)

	if emit_change:
		notify_inventory_changed()
	return true

func get_used_slot_count() -> int:
	var used_slots := 0
	for item in inventory:
		if item != null:
			used_slots += 1
	return used_slots

func has_free_slot() -> bool:
	return _find_first_empty_slot() != -1

func get_save_data() -> Dictionary:
	var inventory_data: Array = []
	for i in range(MAX_INVENTORY_SIZE):
		var slot_data = inventory[i]
		if slot_data == null:
			inventory_data.append(null)
			continue
		inventory_data.append({
			"id": slot_data.get("id", ""),
			"quantity": int(slot_data.get("quantity", 0))
		})

	return {
		"inventory": inventory_data
	}

func load_from_save_data(data: Dictionary, emit_change: bool = true) -> void:
	initialize_inventory()
	var inventory_data: Array = data.get("inventory", [])
	for i in range(min(inventory_data.size(), MAX_INVENTORY_SIZE)):
		var slot_data = inventory_data[i]
		if slot_data == null:
			inventory[i] = null
			continue
		if not (slot_data is Dictionary):
			inventory[i] = null
			continue

		var item_id := str(slot_data.get("id", slot_data.get("item_id", "")))
		var quantity := int(slot_data.get("quantity", 0))
		if item_id.is_empty() or quantity <= 0:
			inventory[i] = null
		else:
			inventory[i] = {
				"id": item_id,
				"quantity": quantity
			}

	if emit_change:
		notify_inventory_changed()

func notify_inventory_changed() -> void:
	inventory_updated.emit()
	EventBus.inventory_changed.emit()

func _on_item_picked_up(item_id: String, quantity: int) -> void:
	var success = add_item(item_id, quantity)
	if success:
		print("Picked up %d x %s" % [quantity, item_id])
	else:
		print("Inventory full! Could not pick up %s" % item_id)

func _find_slot_with_item(item_id: String) -> int:
	for i in range(MAX_INVENTORY_SIZE):
		var item = inventory[i]
		if item != null and item.get("id", "") == item_id:
			return i
	return -1

func _find_first_empty_slot() -> int:
	for i in range(MAX_INVENTORY_SIZE):
		if inventory[i] == null:
			return i
	return -1

func _is_valid_slot(slot_index: int) -> bool:
	return slot_index >= 0 and slot_index < MAX_INVENTORY_SIZE

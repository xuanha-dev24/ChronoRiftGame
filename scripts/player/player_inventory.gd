# player_inventory.gd
# Manages player inventory system
extends Node

signal inventory_updated()

const MAX_INVENTORY_SIZE: int = 30

var inventory: Array[Dictionary] = []

func _ready() -> void:
	EventBus.item_picked_up.connect(_on_item_picked_up)

func add_item(item_id: String, quantity: int = 1) -> bool:
	# Check if item already exists in inventory
	for item in inventory:
		if item.id == item_id:
			item.quantity += quantity
			inventory_updated.emit()
			EventBus.inventory_changed.emit()
			return true
	
	# Add new item if inventory not full
	if inventory.size() < MAX_INVENTORY_SIZE:
		inventory.append({
			"id": item_id,
			"quantity": quantity
		})
		inventory_updated.emit()
		EventBus.inventory_changed.emit()
		return true
	
	print("Inventory full!")
	return false

func remove_item(item_id: String, quantity: int = 1) -> bool:
	for i in range(inventory.size()):
		if inventory[i].id == item_id:
			inventory[i].quantity -= quantity
			if inventory[i].quantity <= 0:
				inventory.remove_at(i)
			inventory_updated.emit()
			EventBus.inventory_changed.emit()
			return true
	return false

func has_item(item_id: String, quantity: int = 1) -> bool:
	for item in inventory:
		if item.id == item_id and item.quantity >= quantity:
			return true
	return false

func get_item_count(item_id: String) -> int:
	for item in inventory:
		if item.id == item_id:
			return item.quantity
	return 0

func _on_item_picked_up(item_id: String, quantity: int) -> void:
	var success = add_item(item_id, quantity)
	if success:
		print("Picked up %d x %s" % [quantity, item_id])
	else:
		print("Inventory full! Could not pick up %s" % item_id)

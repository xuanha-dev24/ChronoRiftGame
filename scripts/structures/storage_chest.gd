extends Structure

## Storage Chest structure - Provides additional inventory capacity
## Players can interact to transfer items between player and chest inventories

# Inventory constants
const INVENTORY_SIZE: int = 20

# Inventory state
var chest_inventory: Array = []

# Interaction state
var player_in_range: bool = false

# Node references
@onready var interaction_indicator: ColorRect = $InteractionIndicator

func _ready() -> void:
	# Set structure properties
	structure_type = "storage_chest"
	max_health = 150
	grid_size = Vector2i(2, 2)
	resource_costs = {"wood": 25}
	
	# Initialize inventory
	initialize_inventory()
	
	# Call parent _ready
	super._ready()
	
	# Validate interaction indicator exists
	if not has_node("InteractionIndicator"):
		push_error("[StorageChest] Missing InteractionIndicator node")
		return
	
	# Hide interaction indicator initially
	interaction_indicator.visible = false

func _process(_delta: float) -> void:
	# Check for interact input when player is in range
	if player_in_range and Input.is_action_just_pressed("interact"):
		open_chest_ui()

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
		# TODO: Close chest UI if open

## Initialize chest inventory with empty slots
func initialize_inventory() -> void:
	chest_inventory.resize(INVENTORY_SIZE)
	for i in range(INVENTORY_SIZE):
		chest_inventory[i] = null
	print("[StorageChest] Initialized inventory with %d slots" % INVENTORY_SIZE)

## Add item to chest inventory
func add_item(item_id: String, quantity: int) -> bool:
	# Try to stack with existing item
	for i in range(INVENTORY_SIZE):
		if chest_inventory[i] != null and chest_inventory[i]["item_id"] == item_id:
			chest_inventory[i]["quantity"] += quantity
			print("[StorageChest] Stacked %d %s (slot %d)" % [quantity, item_id, i])
			return true
	
	# Find empty slot
	for i in range(INVENTORY_SIZE):
		if chest_inventory[i] == null:
			chest_inventory[i] = {
				"item_id": item_id,
				"quantity": quantity
			}
			print("[StorageChest] Added %d %s to slot %d" % [quantity, item_id, i])
			return true
	
	# Inventory full
	print("[StorageChest] Inventory full, cannot add %s" % item_id)
	return false

## Remove item from chest inventory at given slot
func remove_item(slot_index: int) -> Dictionary:
	if slot_index < 0 or slot_index >= INVENTORY_SIZE:
		push_error("[StorageChest] Invalid slot index: %d" % slot_index)
		return {}
	
	if chest_inventory[slot_index] == null:
		return {}
	
	var item_data = chest_inventory[slot_index]
	chest_inventory[slot_index] = null
	print("[StorageChest] Removed %s from slot %d" % [item_data["item_id"], slot_index])
	return item_data

## Get item data at given slot
func get_item(slot_index: int) -> Dictionary:
	if slot_index < 0 or slot_index >= INVENTORY_SIZE:
		push_error("[StorageChest] Invalid slot index: %d" % slot_index)
		return {}
	
	if chest_inventory[slot_index] == null:
		return {}
	
	return chest_inventory[slot_index]

## Check if inventory is full
func is_inventory_full() -> bool:
	for i in range(INVENTORY_SIZE):
		if chest_inventory[i] == null:
			return false
	return true

## Open chest inventory UI
func open_chest_ui() -> void:
	"""Open the chest inventory UI"""
	EventBus.storage_chest_opened.emit(self)
	print("[StorageChest] Chest inventory opened (20 slots)")
	# TODO: Display chest inventory UI (Phase 4)

## Override destroy to drop all items
func destroy() -> void:
	# Drop all items as PickupItems before destroying
	_drop_all_items()
	
	# Call parent destroy
	super.destroy()

## Drop all inventory items as PickupItems
func _drop_all_items() -> void:
	var pickup_item_scene = preload("res://scenes/items/PickupItem.tscn")
	var tree = get_tree()
	if tree == null:
		return

	var drop_parent = tree.current_scene
	if drop_parent == null:
		drop_parent = tree.root

	var ysort_root = drop_parent.get_node_or_null("YSortRoot")
	if ysort_root != null:
		drop_parent = ysort_root
	
	for i in range(INVENTORY_SIZE):
		if chest_inventory[i] != null:
			var item_data = chest_inventory[i]
			var pickup = pickup_item_scene.instantiate()
			pickup.item_id = item_data["item_id"]
			pickup.quantity = item_data["quantity"]
			pickup.global_position = global_position
			
			# Add to scene
			drop_parent.add_child(pickup)
			
			print("[StorageChest] Dropped %d %s" % [item_data["quantity"], item_data["item_id"]])

## Override get_save_data to include inventory
func get_save_data() -> Dictionary:
	var data = super.get_save_data()
	
	# Add inventory data
	var inventory_data = []
	for i in range(INVENTORY_SIZE):
		if chest_inventory[i] != null:
			inventory_data.append({
				"item_id": chest_inventory[i]["item_id"],
				"quantity": chest_inventory[i]["quantity"]
			})
		else:
			inventory_data.append(null)
	
	data["inventory"] = inventory_data
	return data

## Override load_from_data to restore inventory
func load_from_data(data: Dictionary) -> void:
	# Call parent load
	super.load_from_data(data)
	
	# Restore inventory
	if data.has("inventory"):
		var inventory_data = data["inventory"]
		for i in range(min(inventory_data.size(), INVENTORY_SIZE)):
			if inventory_data[i] != null:
				chest_inventory[i] = {
					"item_id": inventory_data[i]["item_id"],
					"quantity": inventory_data[i]["quantity"]
				}
			else:
				chest_inventory[i] = null
		
		print("[StorageChest] Restored inventory from save data")

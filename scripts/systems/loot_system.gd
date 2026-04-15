# loot_system.gd
# Manages item drops when enemies are killed
extends Node

const MAX_ACTIVE_PICKUPS: int = 50
const PICKUP_ITEM_SCENE = preload("res://scenes/items/PickupItem.tscn")

var active_pickups: int = 0
var pickup_mode: String = "automatic"  # or "manual"

func _ready() -> void:
	# Connect to enemy_killed signal
	EventBus.enemy_killed.connect(_on_enemy_killed)
	print("LootSystem initialized - Pickup mode: ", pickup_mode)

func _on_enemy_killed(enemy_type: String, position: Vector2) -> void:
	spawn_loot(enemy_type, position)

func spawn_loot(enemy_type: String, position: Vector2) -> void:
	# Get drop table for this enemy type
	var drop_table = DataManager.get_drop_table(enemy_type)
	
	if drop_table.is_empty():
		# No loot table for this enemy
		return
	
	# Roll for drops
	var dropped_items = roll_for_drops(drop_table)
	
	if dropped_items.is_empty():
		# No items dropped this time
		return
	
	# Spawn each dropped item
	for i in range(dropped_items.size()):
		var item = dropped_items[i]
		var offset_pos = get_offset_position(position, i, dropped_items.size())
		spawn_pickup_item(item["item_id"], item["quantity"], offset_pos)

func roll_for_drops(drop_table: Array) -> Array:
	var dropped_items: Array = []
	
	for entry in drop_table:
		# Roll random float 0.0-1.0
		var roll = randf()
		
		# Check if item drops
		if roll <= entry["chance"]:
			# Roll quantity
			var min_qty = entry["quantity"][0]
			var max_qty = entry["quantity"][1]
			var quantity = randi_range(min_qty, max_qty)
			
			dropped_items.append({
				"item_id": entry["item_id"],
				"quantity": quantity
			})
	
	return dropped_items

func get_offset_position(base_position: Vector2, index: int, total: int) -> Vector2:
	if total == 1:
		return base_position
	
	# Circular offset pattern
	var radius = randf_range(10.0, 30.0)
	var angle = (float(index) / float(total)) * TAU
	
	var offset = Vector2(cos(angle), sin(angle)) * radius
	return base_position + offset

func spawn_pickup_item(item_id: String, quantity: int, position: Vector2) -> void:
	# Check if at maximum pickup limit
	if active_pickups >= MAX_ACTIVE_PICKUPS:
		push_warning("Maximum pickup limit reached (%d). Cannot spawn more items." % MAX_ACTIVE_PICKUPS)
		return
	
	# Instance the pickup item scene
	var pickup_item = PICKUP_ITEM_SCENE.instantiate()
	
	# Set position before adding to tree
	pickup_item.global_position = position
	
	# Add to scene tree FIRST (so _ready() is called and nodes are initialized)
	get_tree().current_scene.add_child(pickup_item)
	
	# Setup item properties AFTER adding to tree (so visual node exists)
	pickup_item.setup(item_id, quantity)
	
	# Increment counter
	active_pickups += 1
	
	# Connect to tree_exited signal to decrement counter
	pickup_item.tree_exited.connect(_on_pickup_removed)
	
	# Add spawn animation
	_add_spawn_animation(pickup_item)

func _add_spawn_animation(pickup_item: Node2D) -> void:
	# Animate from above to spawn position
	var start_pos = pickup_item.global_position + Vector2(0, -20)
	var end_pos = pickup_item.global_position
	
	pickup_item.global_position = start_pos
	
	var tween = pickup_item.create_tween()
	tween.tween_property(pickup_item, "global_position", end_pos, 0.3).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

func _on_pickup_removed() -> void:
	active_pickups -= 1
	if active_pickups < 0:
		active_pickups = 0

func set_pickup_mode(mode: String) -> void:
	if mode in ["automatic", "manual"]:
		pickup_mode = mode
		print("Pickup mode changed to: ", pickup_mode)
	else:
		push_warning("Invalid pickup mode: " + mode)

# Helper method for manual pickup - find closest item to player
func get_closest_pickup_in_range(player_position: Vector2, max_range: float = 50.0) -> Node2D:
	var closest_pickup: Node2D = null
	var closest_distance: float = max_range
	
	# Get all pickup items in the scene
	var pickups = get_tree().get_nodes_in_group("pickups")
	
	for pickup in pickups:
		if pickup is Node2D:
			var distance = player_position.distance_to(pickup.global_position)
			if distance < closest_distance:
				closest_distance = distance
				closest_pickup = pickup
	
	return closest_pickup

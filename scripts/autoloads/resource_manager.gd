# resource_manager.gd
# Global resource management system
# Tracks player resources: fire_shard, gold, stone, wood, meat
extends Node

# Resource storage
var resources: Dictionary = {
	"fire_shard": 0,
	"gold": 0,
	"stone": 0,
	"wood": 0,
	"meat": 0
}

func _ready() -> void:
	print("[ResourceManager] Initialized with resources: ", resources)

## Get the current amount of a specific resource
func get_resource(type: String) -> int:
	if resources.has(type):
		return resources[type]
	else:
		push_warning("[ResourceManager] Unknown resource type: %s" % type)
		return 0

## Add amount to a specific resource (can be negative to subtract)
func add_resource(type: String, amount: int) -> void:
	if not resources.has(type):
		push_warning("[ResourceManager] Unknown resource type: %s" % type)
		return
	
	resources[type] += amount
	
	# Clamp to minimum 0 (no negative resources)
	if resources[type] < 0:
		resources[type] = 0
	
	# Emit signal for HUD update
	EventBus.resource_changed.emit(type, resources[type])
	
	print("[ResourceManager] %s changed: %d (delta: %+d)" % [type, resources[type], amount])

## Set a specific resource to an exact amount
func set_resource(type: String, amount: int) -> void:
	if not resources.has(type):
		push_warning("[ResourceManager] Unknown resource type: %s" % type)
		return
	
	# Clamp to minimum 0
	amount = max(0, amount)
	
	resources[type] = amount
	
	# Emit signal for HUD update
	EventBus.resource_changed.emit(type, resources[type])
	
	print("[ResourceManager] %s set to: %d" % [type, resources[type]])

## Check if player has enough of a resource
func has_resource(type: String, amount: int) -> bool:
	return get_resource(type) >= amount

## Spend resources (returns true if successful, false if not enough)
func spend_resource(type: String, amount: int) -> bool:
	if has_resource(type, amount):
		add_resource(type, -amount)
		return true
	else:
		print("[ResourceManager] Not enough %s. Have: %d, Need: %d" % [type, get_resource(type), amount])
		return false

## Get all resources as a dictionary (for saving/loading)
func get_all_resources() -> Dictionary:
	return resources.duplicate()

## Set all resources from a dictionary (for saving/loading)
func set_all_resources(new_resources: Dictionary) -> void:
	for type in new_resources:
		if resources.has(type):
			set_resource(type, new_resources[type])

## Reset all resources to zero
func reset_resources() -> void:
	for type in resources.keys():
		set_resource(type, 0)
	print("[ResourceManager] All resources reset to 0")

extends Node

## HarvestableObjectSpawner
## Spawns harvestable objects (trees, rocks, bushes) at random valid positions on the map.
## Ensures objects maintain minimum spacing and stay within map bounds.

# Scene references for harvestable objects
@export var tree_scene: PackedScene
@export var rock_scene: PackedScene
@export var bush_scene: PackedScene

# Spawn configuration
@export var min_spawn_count: int = 5  # Minimum of each type to spawn
@export var map_size: Vector2 = Vector2(960, 960)  # 30x30 tiles * 32 pixels
@export var spawn_margin: float = 50.0  # Distance from map edges
@export var min_object_spacing: float = 80.0  # Minimum distance between objects

# Track spawned positions to enforce spacing
var spawned_positions: Array[Vector2] = []

func _ready() -> void:
	"""Called when the spawner is added to the scene tree. Spawns all harvestable objects."""
	spawn_objects()


func spawn_objects() -> void:
	"""Spawns minimum count of each harvestable object type (trees, rocks, bushes)."""
	spawn_object_type(tree_scene, min_spawn_count)
	spawn_object_type(rock_scene, min_spawn_count)
	spawn_object_type(bush_scene, min_spawn_count)


func spawn_object_type(scene: PackedScene, count: int) -> void:
	"""
	Spawns 'count' instances of the given scene at valid positions.
	
	Args:
		scene: The PackedScene to instantiate (Tree, Rock, or Bush)
		count: Number of instances to spawn
	"""
	if scene == null:
		push_warning("[HarvestableObjectSpawner] Scene is null, skipping spawn")
		return
	
	for i in range(count):
		var position = get_valid_spawn_position()
		var instance = scene.instantiate()
		instance.global_position = position
		spawned_positions.append(position)
		
		# Add to YSortRoot for proper visual layering
		var ysort_root = get_parent().get_node("YSortRoot")
		if ysort_root:
			ysort_root.add_child(instance)
		else:
			push_error("[HarvestableObjectSpawner] YSortRoot node not found")


func get_valid_spawn_position() -> Vector2:
	"""
	Generates a random position within map bounds that maintains minimum spacing from other objects.
	
	Returns:
		A valid Vector2 position, or a fallback position if no valid position found after max attempts
	"""
	var max_attempts = 50
	
	for attempt in range(max_attempts):
		var pos = Vector2(
			randf_range(spawn_margin, map_size.x - spawn_margin),
			randf_range(spawn_margin, map_size.y - spawn_margin)
		)
		
		if is_position_valid(pos):
			return pos
	
	# Fallback: return center of map with random offset
	push_warning("[HarvestableObjectSpawner] Could not find valid position after %d attempts, using fallback" % max_attempts)
	return map_size / 2 + Vector2(randf_range(-100, 100), randf_range(-100, 100))


func is_position_valid(pos: Vector2) -> bool:
	"""
	Checks if a position maintains minimum spacing from all previously spawned objects.
	
	Args:
		pos: The position to validate
		
	Returns:
		true if position is valid (maintains min_object_spacing), false otherwise
	"""
	for spawned_pos in spawned_positions:
		var distance = pos.distance_to(spawned_pos)
		if distance < min_object_spacing:
			return false
	
	return true

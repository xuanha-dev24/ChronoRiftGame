extends Area2D
class_name Structure

## Base class for all placeable structures (Wall, Turret, Crafting_Station, Storage_Chest)
## Manages health system, visual feedback, collision detection, and save/load interface

# Structure properties
@export var structure_type: String = "wall"
@export var max_health: int = 100
@export var grid_size: Vector2i = Vector2i(1, 1)
@export var resource_costs: Dictionary = {"wood": 10}

# Runtime state
var current_health: int = 100
var grid_position: Vector2i = Vector2i(0, 0)
var is_destroyed: bool = false

# Node references (assigned in _ready)
@onready var visual: ColorRect = $Visual
@onready var health_bar: ColorRect = $HealthBar
@onready var health_bar_fill: ColorRect = $HealthBar/Fill
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	# Validate required child nodes exist
	if not has_node("Visual"):
		push_error("[Structure] Missing Visual node")
		queue_free()
		return
	
	if not has_node("HealthBar"):
		push_error("[Structure] Missing HealthBar node")
		queue_free()
		return
	
	if not has_node("HealthBar/Fill"):
		push_error("[Structure] Missing HealthBar/Fill node")
		queue_free()
		return
	
	if not has_node("CollisionShape2D"):
		push_error("[Structure] Missing CollisionShape2D node")
		queue_free()
		return
	
	# Set collision layer and mask
	# Layer 4: Structures
	# Mask 3: Player (layer 1) + Enemies (layer 2)
	collision_layer = 4
	collision_mask = 3
	
	# Add to structures group
	add_to_group("structures")
	
	# Initialize health bar
	update_health_bar()
	update_visual_feedback()

## Initialize structure at given grid position
func initialize(grid_pos: Vector2i) -> void:
	grid_position = grid_pos
	current_health = max_health
	is_destroyed = false
	
	# Align the structure to the center of its full footprint, not just the top-left cell.
	global_position = Building_System.get_placement_world_position(grid_pos, grid_size)
	
	# Register with Building_System
	Building_System.register_structure(grid_pos, self)
	
	print("[Structure] Initialized %s at grid %s (world %s)" % [structure_type, grid_pos, global_position])

## Apply damage to structure
func take_damage(amount: int) -> void:
	if is_destroyed:
		return
	
	current_health = max(current_health - amount, 0)
	
	print("[Structure] %s took %d damage (HP: %d/%d)" % [structure_type, amount, current_health, max_health])
	
	# Update visuals
	update_health_bar()
	update_visual_feedback()
	
	# Flash white for damage feedback
	_flash_damage()
	
	# Check if destroyed
	if current_health <= 0:
		destroy()

## Update health bar visual
func update_health_bar() -> void:
	if not health_bar or not health_bar_fill:
		return
	
	var health_percentage = float(current_health) / float(max_health)
	health_bar_fill.size.x = health_bar.size.x * health_percentage

## Update visual feedback based on health percentage
func update_visual_feedback() -> void:
	if not visual:
		return
	
	var health_percentage = float(current_health) / float(max_health)
	
	# Color modulation based on health
	if health_percentage > 0.66:
		visual.modulate = Color(1, 1, 1)  # White (normal)
	elif health_percentage > 0.33:
		visual.modulate = Color(1, 1, 0)  # Yellow (damaged)
	else:
		visual.modulate = Color(1, 0, 0)  # Red (critical)

## Flash white for damage feedback
func _flash_damage() -> void:
	if not visual:
		return
	
	# Store original modulation
	var original_modulation = visual.modulate
	
	# Flash white
	visual.modulate = Color(1, 1, 1)
	
	# Create tween to restore original color after 0.1 seconds
	var tween = create_tween()
	tween.tween_property(visual, "modulate", original_modulation, 0.1)

## Destroy structure
func destroy() -> void:
	if is_destroyed:
		return
	
	is_destroyed = true
	
	print("[Structure] %s destroyed at grid %s" % [structure_type, grid_position])
	
	# Unregister from Building_System
	Building_System.unregister_structure(grid_position)
	
	# Emit signal
	EventBus.structure_destroyed.emit(structure_type, global_position)
	
	# TODO: Play destruction particle effect (Phase 10)
	
	# Remove from scene
	queue_free()

## Get save data for persistence
func get_save_data() -> Dictionary:
	return {
		"type": structure_type,
		"grid_position": {"x": grid_position.x, "y": grid_position.y},
		"current_health": current_health,
		"rotation": rotation_degrees
	}

## Load structure from save data
func load_from_data(data: Dictionary) -> void:
	if data.has("grid_position"):
		var grid_pos_data = data["grid_position"]
		grid_position = Vector2i(grid_pos_data["x"], grid_pos_data["y"])
	
	if data.has("current_health"):
		current_health = data["current_health"]
	
	if data.has("rotation"):
		rotation_degrees = data["rotation"]
	
	# Update visuals
	update_health_bar()
	update_visual_feedback()
	
	print("[Structure] Loaded %s from save data at grid %s (HP: %d/%d)" % [structure_type, grid_position, current_health, max_health])

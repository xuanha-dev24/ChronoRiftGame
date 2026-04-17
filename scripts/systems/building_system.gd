# building_system.gd
# Global building system for structure placement and management
# Manages build mode, structure selection, placement validation, and structure registry
extends Node

# Build mode state
var build_mode_active: bool = false
var selected_structure_type: String = ""
var placement_preview: Node2D = null

# Structure registry
var structures: Dictionary = {}  # Key: Vector2i grid_pos, Value: Structure node
var structure_count: int = 0
var spatial_grid: Dictionary = {}  # Key: Vector2i sector, Value: Array of structures

# Constants
const MAX_STRUCTURES: int = 100
const GRID_SIZE: int = 16  # pixels per grid cell
const MAP_SIZE: int = 30  # 30x30 grid
const SECTOR_SIZE: int = 5  # 5x5 cells per sector (30/5 = 6 sectors per dimension)

# Structure data loaded from JSON
var structure_data: Dictionary = {}

func _ready() -> void:
	print("[Building_System] Initialized")
	load_structure_data()

func _get_scene_root() -> Node:
	var tree = get_tree()
	if tree == null:
		return null
	if tree.current_scene != null:
		return tree.current_scene
	return tree.root

func _get_structure_parent() -> Node:
	var scene_root = _get_scene_root()
	if scene_root == null:
		return null

	var ysort_root = scene_root.get_node_or_null("YSortRoot")
	if ysort_root != null:
		return ysort_root

	return scene_root

func _get_structure_grid_position(structure: Object, fallback: Vector2i) -> Vector2i:
	if structure == null:
		return fallback

	var grid_position_value = structure.get("grid_position")
	if grid_position_value is Vector2i:
		return grid_position_value

	if structure.has_meta("grid_position"):
		grid_position_value = structure.get_meta("grid_position")
		if grid_position_value is Vector2i:
			return grid_position_value

	return fallback

func _get_structure_grid_size(structure: Object) -> Vector2i:
	if structure == null:
		return Vector2i.ONE

	var grid_size_value = structure.get("grid_size")
	if grid_size_value is Vector2i:
		return grid_size_value

	if structure.has_meta("grid_size"):
		grid_size_value = structure.get_meta("grid_size")
		if grid_size_value is Vector2i:
			return grid_size_value

	return Vector2i.ONE

func _process(_delta: float) -> void:
	# Update preview position when structure is selected
	if selected_structure_type != "" and placement_preview != null:
		var mouse_pos = _get_world_mouse_position()
		update_preview_position(mouse_pos)

func _input(event: InputEvent) -> void:
	# Handle build mode toggle
	if event.is_action_pressed("toggle_build_mode"):
		toggle_build_mode()
	
	# Handle structure placement
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Check if demolish key (X) is held
			if Input.is_key_pressed(KEY_X) and build_mode_active:
				# Demolish structure at mouse position
				var mouse_pos = _get_world_mouse_position()
				var grid_pos = world_to_grid(mouse_pos)
				demolish_structure(grid_pos)
			elif selected_structure_type != "" and placement_preview != null:
				# Place structure
				var mouse_pos = _get_world_mouse_position()
				var grid_pos = world_to_grid(mouse_pos)
				place_structure(grid_pos)
		
		# Handle structure cancellation (right mouse button)
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if selected_structure_type != "":
				deselect_structure()
	
	# Handle structure cancellation (Escape key)
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE and event.pressed:
			if selected_structure_type != "":
				deselect_structure()

## Load structure definitions from data/structures.json
func load_structure_data() -> void:
	var file_path = "res://data/structures.json"
	if not FileAccess.file_exists(file_path):
		push_error("[Building_System] structures.json not found at: %s" % file_path)
		return
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("[Building_System] Failed to open structures.json")
		return
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		push_error("[Building_System] Failed to parse structures.json: %s" % json.get_error_message())
		return
	
	structure_data = json.data
	print("[Building_System] Loaded structure data: ", structure_data.keys())

## Toggle build mode on/off
func toggle_build_mode() -> void:
	build_mode_active = not build_mode_active
	
	if not build_mode_active:
		# Deselect structure when exiting build mode
		deselect_structure()
	
	EventBus.build_mode_changed.emit(build_mode_active)
	print("[Building_System] Build mode: %s" % ("ACTIVE" if build_mode_active else "INACTIVE"))

## Select a structure type for placement
func select_structure(type: String) -> void:
	if not structure_data.has(type):
		print("[Building_System] Invalid structure type: %s" % type)
		return
	
	selected_structure_type = type
	print("[Building_System] Selected structure: %s" % type)
	
	# Create placement preview if it doesn't exist
	if placement_preview == null:
		var preview_scene = load("res://scenes/ui/Placement_Preview.tscn")
		if preview_scene == null:
			push_error("[Building_System] Failed to load placement preview scene")
			return

		placement_preview = preview_scene.instantiate()
		var preview_parent = _get_scene_root()
		if preview_parent == null:
			push_error("[Building_System] Unable to find a parent for placement preview")
			placement_preview = null
			return

		preview_parent.add_child(placement_preview)
	
	# Set structure type on preview
	placement_preview.set_structure_type(type)
	placement_preview.show_preview()

## Deselect current structure
func deselect_structure() -> void:
	selected_structure_type = ""
	
	if placement_preview != null:
		placement_preview.queue_free()
		placement_preview = null
	
	# Clear Build_UI button highlights
	var build_ui = get_tree().get_first_node_in_group("build_ui")
	if build_ui and build_ui.has_method("clear_button_highlights"):
		build_ui.clear_button_highlights()
	
	print("[Building_System] Structure deselected")

## Convert world position to grid coordinates
func world_to_grid(world_pos: Vector2) -> Vector2i:
	return Vector2i(
		int(floor(world_pos.x / GRID_SIZE)),
		int(floor(world_pos.y / GRID_SIZE))
	)

## Convert grid coordinates to world position (center of cell)
func grid_to_world(grid_pos: Vector2i) -> Vector2:
	return Vector2(
		grid_pos.x * GRID_SIZE + GRID_SIZE / 2.0,
		grid_pos.y * GRID_SIZE + GRID_SIZE / 2.0
	)

## Get world mouse position (convert from viewport to world coordinates)
func _get_world_mouse_position() -> Vector2:
	var viewport = get_viewport()
	if viewport == null:
		return Vector2.ZERO
	
	# Get viewport mouse position
	var mouse_viewport_pos = viewport.get_mouse_position()
	
	# Get camera
	var camera = get_tree().get_first_node_in_group("camera") as Camera2D
	if camera == null:
		# No camera found, return viewport position directly
		return mouse_viewport_pos
	
	# Convert viewport position to world position
	# Formula: world_pos = camera_pos + (viewport_pos - viewport_center) / camera_zoom
	var viewport_center = viewport.get_visible_rect().size / 2.0
	var offset = (mouse_viewport_pos - viewport_center) / camera.zoom
	var world_pos = camera.global_position + offset
	
	return world_pos

## Check if all grid cells occupied by structure are within map bounds
func is_within_bounds(grid_pos: Vector2i, grid_size: Vector2i) -> bool:
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var cell = grid_pos + Vector2i(x, y)
			if cell.x < 0 or cell.x >= MAP_SIZE or cell.y < 0 or cell.y >= MAP_SIZE:
				return false
	return true

## Check if structure overlaps with existing structures (optimized with spatial partitioning)
func check_overlap_with_structures(grid_pos: Vector2i, grid_size: Vector2i) -> bool:
	# Use spatial partitioning to only check structures in relevant sectors
	var nearby_structures = get_structures_in_sectors(grid_pos, grid_size)
	if nearby_structures.is_empty() and not structures.is_empty():
		var seen_structures = {}
		for structure in structures.values():
			if structure == null:
				continue

			var structure_id = structure.get_instance_id()
			if seen_structures.has(structure_id):
				continue

			seen_structures[structure_id] = true
			nearby_structures.append(structure)
	
	for structure in nearby_structures:
		if not is_instance_valid(structure):
			continue

		var structure_grid_size = _get_structure_grid_size(structure)
		var structure_grid_position = _get_structure_grid_position(structure, grid_pos)
		
		# Check if any cell of the new structure overlaps with this structure
		for x in range(grid_size.x):
			for y in range(grid_size.y):
				var cell = grid_pos + Vector2i(x, y)
				
				# Check if this cell overlaps with the existing structure
				for sx in range(structure_grid_size.x):
					for sy in range(structure_grid_size.y):
						var structure_cell = structure_grid_position + Vector2i(sx, sy)
						if cell == structure_cell:
							return true  # Overlap detected
	
	return false

## Check if structure overlaps with harvestable objects
func check_overlap_with_harvestables(grid_pos: Vector2i, grid_size: Vector2i) -> bool:
	# Get all harvestable objects in the scene
	var harvestables = get_tree().get_nodes_in_group("harvestable")
	
	for harvestable in harvestables:
		var harvestable_grid_pos = world_to_grid(harvestable.global_position)
		
		# Check if any cell of the structure overlaps with the harvestable
		for x in range(grid_size.x):
			for y in range(grid_size.y):
				var cell = grid_pos + Vector2i(x, y)
				if cell == harvestable_grid_pos:
					return true  # Overlap detected
	
	return false

## Update preview position based on mouse position
func update_preview_position(mouse_pos: Vector2) -> void:
	if placement_preview == null or selected_structure_type == "":
		return
	
	# Get structure data
	var data = structure_data[selected_structure_type]
	var grid_size = Vector2i(data["grid_size"]["x"], data["grid_size"]["y"])
	
	# Convert mouse position to grid coordinates
	var grid_pos = world_to_grid(mouse_pos)
	
	# Update preview position (snapped to grid)
	placement_preview.update_position(mouse_pos)
	
	# Validate placement at this position
	var validation = validate_placement(grid_pos, grid_size)
	
	# Update preview color based on validation
	placement_preview.set_valid(validation["valid"])

## Place structure at given grid position
func place_structure(grid_pos: Vector2i) -> bool:
	if selected_structure_type == "":
		return false
	
	# Get structure data
	if not structure_data.has(selected_structure_type):
		push_error("[Building_System] Invalid structure type: %s" % selected_structure_type)
		return false
	
	var data = structure_data[selected_structure_type]
	var grid_size = Vector2i(data["grid_size"]["x"], data["grid_size"]["y"])
	
	# Validate placement
	var validation = validate_placement(grid_pos, grid_size)
	if not validation["valid"]:
		print("[Building_System] Cannot place structure: %s" % validation["error"])
		
		# Show error message in Build_UI
		var build_ui = get_tree().get_first_node_in_group("build_ui")
		if build_ui and build_ui.has_method("show_error_message"):
			build_ui.show_error_message(validation["error"])
		
		return false
	
	# Deduct resources
	var costs = data.get("costs", {})
	for resource_type in costs:
		var amount = costs[resource_type]
		if not ResourceManager.spend_resource(resource_type, amount):
			print("[Building_System] Failed to deduct resources")
			return false
	
	# Instantiate structure scene
	var scene_path = data["scene_path"]
	var structure_scene = load(scene_path)
	if structure_scene == null:
		push_error("[Building_System] Failed to load structure scene: %s" % scene_path)
		return false
	
	var structure = structure_scene.instantiate()

	var structure_parent = _get_structure_parent()
	if structure_parent == null:
		push_error("[Building_System] No valid parent found for structure placement")
		structure.queue_free()
		return false

	structure_parent.add_child(structure)
	structure.initialize(grid_pos)
	
	# Check if approaching structure limit (50+ structures)
	if structure_count >= 50 and structure_count < MAX_STRUCTURES:
		var warning_message = "Approaching structure limit (%d/%d)" % [structure_count, MAX_STRUCTURES]
		print("[Building_System] WARNING: %s" % warning_message)
		
		# Show warning in Build_UI
		var build_ui = get_tree().get_first_node_in_group("build_ui")
		if build_ui and build_ui.has_method("show_error_message"):
			build_ui.show_error_message(warning_message)
	
	# Emit signal
	EventBus.structure_placed.emit(selected_structure_type, structure.global_position)
	
	print("[Building_System] Placed %s at grid %s (world %s)" % [selected_structure_type, grid_pos, structure.global_position])
	
	return true

## Validate placement at given position
func validate_placement(grid_pos: Vector2i, grid_size: Vector2i) -> Dictionary:
	# Check bounds
	if not is_within_bounds(grid_pos, grid_size):
		return {"valid": false, "error": "Cannot place here: Out of bounds"}
	
	# Check overlap with structures
	if check_overlap_with_structures(grid_pos, grid_size):
		return {"valid": false, "error": "Cannot place here: Overlapping with existing structure"}
	
	# Check overlap with harvestables
	if check_overlap_with_harvestables(grid_pos, grid_size):
		return {"valid": false, "error": "Cannot place here: Overlapping with harvestable object"}
	
	# Check structure limit
	if structure_count >= MAX_STRUCTURES:
		return {"valid": false, "error": "Structure limit reached (100/100)"}
	
	# Check resources (will be implemented in Phase 5)
	if selected_structure_type != "":
		var costs = structure_data[selected_structure_type].get("costs", {})
		for resource_type in costs:
			var amount = costs[resource_type]
			if not ResourceManager.has_resource(resource_type, amount):
				return {"valid": false, "error": "Insufficient resources"}
	
	return {"valid": true, "error": ""}

## Get structure at given grid position
func get_structure_at_position(grid_pos: Vector2i) -> Node2D:
	return structures.get(grid_pos, null)

## Register structure in the structures dictionary
func register_structure(grid_pos: Vector2i, structure: Node2D) -> void:
	if structure == null:
		return

	var structure_grid_pos = _get_structure_grid_position(structure, grid_pos)
	var structure_grid_size = _get_structure_grid_size(structure)
	var added_any_cell = false

	for x in range(structure_grid_size.x):
		for y in range(structure_grid_size.y):
			var cell = structure_grid_pos + Vector2i(x, y)
			if structures.get(cell, null) == structure:
				continue

			structures[cell] = structure
			added_any_cell = true

	if added_any_cell:
		structure_count += 1
		add_to_spatial_grid(structure, structure_grid_pos, structure_grid_size)
		print("[Building_System] Registered structure at %s (count: %d/%d)" % [structure_grid_pos, structure_count, MAX_STRUCTURES])

## Unregister structure from the structures dictionary
func unregister_structure(grid_pos: Vector2i) -> void:
	# For multi-cell structures, we need to remove all cells
	# First, get the structure reference
	var structure = structures.get(grid_pos, null)
	if structure == null:
		return

	var structure_grid_pos = _get_structure_grid_position(structure, grid_pos)
	var grid_size = _get_structure_grid_size(structure)
	
	# Remove from spatial grid
	remove_from_spatial_grid(structure, structure_grid_pos, grid_size)
	
	# Remove all cells occupied by this structure
	var cells_removed = 0
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var cell = structure_grid_pos + Vector2i(x, y)
			if structures.get(cell, null) == structure:
				structures.erase(cell)
				cells_removed += 1
	
	# Decrement structure count only once
	if cells_removed > 0:
		structure_count = max(structure_count - 1, 0)
		print("[Building_System] Unregistered structure at %s (count: %d/%d)" % [structure_grid_pos, structure_count, MAX_STRUCTURES])

## Demolish structure at given grid position
func demolish_structure(grid_pos: Vector2i) -> void:
	# Get structure at position
	var structure = get_structure_at_position(grid_pos)
	if structure == null:
		print("[Building_System] No structure at grid %s to demolish" % grid_pos)
		return
	
	# Get structure type and costs for refund calculation
	var structure_type = structure.structure_type
	var costs = structure.resource_costs
	
	# Calculate 50% refund (rounded down)
	for resource_type in costs:
		var cost = costs[resource_type]
		var refund_amount = int(cost * 0.5)
		ResourceManager.add_resource(resource_type, refund_amount)
		print("[Building_System] Refunded %d %s (50%% of %d)" % [refund_amount, resource_type, cost])
	
	# Emit signal before removing structure
	EventBus.structure_demolished.emit(structure_type, structure.global_position)
	
	# Remove structure from structures dictionary
	unregister_structure(grid_pos)
	
	# Remove structure from scene
	structure.queue_free()
	
	print("[Building_System] Demolished %s at grid %s" % [structure_type, grid_pos])

## Load structure from save data
func load_structure_from_data(data: Dictionary) -> bool:
	# Get structure type
	var structure_type = data["type"]
	
	# Check if structure type exists
	if not structure_data.has(structure_type):
		push_error("[Building_System] Unknown structure type: %s" % structure_type)
		return false
	
	# Get structure definition
	var structure_def = structure_data[structure_type]
	
	# Instantiate structure scene
	var scene_path = structure_def["scene_path"]
	var structure_scene = load(scene_path)
	if structure_scene == null:
		push_error("[Building_System] Failed to load structure scene: %s" % scene_path)
		return false
	
	var structure = structure_scene.instantiate()
	
	var structure_parent = _get_structure_parent()
	if structure_parent == null:
		push_error("[Building_System] No valid parent found for loaded structure")
		structure.queue_free()
		return false

	structure_parent.add_child(structure)

	# Load structure data (sets grid_position, current_health, rotation)
	structure.load_from_data(data)
	
	# Set world position based on grid position
	structure.global_position = grid_to_world(structure.grid_position)

	# Check if any cell is already occupied before registering
	var grid_size = structure.grid_size
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var cell = structure.grid_position + Vector2i(x, y)
			if structures.has(cell):
				push_warning("[Building_System] Cell %s already occupied, skipping structure load" % cell)
				structure.queue_free()
				return false

	register_structure(structure.grid_position, structure)
	
	print("[Building_System] Loaded %s at grid %s (HP: %d/%d)" % [structure_type, structure.grid_position, structure.current_health, structure.max_health])
	
	return true

## Get sector coordinates from grid position
func get_sector(grid_pos: Vector2i) -> Vector2i:
	return Vector2i(
		int(floor(float(grid_pos.x) / SECTOR_SIZE)),
		int(floor(float(grid_pos.y) / SECTOR_SIZE))
	)

## Get all sectors that a structure occupies
func get_occupied_sectors(grid_pos: Vector2i, grid_size: Vector2i) -> Array:
	var sectors = []
	var seen_sectors = {}
	
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var cell = grid_pos + Vector2i(x, y)
			var sector = get_sector(cell)
			
			# Avoid duplicates
			var sector_key = "%d,%d" % [sector.x, sector.y]
			if not seen_sectors.has(sector_key):
				sectors.append(sector)
				seen_sectors[sector_key] = true
	
	return sectors

## Add structure to spatial grid
func add_to_spatial_grid(structure: Node2D, grid_pos: Vector2i, grid_size: Vector2i) -> void:
	var sectors = get_occupied_sectors(grid_pos, grid_size)
	
	for sector in sectors:
		if not spatial_grid.has(sector):
			spatial_grid[sector] = []
		
		if not spatial_grid[sector].has(structure):
			spatial_grid[sector].append(structure)

## Remove structure from spatial grid
func remove_from_spatial_grid(structure: Node2D, grid_pos: Vector2i, grid_size: Vector2i) -> void:
	var sectors = get_occupied_sectors(grid_pos, grid_size)
	
	for sector in sectors:
		if spatial_grid.has(sector):
			spatial_grid[sector].erase(structure)
			
			# Clean up empty sectors
			if spatial_grid[sector].is_empty():
				spatial_grid.erase(sector)

## Get structures in relevant sectors (optimized collision check)
func get_structures_in_sectors(grid_pos: Vector2i, grid_size: Vector2i) -> Array:
	var sectors = get_occupied_sectors(grid_pos, grid_size)
	var structures_in_area = []
	var seen_structures = {}
	
	for sector in sectors:
		if spatial_grid.has(sector):
			for structure in spatial_grid[sector]:
				# Avoid duplicates
				var structure_id = structure.get_instance_id()
				if not seen_structures.has(structure_id):
					structures_in_area.append(structure)
					seen_structures[structure_id] = true
	
	return structures_in_area

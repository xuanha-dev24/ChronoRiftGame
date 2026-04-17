# placement_preview.gd
# Visual preview for structure placement
# Shows ghost sprite with green/red color feedback for valid/invalid placement
extends Node2D

# Node references
@onready var visual: ColorRect = $Visual
@onready var grid_indicator: Node2D = $GridIndicator

# Current structure properties
var structure_type: String = ""
var grid_size: Vector2i = Vector2i(1, 1)
var is_valid: bool = false

# Grid cell visuals for multi-cell structures
var grid_cells: Array[ColorRect] = []

func _ready() -> void:
	print("[Placement_Preview] Initialized")

## Set the structure type and update visual
func set_structure_type(type: String) -> void:
	structure_type = type
	
	# Get structure data from Building_System
	if not Building_System.structure_data.has(type):
		push_error("[Placement_Preview] Invalid structure type: %s" % type)
		return
	
	var data = Building_System.structure_data[type]
	grid_size = Vector2i(data["grid_size"]["x"], data["grid_size"]["y"])
	
	# Update visual size
	_update_visual_size()
	
	# Create grid indicators for multi-cell structures
	_create_grid_indicators()
	
	print("[Placement_Preview] Set structure type: %s (size: %s)" % [type, grid_size])

## Update position based on mouse position (follow mouse directly, no grid snapping)
func update_position(mouse_pos: Vector2) -> void:
	# Update preview position to follow mouse directly
	global_position = mouse_pos

## Set whether the current position is valid for placement
func set_valid(valid: bool) -> void:
	is_valid = valid
	
	# Update color based on validity
	if valid:
		_set_color(Color(0, 1, 0, 0.5))  # Green, 50% opacity
	else:
		_set_color(Color(1, 0, 0, 0.5))  # Red, 50% opacity

## Show the preview
func show_preview() -> void:
	visible = true
	print("[Placement_Preview] Preview shown")

## Hide the preview
func hide_preview() -> void:
	visible = false
	print("[Placement_Preview] Preview hidden")

## Update visual size based on grid_size
func _update_visual_size() -> void:
	if not visual:
		return
	
	var pixel_size = grid_size * Building_System.GRID_SIZE
	
	# Center the visual on the preview node
	visual.offset_left = -pixel_size.x / 2.0
	visual.offset_top = -pixel_size.y / 2.0
	visual.offset_right = pixel_size.x / 2.0
	visual.offset_bottom = pixel_size.y / 2.0

## Create grid cell indicators for multi-cell structures
func _create_grid_indicators() -> void:
	# Clear existing grid cells
	for cell in grid_cells:
		cell.queue_free()
	grid_cells.clear()
	
	# Only create indicators for multi-cell structures (2x2 or larger)
	if grid_size.x <= 1 and grid_size.y <= 1:
		return
	
	# Create a ColorRect for each grid cell
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var cell_rect = ColorRect.new()
			cell_rect.size = Vector2(Building_System.GRID_SIZE, Building_System.GRID_SIZE)
			
			# Position relative to preview center
			var offset_x = (x - grid_size.x / 2.0) * Building_System.GRID_SIZE + Building_System.GRID_SIZE / 2.0
			var offset_y = (y - grid_size.y / 2.0) * Building_System.GRID_SIZE + Building_System.GRID_SIZE / 2.0
			cell_rect.position = Vector2(offset_x, offset_y) - Vector2(Building_System.GRID_SIZE / 2.0, Building_System.GRID_SIZE / 2.0)
			
			# Set color (will be updated by set_valid)
			cell_rect.color = Color(0, 1, 0, 0.3)
			
			# Add border using a Line2D (optional, for clarity)
			var border = Line2D.new()
			border.width = 1.0
			border.default_color = Color(1, 1, 1, 0.5)
			border.add_point(Vector2(0, 0))
			border.add_point(Vector2(Building_System.GRID_SIZE, 0))
			border.add_point(Vector2(Building_System.GRID_SIZE, Building_System.GRID_SIZE))
			border.add_point(Vector2(0, Building_System.GRID_SIZE))
			border.add_point(Vector2(0, 0))
			cell_rect.add_child(border)
			
			grid_indicator.add_child(cell_rect)
			grid_cells.append(cell_rect)

## Set color for all visual elements
func _set_color(color: Color) -> void:
	if visual:
		visual.color = color
	
	# Update grid cell colors
	for cell in grid_cells:
		cell.color = Color(color.r, color.g, color.b, 0.3)  # Slightly more transparent

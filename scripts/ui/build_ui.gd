# build_ui.gd
# Build mode UI controller
# Displays available structures, resource costs, and build mode controls
extends CanvasLayer

# Node references
@onready var panel = $Panel
@onready var wood_label = $Panel/VBoxContainer/ResourceDisplay/WoodRow/Label
@onready var stone_label = $Panel/VBoxContainer/ResourceDisplay/StoneRow/Label
@onready var info_label = $Panel/VBoxContainer/InfoLabel
@onready var error_message = $Panel/VBoxContainer/ErrorMessage

# Button references
@onready var wall_button = $Panel/VBoxContainer/StructureButtons/WallButton
@onready var turret_button = $Panel/VBoxContainer/StructureButtons/TurretButton
@onready var crafting_station_button = $Panel/VBoxContainer/StructureButtons/CraftingStationButton
@onready var storage_chest_button = $Panel/VBoxContainer/StructureButtons/StorageChestButton

# Structure costs (loaded from Building_System)
var structure_costs: Dictionary = {}

# Currently highlighted button
var highlighted_button: Button = null

func _ready() -> void:
	# Add to build_ui group for easy access
	add_to_group("build_ui")
	
	# Verify all components exist
	_verify_components()
	
	# Connect to EventBus signals
	_connect_signals()
	
	# Load structure costs from Building_System
	_load_structure_costs()
	
	# Initialize displays
	update_resource_display()
	update_button_states()
	
	# Hide UI initially (will be shown when build mode is activated)
	hide_build_ui()
	
	print("[Build_UI] Initialized successfully")

func _verify_components() -> void:
	"""Verify all component references are valid."""
	if not panel:
		push_error("[Build_UI] Panel not found!")
	if not wood_label:
		push_error("[Build_UI] Wood label not found!")
	if not stone_label:
		push_error("[Build_UI] Stone label not found!")
	if not info_label:
		push_error("[Build_UI] Info label not found!")
	if not error_message:
		push_error("[Build_UI] Error message label not found!")
	if not wall_button:
		push_error("[Build_UI] Wall button not found!")
	if not turret_button:
		push_error("[Build_UI] Turret button not found!")
	if not crafting_station_button:
		push_error("[Build_UI] Crafting station button not found!")
	if not storage_chest_button:
		push_error("[Build_UI] Storage chest button not found!")

func _connect_signals() -> void:
	"""Connect EventBus signals to handler methods."""
	# Build mode signals
	if EventBus.build_mode_changed.connect(_on_build_mode_changed) != OK:
		push_error("[Build_UI] Failed to connect build_mode_changed signal")
	
	# Resource signals
	if EventBus.resource_changed.connect(_on_resource_changed) != OK:
		push_error("[Build_UI] Failed to connect resource_changed signal")

func _load_structure_costs() -> void:
	"""Load structure costs from Building_System structure data."""
	if not Building_System:
		push_error("[Build_UI] Building_System not found!")
		return
	
	var data = Building_System.structure_data
	if data.is_empty():
		push_warning("[Build_UI] Structure data is empty")
		return
	
	# Extract costs for each structure type
	for structure_type in ["wall", "turret", "crafting_station", "storage_chest"]:
		if data.has(structure_type) and data[structure_type].has("costs"):
			structure_costs[structure_type] = data[structure_type]["costs"]
	
	print("[Build_UI] Loaded structure costs: %s" % structure_costs)

## Show the build UI
func show_build_ui() -> void:
	visible = true
	update_resource_display()
	update_button_states()
	clear_error_message()
	print("[Build_UI] Build UI shown")

## Hide the build UI
func hide_build_ui() -> void:
	visible = false
	clear_button_highlights()
	clear_error_message()
	print("[Build_UI] Build UI hidden")

## Update resource display with current resource amounts
func update_resource_display() -> void:
	if not ResourceManager:
		return
	
	var wood_amount = ResourceManager.get_resource("wood")
	var stone_amount = ResourceManager.get_resource("stone")
	
	if wood_label:
		wood_label.text = "Wood: %d" % wood_amount
	if stone_label:
		stone_label.text = "Stone: %d" % stone_amount

## Update button states based on available resources
func update_button_states() -> void:
	if not ResourceManager:
		return
	
	# Check each structure type
	_update_button_state(wall_button, "wall")
	_update_button_state(turret_button, "turret")
	_update_button_state(crafting_station_button, "crafting_station")
	_update_button_state(storage_chest_button, "storage_chest")

func _update_button_state(button: Button, structure_type: String) -> void:
	"""Update a single button's state based on resource availability."""
	if not button or not structure_costs.has(structure_type):
		return
	
	var costs = structure_costs[structure_type]
	var can_afford = true
	
	# Check if player has sufficient resources
	for resource_type in costs:
		var required = costs[resource_type]
		var available = ResourceManager.get_resource(resource_type)
		if available < required:
			can_afford = false
			break
	
	# Update button appearance
	if can_afford:
		button.modulate = Color(1.0, 1.0, 1.0, 1.0)  # Full opacity
		button.disabled = false
	else:
		button.modulate = Color(1.0, 1.0, 1.0, 0.5)  # 50% opacity
		button.disabled = true

## Highlight a structure button
func highlight_button(type: String) -> void:
	# Clear previous highlight
	clear_button_highlights()
	
	# Highlight the selected button
	match type:
		"wall":
			highlighted_button = wall_button
		"turret":
			highlighted_button = turret_button
		"crafting_station":
			highlighted_button = crafting_station_button
		"storage_chest":
			highlighted_button = storage_chest_button
	
	if highlighted_button:
		# Add a visual highlight (border or color change)
		highlighted_button.add_theme_color_override("font_color", Color(0.2, 1.0, 0.2))
		print("[Build_UI] Highlighted button: %s" % type)

## Clear all button highlights
func clear_button_highlights() -> void:
	if highlighted_button:
		highlighted_button.remove_theme_color_override("font_color")
		highlighted_button = null

## Show an error message
func show_error_message(message: String) -> void:
	if error_message:
		error_message.text = message
		print("[Build_UI] Error: %s" % message)
		
		# Auto-clear error after 3 seconds
		await get_tree().create_timer(3.0).timeout
		clear_error_message()

## Clear the error message
func clear_error_message() -> void:
	if error_message:
		error_message.text = ""

# Signal handlers

func _on_build_mode_changed(active: bool) -> void:
	"""Handle build mode activation/deactivation."""
	if active:
		show_build_ui()
	else:
		hide_build_ui()

func _on_resource_changed(_type: String, _amount: int) -> void:
	"""Update resource display when resources change."""
	# Prefix unused parameters with underscore to suppress warnings
	update_resource_display()
	update_button_states()

# Button press handlers

func _on_wall_button_pressed() -> void:
	"""Handle wall button press."""
	Building_System.select_structure("wall")
	highlight_button("wall")
	print("[Build_UI] Wall selected")

func _on_turret_button_pressed() -> void:
	"""Handle turret button press."""
	Building_System.select_structure("turret")
	highlight_button("turret")
	print("[Build_UI] Turret selected")

func _on_crafting_station_button_pressed() -> void:
	"""Handle crafting station button press."""
	Building_System.select_structure("crafting_station")
	highlight_button("crafting_station")
	print("[Build_UI] Crafting station selected")

func _on_storage_chest_button_pressed() -> void:
	"""Handle storage chest button press."""
	Building_System.select_structure("storage_chest")
	highlight_button("storage_chest")
	print("[Build_UI] Storage chest selected")

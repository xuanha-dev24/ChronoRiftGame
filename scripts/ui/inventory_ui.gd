# inventory_ui.gd
# Inventory UI controller with grid display and tooltips
extends Control

@onready var grid_container: GridContainer = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/GridContainer
@onready var tooltip_panel: Panel = $TooltipPanel
@onready var tooltip_name: Label = $TooltipPanel/VBoxContainer/ItemName
@onready var tooltip_desc: Label = $TooltipPanel/VBoxContainer/ItemDescription

var is_open: bool = false

func _ready() -> void:
	visible = false
	EventBus.inventory_changed.emit()
	
	# Hide tooltip initially
	if tooltip_panel:
		tooltip_panel.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("open_inventory"):
		toggle_inventory()

func toggle_inventory() -> void:
	is_open = !is_open
	visible = is_open
	
	if is_open:
		EventBus.ui_opened.emit("inventory")
		_on_inventory_changed()  # Refresh when opened
	else:
		EventBus.ui_closed.emit("inventory")

func _on_inventory_changed() -> void:
	if not is_open:
		return
	
	print("[Inventory_UI] Refreshing inventory display")
	
	# Clear existing items
	for child in grid_container.get_children():
		child.queue_free()
	
	# Get inventory from Player_Inventory autoload
	var player_inventory_node = get_node_or_null("/root/Player_Inventory")
	if not player_inventory_node:
		print("[Inventory_UI] ERROR: Player_Inventory autoload not found!")
		return
	
	var inventory = player_inventory_node.inventory
	print("[Inventory_UI] Inventory has %d items" % inventory.size())
	
	# Display each item
	for item in inventory:
		_create_item_slot(item["id"], item["quantity"])
	
	# Force layout update to recalculate center position
	await get_tree().process_frame
	# Force CenterContainer to recalculate by resetting size
	var center_container = $CenterContainer
	if center_container:
		center_container.reset_size()

func _create_item_slot(item_id: String, quantity: int) -> void:
	# Get item data
	var item_data = DataManager.get_item_data(item_id)
	if item_data.is_empty():
		return
	
	# Create slot panel
	var slot = Panel.new()
	slot.custom_minimum_size = Vector2(64, 64)
	
	# Create icon (ColorRect)
	var icon = ColorRect.new()
	icon.size = Vector2(48, 48)
	icon.position = Vector2(8, 8)
	
	# Set color from item data
	if item_data.has("icon_color"):
		icon.color = Color(item_data["icon_color"])
	else:
		icon.color = Color(0.5, 0.5, 0.5)
	
	slot.add_child(icon)
	
	# Create quantity label
	var qty_label = Label.new()
	qty_label.text = "x%d" % quantity
	qty_label.position = Vector2(40, 40)
	qty_label.add_theme_font_size_override("font_size", 12)
	slot.add_child(qty_label)
	
	# Connect mouse signals for tooltip
	slot.mouse_entered.connect(_on_item_mouse_entered.bind(item_id))
	slot.mouse_exited.connect(_on_item_mouse_exited)
	
	# Add to grid
	grid_container.add_child(slot)

func _on_item_mouse_entered(item_id: String) -> void:
	show_tooltip(item_id)

func _on_item_mouse_exited() -> void:
	hide_tooltip()

func show_tooltip(item_id: String) -> void:
	if not tooltip_panel:
		return
	
	# Get item data
	var item_data = DataManager.get_item_data(item_id)
	if item_data.is_empty():
		return
	
	# Set tooltip text
	if tooltip_name:
		tooltip_name.text = item_data.get("name", "Unknown Item")
	
	if tooltip_desc:
		tooltip_desc.text = item_data.get("description", "No description available")
	
	# Position tooltip near mouse
	tooltip_panel.global_position = get_global_mouse_position() + Vector2(10, 10)
	tooltip_panel.visible = true

func hide_tooltip() -> void:
	if tooltip_panel:
		tooltip_panel.visible = false

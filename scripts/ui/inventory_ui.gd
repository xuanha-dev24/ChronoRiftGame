# inventory_ui.gd
# Shared modal UI for player inventory, chest transfer, and crafting recipes
extends Control

const InventorySlotButton = preload("res://scripts/ui/inventory_slot_button.gd")

enum ViewMode {
	INVENTORY,
	CHEST,
	CRAFTING
}

const PLAYER_COLUMNS: int = 6
const PLAYER_SLOT_COUNT: int = 30
const CHEST_COLUMNS: int = 5
const PLAYER_UI_NAME: String = "inventory"
const CHEST_UI_NAME: String = "storage_chest"
const CRAFTING_UI_NAME: String = "crafting_station"

@onready var center_container: CenterContainer = $CenterContainer
@onready var title_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HeaderRow/TitleBlock/TitleLabel
@onready var subtitle_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HeaderRow/TitleBlock/SubtitleLabel
@onready var close_hint_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HeaderRow/CloseHintLabel
@onready var player_section: VBoxContainer = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ContentRow/PlayerSection
@onready var player_section_title: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ContentRow/PlayerSection/SectionTitle
@onready var player_grid: GridContainer = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ContentRow/PlayerSection/PanelContainer/MarginContainer/GridContainer
@onready var secondary_section: VBoxContainer = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ContentRow/SecondarySection
@onready var secondary_section_title: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ContentRow/SecondarySection/SectionTitle
@onready var secondary_grid: GridContainer = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ContentRow/SecondarySection/PanelContainer/MarginContainer/GridContainer
@onready var recipes_scroll: ScrollContainer = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ContentRow/SecondarySection/RecipesScroll
@onready var recipes_list: VBoxContainer = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ContentRow/SecondarySection/RecipesScroll/RecipesList
@onready var status_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/FooterLabel
@onready var tooltip_panel: Panel = $TooltipPanel
@onready var tooltip_name: Label = $TooltipPanel/MarginContainer/VBoxContainer/ItemName
@onready var tooltip_desc: Label = $TooltipPanel/MarginContainer/VBoxContainer/ItemDescription

var is_open: bool = false
var current_mode: int = ViewMode.INVENTORY
var active_chest: Node2D = null
var status_message: String = "Press I to open your bag."

func _ready() -> void:
	visible = false
	hide_tooltip()
	close_hint_label.text = "I / Esc to close"
	_connect_signals()
	_update_status(status_message)

func _connect_signals() -> void:
	if not EventBus.inventory_changed.is_connected(_on_inventory_changed):
		EventBus.inventory_changed.connect(_on_inventory_changed)
	if not EventBus.storage_chest_opened.is_connected(_on_storage_chest_opened):
		EventBus.storage_chest_opened.connect(_on_storage_chest_opened)
	if not EventBus.storage_chest_closed.is_connected(_on_storage_chest_closed):
		EventBus.storage_chest_closed.connect(_on_storage_chest_closed)
	if not EventBus.crafting_station_opened.is_connected(_on_crafting_station_opened):
		EventBus.crafting_station_opened.connect(_on_crafting_station_opened)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("open_inventory"):
		if is_open and current_mode != ViewMode.INVENTORY:
			close_modal()
		else:
			toggle_inventory()
	elif is_open and event.is_action_pressed("ui_cancel"):
		close_modal()

func toggle_inventory() -> void:
	if is_open and current_mode == ViewMode.INVENTORY:
		close_modal()
	else:
		active_chest = null
		_open_mode(ViewMode.INVENTORY)

func _open_mode(mode: int) -> void:
	current_mode = mode
	is_open = true
	visible = true
	hide_tooltip()
	EventBus.ui_opened.emit(_get_ui_name(mode))
	_refresh_view()

func close_modal() -> void:
	if not is_open:
		return

	var ui_name := _get_ui_name(current_mode)
	is_open = false
	visible = false
	hide_tooltip()
	active_chest = null
	EventBus.ui_closed.emit(ui_name)
	_update_status("Closed %s." % ui_name)

func _refresh_view() -> void:
	if not is_open:
		return

	if current_mode == ViewMode.CHEST and not is_instance_valid(active_chest):
		close_modal()
		return

	match current_mode:
		ViewMode.INVENTORY:
			_configure_inventory_view()
		ViewMode.CHEST:
			_configure_chest_view()
		ViewMode.CRAFTING:
			_configure_crafting_view()

	await get_tree().process_frame
	center_container.reset_size()

func _configure_inventory_view() -> void:
	title_label.text = "Inventory"
	subtitle_label.text = "Drag between slots to reorder your backpack."
	player_section_title.text = "Backpack"
	secondary_section.visible = false
	_render_player_inventory(true)
	_update_status("Drag an item onto another slot to reorder or stack it.")

func _configure_chest_view() -> void:
	title_label.text = "Storage Chest"
	subtitle_label.text = "Drag items between backpack and chest to move, merge, or swap stacks."
	player_section_title.text = "Backpack"
	secondary_section.visible = true
	secondary_section_title.text = "Chest"
	secondary_grid.visible = true
	recipes_scroll.visible = false
	_render_player_inventory(true)
	_render_chest_inventory()
	_update_status("Drag a stack onto another slot to move, merge, or swap it.")

func _configure_crafting_view() -> void:
	title_label.text = "Crafting Station"
	subtitle_label.text = "Craft consumables directly from backpack materials."
	player_section_title.text = "Backpack"
	secondary_section.visible = true
	secondary_section_title.text = "Recipes"
	secondary_grid.visible = false
	recipes_scroll.visible = true
	_render_player_inventory(true)
	_render_recipes()
	_update_status("Crafting checks ingredients from your backpack. You can still reorder slots here.")

func _render_player_inventory(allow_transfer: bool) -> void:
	_clear_children(player_grid)
	player_grid.columns = PLAYER_COLUMNS

	for slot_index in range(PLAYER_SLOT_COUNT):
		var item_data: Dictionary = Player_Inventory.get_item(slot_index)
		var slot = _create_inventory_slot(item_data, slot_index, allow_transfer)
		player_grid.add_child(slot)

func _render_chest_inventory() -> void:
	_clear_children(secondary_grid)
	secondary_grid.columns = CHEST_COLUMNS

	var chest_inventory: Array = active_chest.chest_inventory
	for slot_index in range(chest_inventory.size()):
		var item_data: Dictionary = active_chest.get_item(slot_index)
		var slot = _create_chest_slot(item_data, slot_index)
		secondary_grid.add_child(slot)

func _render_recipes() -> void:
	_clear_children(recipes_list)

	var recipes := DataManager.get_crafting_recipes()
	var recipe_ids: Array = recipes.keys()
	recipe_ids.sort()

	for recipe_id in recipe_ids:
		var recipe: Dictionary = recipes[recipe_id]
		var card := PanelContainer.new()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var margin := MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 12)
		margin.add_theme_constant_override("margin_top", 12)
		margin.add_theme_constant_override("margin_right", 12)
		margin.add_theme_constant_override("margin_bottom", 12)
		card.add_child(margin)

		var column := VBoxContainer.new()
		column.add_theme_constant_override("separation", 6)
		margin.add_child(column)

		var output_data: Dictionary = DataManager.get_item_data(recipe["output"]["item_id"])
		var name_label := Label.new()
		name_label.text = "%s x%d" % [output_data.get("name", recipe_id), recipe["output"]["quantity"]]
		column.add_child(name_label)

		var description_label := Label.new()
		description_label.text = recipe.get("description", "")
		description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		column.add_child(description_label)

		var ingredients_label := Label.new()
		ingredients_label.text = "Needs: %s" % _format_ingredients(recipe.get("ingredients", []))
		ingredients_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		column.add_child(ingredients_label)

		var craft_button := Button.new()
		craft_button.text = "Craft"
		craft_button.disabled = not _can_craft_recipe(recipe)
		craft_button.pressed.connect(_on_craft_button_pressed.bind(recipe_id))
		column.add_child(craft_button)

		recipes_list.add_child(card)

func _create_inventory_slot(item_data: Dictionary, slot_index: int, allow_transfer: bool) -> Control:
	return _create_slot_button("player", slot_index, item_data, allow_transfer, allow_transfer)

func _create_chest_slot(item_data: Dictionary, slot_index: int) -> Control:
	return _create_slot_button("chest", slot_index, item_data, true, true)

func _create_slot_button(slot_owner: String, slot_index: int, item_data: Dictionary, can_drag: bool, can_drop: bool) -> Control:
	var button := InventorySlotButton.new()
	button.inventory_ui = self
	button.slot_owner = slot_owner
	button.slot_index = slot_index
	button.can_drag_slot = can_drag
	button.can_drop_slot = can_drop
	button.custom_minimum_size = Vector2(68, 68)
	button.clip_contents = true
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	if item_data.is_empty():
		button.flat = true
		button.modulate = Color(1, 1, 1, 0.55)
		return button

	var item_id := str(item_data.get("id", item_data.get("item_id", "")))
	var quantity := int(item_data.get("quantity", 0))
	button.item_id = item_id
	button.quantity = quantity
	_populate_slot_visuals(button, item_id, quantity)
	button.mouse_entered.connect(_on_item_mouse_entered.bind(item_id))
	button.mouse_exited.connect(_on_item_mouse_exited)
	return button


func _populate_slot_visuals(button: Control, item_id: String, quantity: int) -> void:
	var item_data: Dictionary = DataManager.get_item_data(item_id)

	var icon := ColorRect.new()
	icon.position = Vector2(10, 10)
	icon.size = Vector2(48, 48)
	icon.color = Color(item_data.get("icon_color", "#7F8C8D"))
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(icon)

	var name_label := Label.new()
	name_label.position = Vector2(8, 6)
	name_label.size = Vector2(52, 18)
	name_label.text = item_data.get("name", item_id).substr(0, 8)
	name_label.add_theme_font_size_override("font_size", 10)
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(name_label)

	var quantity_label := Label.new()
	quantity_label.position = Vector2(8, 48)
	quantity_label.size = Vector2(52, 16)
	quantity_label.text = "x%d" % quantity
	quantity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	quantity_label.add_theme_font_size_override("font_size", 11)
	quantity_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(quantity_label)

func create_drag_preview(item_id: String, quantity: int) -> Control:
	var preview := Panel.new()
	preview.custom_minimum_size = Vector2(68, 68)
	preview.modulate = Color(1, 1, 1, 0.9)
	_populate_slot_visuals(preview, item_id, quantity)
	return preview

func begin_slot_drag(_item_id: String) -> void:
	hide_tooltip()

func finish_slot_drag() -> void:
	hide_tooltip()

func can_drop_on_slot(target_owner: String, target_index: int, data: Variant) -> bool:
	if not is_open or current_mode == ViewMode.CRAFTING and target_owner == "chest":
		return false
	if not (data is Dictionary):
		return false
	if not data.has("source_owner") or not data.has("source_index"):
		return false

	var source_owner := str(data.get("source_owner", ""))
	var source_index := int(data.get("source_index", -1))
	if source_owner.is_empty() or source_index < 0:
		return false
	if source_owner == target_owner and source_index == target_index:
		return false

	if current_mode == ViewMode.INVENTORY or current_mode == ViewMode.CRAFTING:
		return source_owner == "player" and target_owner == "player" and not _get_normalized_slot_item(source_owner, source_index).is_empty()
	if current_mode == ViewMode.CHEST:
		if not ["player", "chest"].has(source_owner):
			return false
		if not ["player", "chest"].has(target_owner):
			return false
		return not _get_normalized_slot_item(source_owner, source_index).is_empty()
	return false

func drop_on_slot(target_owner: String, target_index: int, data: Variant) -> void:
	if not can_drop_on_slot(target_owner, target_index, data):
		return

	var source_owner := str(data.get("source_owner", ""))
	var source_index := int(data.get("source_index", -1))
	var source_item := _get_normalized_slot_item(source_owner, source_index)
	if source_item.is_empty():
		return

	if source_owner == target_owner:
		_move_within_owner(target_owner, source_index, target_index)
		_update_status("Reordered %s." % source_item.get("item_id", "item"))
		_refresh_view()
		return

	if current_mode != ViewMode.CHEST:
		return

	var target_item := _get_normalized_slot_item(target_owner, target_index)
	if target_item.is_empty():
		_set_normalized_slot_item(target_owner, target_index, source_item)
		_set_normalized_slot_item(source_owner, source_index, {})
	elif target_item.get("item_id", "") == source_item.get("item_id", ""):
		target_item["quantity"] += int(source_item.get("quantity", 0))
		_set_normalized_slot_item(target_owner, target_index, target_item)
		_set_normalized_slot_item(source_owner, source_index, {})
	else:
		_set_normalized_slot_item(target_owner, target_index, source_item)
		_set_normalized_slot_item(source_owner, source_index, target_item)

	_notify_player_inventory_if_needed(source_owner, target_owner)
	_update_status("Moved %s between backpack and chest." % source_item.get("item_id", "item"))
	_refresh_view()

func _on_craft_button_pressed(recipe_id: String) -> void:
	var recipes := DataManager.get_crafting_recipes()
	if not recipes.has(recipe_id):
		return

	var recipe: Dictionary = recipes[recipe_id]
	if not _can_craft_recipe(recipe):
		_update_status("Missing ingredients for %s." % recipe_id)
		_refresh_view()
		return

	var output: Dictionary = recipe["output"]
	if not _can_store_item(output["item_id"]):
		_update_status("Backpack is full.")
		_refresh_view()
		return

	for ingredient in recipe.get("ingredients", []):
		Player_Inventory.remove_item(ingredient["item_id"], ingredient["quantity"])

	if Player_Inventory.add_item(output["item_id"], output["quantity"]):
		_update_status("Crafted %d x %s." % [output["quantity"], output["item_id"]])
	else:
		for ingredient in recipe.get("ingredients", []):
			Player_Inventory.add_item(ingredient["item_id"], ingredient["quantity"])
		_update_status("Backpack is full.")

	_refresh_view()

func _can_craft_recipe(recipe: Dictionary) -> bool:
	for ingredient in recipe.get("ingredients", []):
		if Player_Inventory.get_item_count(ingredient["item_id"]) < ingredient["quantity"]:
			return false
	return true

func _can_store_item(item_id: String) -> bool:
	for item in Player_Inventory.inventory:
		if item != null and item.get("id", "") == item_id:
			return true
	return Player_Inventory.get_used_slot_count() < PLAYER_SLOT_COUNT

func _move_within_owner(slot_owner: String, from_index: int, to_index: int) -> void:
	if slot_owner == "player":
		if Player_Inventory.move_slot_item(from_index, to_index, false):
			Player_Inventory.notify_inventory_changed()
		return
	if is_instance_valid(active_chest):
		active_chest.move_item_to_slot(from_index, to_index)


func _get_normalized_slot_item(slot_owner: String, slot_index: int) -> Dictionary:
	if slot_owner == "player":
		var player_item: Dictionary = Player_Inventory.get_item(slot_index)
		if player_item.is_empty():
			return {}
		return {
			"item_id": player_item.get("id", ""),
			"quantity": player_item.get("quantity", 0)
		}
	if is_instance_valid(active_chest):
		var chest_item: Dictionary = active_chest.get_item(slot_index)
		if chest_item.is_empty():
			return {}
		return {
			"item_id": chest_item.get("item_id", ""),
			"quantity": chest_item.get("quantity", 0)
		}
	return {}

func _set_normalized_slot_item(slot_owner: String, slot_index: int, item_data: Dictionary) -> void:
	if slot_owner == "player":
		if item_data.is_empty():
			Player_Inventory.clear_slot(slot_index, false)
		else:
			Player_Inventory.set_item(slot_index, {
				"id": item_data.get("item_id", ""),
				"quantity": item_data.get("quantity", 0)
			}, false)
		return
	if not is_instance_valid(active_chest):
		return
	if item_data.is_empty():
		active_chest.clear_slot(slot_index)
	else:
		active_chest.set_item(slot_index, item_data)

func _notify_player_inventory_if_needed(source_owner: String, target_owner: String) -> void:
	if source_owner == "player" or target_owner == "player":
		Player_Inventory.notify_inventory_changed()

func _format_ingredients(ingredients: Array) -> String:
	var parts: Array[String] = []
	for ingredient in ingredients:
		var item_data: Dictionary = DataManager.get_item_data(ingredient["item_id"])
		parts.append("%s x%d" % [item_data.get("name", ingredient["item_id"]), ingredient["quantity"]])
	return ", ".join(parts)

func _clear_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()

func _get_ui_name(mode: int) -> String:
	match mode:
		ViewMode.CHEST:
			return CHEST_UI_NAME
		ViewMode.CRAFTING:
			return CRAFTING_UI_NAME
		_:
			return PLAYER_UI_NAME

func _update_status(message: String) -> void:
	status_message = message
	status_label.text = status_message

func _on_inventory_changed() -> void:
	if is_open:
		_refresh_view()

func _on_storage_chest_opened(chest: Node2D) -> void:
	active_chest = chest
	_open_mode(ViewMode.CHEST)

func _on_storage_chest_closed() -> void:
	if current_mode == ViewMode.CHEST and is_open:
		close_modal()

func _on_crafting_station_opened() -> void:
	active_chest = null
	_open_mode(ViewMode.CRAFTING)

func _on_item_mouse_entered(item_id: String) -> void:
	show_tooltip(item_id)

func _on_item_mouse_exited() -> void:
	hide_tooltip()

func show_tooltip(item_id: String) -> void:
	var item_data: Dictionary = DataManager.get_item_data(item_id)
	if item_data.is_empty():
		return

	tooltip_name.text = item_data.get("name", item_id)
	tooltip_desc.text = item_data.get("description", "No description available")
	tooltip_panel.global_position = get_global_mouse_position() + Vector2(16, 16)
	tooltip_panel.visible = true

func hide_tooltip() -> void:
	tooltip_panel.visible = false

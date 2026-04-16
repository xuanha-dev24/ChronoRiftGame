# hud.gd
# Main HUD controller
extends CanvasLayer

# Component references
@onready var hp_bar = $StatsPanel/HPBar
@onready var mana_bar = $StatsPanel/ManaBar
@onready var chrono_rift_indicator = $StatsPanel/ChronoRiftIndicator
@onready var hotbar = $Hotbar
@onready var inventory_counter = $InfoPanel/InventoryCounter
@onready var resource_display = $InfoPanel/ResourceDisplay

func _ready() -> void:
	# Verify all components exist
	_verify_components()
	
	# Connect to EventBus signals
	_connect_signals()
	
	# Connect to viewport size changed
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	
	# Initialize displays
	_initialize_displays()
	
	print("[HUD] Initialized successfully")

func _verify_components() -> void:
	"""Verify all component references are valid."""
	if not hp_bar:
		push_error("[HUD] HPBar component not found!")
	if not mana_bar:
		push_error("[HUD] ManaBar component not found!")
	if not chrono_rift_indicator:
		push_error("[HUD] ChronoRiftIndicator component not found!")
	if not hotbar:
		push_error("[HUD] Hotbar component not found!")
	if not inventory_counter:
		push_error("[HUD] InventoryCounter component not found!")
	if not resource_display:
		push_error("[HUD] ResourceDisplay component not found!")

func _connect_signals() -> void:
	"""Connect EventBus signals to handler methods."""
	# Player stats signals
	if EventBus.player_damaged.connect(_on_player_damaged) != OK:
		push_error("[HUD] Failed to connect player_damaged signal")
	
	if EventBus.player_mana_changed.connect(_on_mana_changed) != OK:
		push_error("[HUD] Failed to connect player_mana_changed signal")
	
	# Chrono Rift signals
	if EventBus.chrono_rift_cooldown_started.connect(_on_chrono_rift_cooldown) != OK:
		push_error("[HUD] Failed to connect chrono_rift_cooldown_started signal")
	
	if EventBus.chrono_rift_ready.connect(_on_chrono_rift_ready) != OK:
		push_error("[HUD] Failed to connect chrono_rift_ready signal")
	
	# Resource signals
	if EventBus.resource_changed.connect(_on_resource_changed) != OK:
		push_error("[HUD] Failed to connect resource_changed signal")
	
	# Hotbar signals
	if EventBus.hotbar_slot_changed.connect(_on_hotbar_changed) != OK:
		push_error("[HUD] Failed to connect hotbar_slot_changed signal")
	
	# Inventory signals
	if Player_Inventory.inventory_updated.connect(_on_inventory_updated) != OK:
		push_error("[HUD] Failed to connect inventory_updated signal")

func _initialize_displays() -> void:
	"""Initialize all displays with default/current values."""
	# Initialize inventory counter
	if inventory_counter:
		var item_count = Player_Inventory.inventory.size()
		inventory_counter.update_count(item_count, 30)
	
	# Initialize resource display
	if resource_display:
		for resource_type in ["fire_shard", "gold", "stone", "wood", "meat"]:
			var amount = ResourceManager.get_resource(resource_type)
			resource_display.update_resource(resource_type, amount)

# Signal handlers

func _on_player_damaged(current_hp: int, max_hp: int) -> void:
	"""Update HP display when player takes damage."""
	if hp_bar:
		hp_bar.update_hp(current_hp, max_hp)

func _on_mana_changed(current: int, max: int) -> void:
	"""Update mana display when player mana changes."""
	if mana_bar:
		mana_bar.update_mana(current, max)

func _on_chrono_rift_cooldown(duration: float) -> void:
	"""Start chrono rift cooldown display."""
	if chrono_rift_indicator:
		chrono_rift_indicator.start_cooldown(duration)

func _on_chrono_rift_ready() -> void:
	"""Set chrono rift indicator to ready state."""
	if chrono_rift_indicator:
		chrono_rift_indicator.set_ready()

func _on_resource_changed(type: String, amount: int) -> void:
	"""Update resource display when resource changes."""
	if resource_display:
		resource_display.update_resource(type, amount)

func _on_hotbar_changed(slot_index: int, item_data: Dictionary) -> void:
	"""Update hotbar slot when item changes."""
	if not hotbar:
		return
	
	if item_data.is_empty():
		hotbar.clear_slot(slot_index)
	else:
		var item_id = item_data.get("id", "")
		var quantity = item_data.get("quantity", 0)
		hotbar.update_slot(slot_index, item_id, quantity)

func _on_inventory_updated() -> void:
	"""Update inventory counter when items are added/removed."""
	if inventory_counter:
		var item_count = Player_Inventory.inventory.size()
		inventory_counter.update_count(item_count, 30)

func _on_viewport_size_changed() -> void:
	"""Handle window resize to reposition UI elements."""
	var viewport_size = get_viewport().get_visible_rect().size
	
	# Hotbar is already anchored to bottom-center, but we can adjust if needed
	# InfoPanel is already anchored to top-right
	# StatsPanel is already at fixed top-left position
	
	# Optional: Add any custom positioning logic here if needed
	pass

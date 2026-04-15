# pickup_item.gd
# Represents a collectible item in the game world
extends Node2D

@export var item_id: String = ""
@export var quantity: int = 1

@onready var area: Area2D = $Area2D
@onready var visual: ColorRect = $Visual
@onready var despawn_timer: Timer = $DespawnTimer
@onready var interact_prompt: Label = $InteractPrompt
@onready var item_label: Label = $ItemLabel

var is_highlighted: bool = false
var player_in_range: bool = false
var base_color: Color = Color.WHITE
var tween: Tween

func _ready() -> void:
	# Add to pickups group for proximity selection
	add_to_group("pickups")
	
	# Debug: Check if nodes exist
	print("[PickupItem] _ready called")
	print("[PickupItem] area exists: ", area != null)
	print("[PickupItem] visual exists: ", visual != null)
	print("[PickupItem] despawn_timer exists: ", despawn_timer != null)
	print("[PickupItem] interact_prompt exists: ", interact_prompt != null)
	
	# Start despawn timer
	if despawn_timer:
		despawn_timer.start()
	else:
		print("[PickupItem] ERROR: DespawnTimer not found!")
	
	# Connect signals
	area.body_entered.connect(_on_area_entered)
	area.body_exited.connect(_on_area_exited)
	despawn_timer.timeout.connect(_on_despawn_timer_timeout)
	
	# Hide interact prompt initially
	if interact_prompt:
		interact_prompt.visible = false
	
	# Start idle animation
	_start_idle_animation()

func setup(p_item_id: String, p_quantity: int) -> void:
	item_id = p_item_id
	quantity = p_quantity
	
	print("[PickupItem] Setup called: item_id=%s, quantity=%d" % [item_id, quantity])
	
	# Load item data from DataManager to set visual color
	var item_data = DataManager.get_item_data(item_id)
	print("[PickupItem] Item data: ", item_data)
	
	if item_data.has("icon_color"):
		base_color = Color(item_data["icon_color"])
		print("[PickupItem] Setting color to: ", base_color)
		if visual:
			visual.color = base_color
			print("[PickupItem] Color applied to visual")
		else:
			print("[PickupItem] ERROR: Visual node is null!")
	else:
		# Default gray color if no icon_color found
		print("[PickupItem] No icon_color found, using default gray")
		base_color = Color(0.5, 0.5, 0.5)
		if visual:
			visual.color = base_color
	
	# Set item name label
	if item_label and item_data.has("name"):
		var display_text = item_data["name"]
		if quantity > 1:
			display_text += " x%d" % quantity
		item_label.text = display_text

func _on_area_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		highlight()
		
		# Check pickup mode from LootSystem
		if LootSystem.pickup_mode == "automatic":
			collect()
		elif LootSystem.pickup_mode == "manual" and interact_prompt:
			interact_prompt.visible = true

func _on_area_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		unhighlight()
		
		if interact_prompt:
			interact_prompt.visible = false

func _input(event: InputEvent) -> void:
	# Manual pickup mode
	if LootSystem.pickup_mode == "manual" and player_in_range:
		if event.is_action_pressed("interact"):
			collect()

func highlight() -> void:
	is_highlighted = true
	# Increase brightness by 20%
	if visual:
		visual.modulate = Color(1.2, 1.2, 1.2)

func unhighlight() -> void:
	is_highlighted = false
	# Restore normal brightness
	if visual:
		visual.modulate = Color(1.0, 1.0, 1.0)

func _start_idle_animation() -> void:
	# Create looping float and pulse animation
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_loops()
	tween.set_parallel(true)
	
	# Float animation (±3 pixels)
	tween.tween_property(self, "position:y", position.y - 3, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position:y", position.y + 3, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT).set_delay(1.0)
	
	# Pulse animation (0.95 to 1.05 scale) - only if visual exists
	if visual:
		tween.tween_property(visual, "scale", Vector2(1.05, 1.05), 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(visual, "scale", Vector2(0.95, 0.95), 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT).set_delay(1.0)

func collect() -> void:
	# Store position before queue_free
	var pickup_position = global_position
	
	print("[PickupItem] collect() called")
	print("[PickupItem] Item global_position: ", global_position)
	print("[PickupItem] Item position: ", position)
	print("[PickupItem] Emitting spawn_effect with position: ", pickup_position)
	
	# Emit signal
	EventBus.item_picked_up.emit(item_id, quantity)
	
	# Play effects BEFORE queue_free
	EventBus.spawn_effect.emit("pickup_effect", pickup_position)
	
	# Play sound effect (handle missing file gracefully)
	if has_node("AudioStreamPlayer"):
		var audio_player = get_node("AudioStreamPlayer") as AudioStreamPlayer
		if audio_player and audio_player.stream:
			audio_player.play()
	
	# Remove from scene
	queue_free()

func play_pickup_effect() -> void:
	# Spawn visual effect
	print("[PickupItem] Emitting spawn_effect signal for pickup_effect at position: ", global_position)
	EventBus.spawn_effect.emit("pickup_effect", global_position)
	
	# Play sound effect (handle missing file gracefully)
	if has_node("AudioStreamPlayer"):
		var audio_player = get_node("AudioStreamPlayer") as AudioStreamPlayer
		if audio_player and audio_player.stream:
			audio_player.play()

func _on_despawn_timer_timeout() -> void:
	# Fade out and remove
	if tween:
		tween.kill()
	
	if visual:
		var fade_tween = create_tween()
		fade_tween.tween_property(visual, "modulate:a", 0.0, 0.5)
		fade_tween.tween_callback(queue_free)
	else:
		queue_free()

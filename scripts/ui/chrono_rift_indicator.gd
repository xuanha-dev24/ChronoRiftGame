# chrono_rift_indicator.gd
# Chrono Rift cooldown indicator for HUD
extends PanelContainer

@onready var label: Label = $Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var cooldown_remaining: float = 0.0
var is_on_cooldown: bool = false

func _ready() -> void:
	set_ready()

func _process(delta: float) -> void:
	if is_on_cooldown:
		_update_cooldown_display(delta)

func start_cooldown(duration: float) -> void:
	"""Start cooldown timer with given duration."""
	cooldown_remaining = duration
	is_on_cooldown = true
	
	if label:
		label.modulate = Color(0.5, 0.5, 0.5, 1.0)  # Gray during cooldown
	
	if animation_player and animation_player.has_animation("pulse"):
		animation_player.stop()

func set_ready() -> void:
	"""Set indicator to ready state with pulse animation."""
	is_on_cooldown = false
	cooldown_remaining = 0.0
	
	if label:
		label.text = "READY"
		label.modulate = Color.CYAN  # Bright cyan when ready
	
	# Play pulse animation
	if animation_player and animation_player.has_animation("pulse"):
		animation_player.play("pulse")

func _update_cooldown_display(delta: float) -> void:
	"""Update cooldown display every frame."""
	cooldown_remaining -= delta
	
	if cooldown_remaining <= 0:
		set_ready()
		return
	
	# Display remaining time in seconds (1 decimal place)
	if label:
		label.text = "%.1fs" % cooldown_remaining

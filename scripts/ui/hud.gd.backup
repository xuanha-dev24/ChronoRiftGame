# hud.gd
# Main HUD controller
extends CanvasLayer

@onready var hp_label: Label = $HPLabel

func _ready() -> void:
	# Connect to player damage signal
	EventBus.player_damaged.connect(_on_player_damaged)
	
	# Initialize HP display
	_update_hp_display(100, 100)
	
	print("[HUD] Initialized")

func _on_player_damaged(current_hp: int, max_hp: int) -> void:
	"""Update HP display when player takes damage."""
	_update_hp_display(current_hp, max_hp)

func _update_hp_display(current_hp: int, max_hp: int) -> void:
	"""Update HP label text."""
	if hp_label:
		hp_label.text = "HP: %d / %d" % [current_hp, max_hp]
		
		# Color code based on HP percentage
		var hp_percent = float(current_hp) / float(max_hp)
		if hp_percent > 0.6:
			hp_label.modulate = Color.WHITE
		elif hp_percent > 0.3:
			hp_label.modulate = Color.YELLOW
		else:
			hp_label.modulate = Color.RED

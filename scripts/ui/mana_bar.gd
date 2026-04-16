# mana_bar.gd
# Mana bar component for HUD
extends PanelContainer

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var label: Label = $ProgressBar/Label

func _ready() -> void:
	# Set cyan color for mana
	if progress_bar:
		progress_bar.modulate = Color.CYAN
	
	# Initialize with default values
	update_mana(100, 100)

func update_mana(current: int, max: int) -> void:
	"""Update mana bar display with current and max mana values."""
	if not progress_bar or not label:
		return
	
	# Update progress bar
	progress_bar.max_value = max
	progress_bar.value = current
	
	# Update label text
	label.text = "%d / %d" % [current, max]
	
	# Handle empty state (mana = 0)
	if current <= 0:
		label.text = "0 / %d" % max
		progress_bar.modulate = Color(0, 0.5, 0.5, 1.0)  # Darker cyan
	else:
		progress_bar.modulate = Color.CYAN  # Bright cyan

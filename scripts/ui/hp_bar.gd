# hp_bar.gd
# HP Bar component for HUD
extends PanelContainer

@onready var progress_bar: ProgressBar = $MarginContainer/VBoxContainer/ProgressBar
@onready var label: Label = $MarginContainer/VBoxContainer/Label

var current_hp: int = 100
var max_hp: int = 100

func _ready() -> void:
	# Set initial values
	update_hp(current_hp, max_hp)
	
	# Apply semi-transparent dark background
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.7)
	add_theme_stylebox_override("panel", style)
	
	print("[HPBar] Initialized")

## Update HP display with current and max values
func update_hp(current: int, max: int) -> void:
	current_hp = current
	max_hp = max
	
	# Update progress bar
	if progress_bar:
		progress_bar.max_value = max_hp
		progress_bar.value = current_hp
		
		# Update color based on HP percentage
		var hp_percent = float(current_hp) / float(max_hp) if max_hp > 0 else 0.0
		var bar_color = _get_hp_color(hp_percent)
		
		# Apply color to progress bar
		var style = StyleBoxFlat.new()
		style.bg_color = bar_color
		progress_bar.add_theme_stylebox_override("fill", style)
	
	# Update label text
	if label:
		label.text = "HP: %d / %d" % [current_hp, max_hp]
		label.modulate = _get_hp_color(float(current_hp) / float(max_hp) if max_hp > 0 else 0.0)

## Get color based on HP percentage
func _get_hp_color(percentage: float) -> Color:
	if percentage > 0.6:
		return Color.GREEN  # Green (#00FF00)
	elif percentage > 0.3:
		return Color.YELLOW  # Yellow (#FFFF00)
	else:
		return Color.RED  # Red (#FF0000)

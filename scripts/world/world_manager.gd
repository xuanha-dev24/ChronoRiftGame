# world_manager.gd
# Manages world state transitions, biome tracking, and the day/night cycle.
extends Node
class_name WorldManager

@export var current_biome: String = "plains"
@export_range(0.0, 1.0, 0.001) var time_of_day: float = 0.32
@export var auto_cycle_enabled: bool = true
@export var day_length_seconds: float = 300.0

var _last_emitted_time: float = -1.0


func _ready() -> void:
	_emit_time_of_day_changed(true)


func change_biome(biome_name: String) -> void:
	if biome_name == "" or biome_name == current_biome:
		return
	current_biome = biome_name
	EventBus.biome_entered.emit(biome_name)
	print("Entered biome: ", biome_name)


func update_time_of_day(delta: float) -> void:
	if not auto_cycle_enabled:
		return
	set_time_of_day(time_of_day + delta / max(day_length_seconds, 1.0))


func set_time_of_day(value: float) -> void:
	time_of_day = wrapf(value, 0.0, 1.0)
	_emit_time_of_day_changed(false)


func is_night() -> bool:
	return time_of_day < 0.2 or time_of_day >= 0.8


func get_time_phase_name() -> String:
	if time_of_day < 0.20:
		return "Night"
	if time_of_day < 0.30:
		return "Dawn"
	if time_of_day < 0.70:
		return "Day"
	if time_of_day < 0.80:
		return "Dusk"
	return "Night"


func get_clock_time_string() -> String:
	var total_minutes: int = int(round(time_of_day * 24.0 * 60.0)) % (24 * 60)
	var hours: int = total_minutes / 60
	var minutes: int = total_minutes % 60
	return "%02d:%02d" % [hours, minutes]


func get_daylight_color() -> Color:
	if time_of_day < 0.20:
		return Color(0.32, 0.38, 0.55, 1.0)
	if time_of_day < 0.30:
		return Color(0.32, 0.38, 0.55, 1.0).lerp(Color(0.82, 0.62, 0.52, 1.0), inverse_lerp(0.20, 0.30, time_of_day))
	if time_of_day < 0.50:
		return Color(0.82, 0.62, 0.52, 1.0).lerp(Color(1.0, 1.0, 1.0, 1.0), inverse_lerp(0.30, 0.50, time_of_day))
	if time_of_day < 0.70:
		return Color(1.0, 1.0, 1.0, 1.0).lerp(Color(0.88, 0.72, 0.56, 1.0), inverse_lerp(0.50, 0.70, time_of_day))
	if time_of_day < 0.80:
		return Color(0.88, 0.72, 0.56, 1.0).lerp(Color(0.32, 0.38, 0.55, 1.0), inverse_lerp(0.70, 0.80, time_of_day))
	return Color(0.32, 0.38, 0.55, 1.0)


func _emit_time_of_day_changed(force: bool) -> void:
	if force or absf(time_of_day - _last_emitted_time) >= 0.0025:
		_last_emitted_time = time_of_day
		EventBus.day_night_cycle_changed.emit(time_of_day)

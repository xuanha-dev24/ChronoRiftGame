# chrono_rift_system_poc.gd
# POC — Only implements SLOW mode for validation
class_name ChronoRiftSystemPOC
extends Node

const SLOW_RADIUS: float = 80.0
const SLOW_FACTOR: float = 0.2   # enemy speed * 0.2
const SLOW_DURATION: float = 3.0
const RIFT_COOLDOWN: float = 5.0
const MANA_COST: int = 50  # Mana cost to use Chrono Rift

var is_on_cooldown: bool = false
var slowed_enemies: Array[CharacterBody2D] = []
var player: CharacterBody2D = null
var player_stats: Node = null  # Reference to PlayerStats

@onready var cooldown_timer: Timer = $CooldownTimer
@onready var slow_area: Area2D = $SlowArea
@onready var slow_visual: ColorRect = $SlowVisual

func _ready() -> void:
	cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)
	# Get player reference
	player = get_parent() as CharacterBody2D
	
	# Get PlayerStats reference
	if player and player.has_node("PlayerStats"):
		player_stats = player.get_node("PlayerStats")

func _process(_delta: float) -> void:
	# Update SlowArea position to follow player
	if player:
		slow_area.global_position = player.global_position
		slow_visual.global_position = player.global_position - Vector2(80, 80)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("use_chrono_rift") and not is_on_cooldown:
		activate_slow()

func activate_slow() -> void:
	# Check mana cost
	if player_stats and not player_stats.use_mana(MANA_COST):
		print("CHRONO RIFT — Not enough mana! Need %d mana" % MANA_COST)
		return
	
	is_on_cooldown = true
	cooldown_timer.start(RIFT_COOLDOWN)
	
	# Emit cooldown started signal
	EventBus.chrono_rift_cooldown_started.emit(RIFT_COOLDOWN)
	
	# Debug: Check if SlowArea is working
	print("CHRONO RIFT — SLOW activated (-%d mana)" % MANA_COST)
	print("SlowArea monitoring: ", slow_area.monitoring)
	print("SlowArea position: ", slow_area.global_position)
	
	# Get all bodies in radius
	var bodies_in_range = slow_area.get_overlapping_bodies()
	print("Total bodies detected: ", bodies_in_range.size())
	
	var enemy_count = 0
	
	# Debug each body
	for body in bodies_in_range:
		print("  - Body found: ", body.name, " | In 'enemies' group: ", body.is_in_group("enemies"))
		if body.is_in_group("enemies") and body.has_method("apply_slow"):
			body.apply_slow(SLOW_FACTOR)
			slowed_enemies.append(body)
			enemy_count += 1
	
	print("Enemies slowed: ", enemy_count)
	slow_visual.visible = true
	
	# Remove slow after duration
	await get_tree().create_timer(SLOW_DURATION).timeout
	_remove_slow()
	slow_visual.visible = false

func _remove_slow() -> void:
	for enemy in slowed_enemies:
		if is_instance_valid(enemy) and enemy.has_method("remove_slow"):
			enemy.remove_slow()
	slowed_enemies.clear()

func _on_cooldown_timer_timeout() -> void:
	is_on_cooldown = false
	print("Chrono Rift ready")
	
	# Emit ready signal
	EventBus.chrono_rift_ready.emit()

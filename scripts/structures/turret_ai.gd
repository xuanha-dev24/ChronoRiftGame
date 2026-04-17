extends Node
class_name TurretAI

## AI component for Turret structures
## Handles enemy scanning, target selection, rotation, and projectile firing

# Constants
const SCAN_RANGE: float = 150.0
const ATTACK_COOLDOWN: float = 1.5
const PROJECTILE_SPEED: float = 200.0
const PROJECTILE_DAMAGE: int = 15
const PROJECTILE_MAX_DISTANCE: float = 200.0
const SCAN_INTERVAL: float = 0.5
const MAX_TURRETS_PER_FRAME: int = 10

# Static variables for staggering
static var turrets_processed_this_frame: int = 0
static var frame_counter: int = 0

# Properties
var current_target: Node2D = null
var attack_cooldown_timer: float = 0.0
var scan_timer: float = 0.0
var turret: Node2D = null  # Reference to parent turret
var update_group: int = 0  # Which update group this turret belongs to

# Projectile scene
var projectile_scene: PackedScene = null

func _ready() -> void:
	# Load projectile scene
	projectile_scene = load("res://scenes/structures/TurretProjectile.tscn")
	if not projectile_scene:
		push_error("[TurretAI] Failed to load TurretProjectile scene")
	
	# Assign update group based on current turret count
	var all_turrets = get_tree().get_nodes_in_group("turret_ai")
	update_group = all_turrets.size() % MAX_TURRETS_PER_FRAME
	
	# Add to turret_ai group for tracking
	add_to_group("turret_ai")

func _process(delta: float) -> void:
	if not turret:
		return
	
	# Reset frame counter at the start of each frame
	var current_frame = Engine.get_process_frames()
	if current_frame != frame_counter:
		frame_counter = current_frame
		turrets_processed_this_frame = 0
	
	# Check if we've reached the limit for this frame
	if turrets_processed_this_frame >= MAX_TURRETS_PER_FRAME:
		return  # Skip processing this turret this frame
	
	# Increment counter
	turrets_processed_this_frame += 1
	
	# Update scan timer
	scan_timer -= delta
	if scan_timer <= 0.0:
		scan_timer = SCAN_INTERVAL
		scan_for_enemies()
	
	# Validate current target
	if not is_target_valid():
		current_target = null
	
	# If we have a valid target
	if current_target:
		# Rotate toward target
		rotate_to_target(delta)
		
		# Update attack cooldown
		attack_cooldown_timer -= delta
		
		# Fire projectile when cooldown ready
		if attack_cooldown_timer <= 0.0:
			fire_projectile()
			attack_cooldown_timer = ATTACK_COOLDOWN

## Scan for enemies within range
func scan_for_enemies() -> void:
	if not turret:
		return
	
	var enemies = get_tree().get_nodes_in_group("enemies")
	var enemies_in_range: Array = []
	
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		
		var distance = turret.global_position.distance_to(enemy.global_position)
		if distance <= SCAN_RANGE:
			enemies_in_range.append(enemy)
	
	# Select closest enemy
	if not enemies_in_range.is_empty():
		current_target = select_closest_enemy(enemies_in_range)

## Select the closest enemy from an array of enemies
func select_closest_enemy(enemies: Array) -> Node2D:
	if enemies.is_empty():
		return null
	
	var closest_enemy: Node2D = null
	var closest_distance: float = INF
	
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		
		var distance = turret.global_position.distance_to(enemy.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_enemy = enemy
	
	return closest_enemy

## Check if current target is still valid
func is_target_valid() -> bool:
	if not current_target:
		return false
	
	if not is_instance_valid(current_target):
		return false
	
	var distance = turret.global_position.distance_to(current_target.global_position)
	if distance > SCAN_RANGE:
		return false
	
	return true

## Rotate turret to face target
func rotate_to_target(_delta: float) -> void:
	# Prefix unused parameter with underscore to suppress warning
	if not current_target or not turret:
		return
	
	# Calculate angle to target
	var direction = current_target.global_position - turret.global_position
	var target_angle = direction.angle()
	
	# Set turret rotation
	turret.rotation = target_angle

## Fire projectile toward target
func fire_projectile() -> void:
	if not current_target or not turret or not projectile_scene:
		return
	
	# Instantiate projectile
	var projectile = projectile_scene.instantiate()
	var tree = get_tree()
	if tree == null:
		projectile.queue_free()
		return

	var projectile_parent = tree.current_scene
	if projectile_parent == null:
		projectile_parent = tree.root

	var ysort_root = projectile_parent.get_node_or_null("YSortRoot")
	if ysort_root != null:
		projectile_parent = ysort_root

	# Add projectile to scene
	projectile_parent.add_child(projectile)
	
	# Initialize projectile
	projectile.initialize(turret.global_position, current_target.global_position, PROJECTILE_DAMAGE)
	
	# Optional: Emit signal for turret fired event
	# EventBus.turret_fired.emit(turret.global_position)

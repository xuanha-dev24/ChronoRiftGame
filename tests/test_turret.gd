extends GutTest

## Unit tests for Turret structure and TurretAI component
## Tests turret properties, AI behavior, target selection, and rotation

var turret_scene = preload("res://scenes/structures/Turret.tscn")
var turret: Structure
var turret_ai: TurretAI  # Changed back to TurretAI type

func before_each():
	turret = turret_scene.instantiate()
	add_child_autofree(turret)
	turret.initialize(Vector2i(15, 15))
	turret_ai = turret.get_node("TurretAI") as TurretAI
	
	# Verify turret_ai was found
	if turret_ai == null:
		fail_test("TurretAI node not found in turret scene")

func after_each():
	turret = null
	turret_ai = null

# ===== Task 13.2: Turret Properties =====

func test_turret_has_correct_type():
	# Turret should have type 'turret'
	assert_eq(turret.structure_type, "turret", "Turret should have type 'turret'")

func test_turret_has_correct_max_health():
	# Turret should have 150 max health
	assert_eq(turret.max_health, 150, "Turret should have 150 max health")

func test_turret_has_correct_grid_size():
	# Turret should occupy 1x1 grid
	assert_eq(turret.grid_size, Vector2i(1, 1), "Turret should be 1x1 grid size")

func test_turret_has_correct_resource_costs():
	# Turret should cost 15 wood + 10 stone
	assert_eq(turret.resource_costs, {"wood": 15, "stone": 10}, "Turret should cost 15 wood + 10 stone")

func test_turret_has_ai_component():
	# Turret should have TurretAI component
	assert_not_null(turret_ai, "Turret should have TurretAI component")
	assert_true(turret_ai is TurretAI, "AI component should be TurretAI class")

# ===== Task 13.4: TurretAI Constants =====

func test_turret_ai_has_correct_constants():
	# Verify AI constants
	assert_eq(turret_ai.SCAN_RANGE, 150.0, "Scan range should be 150.0")
	assert_eq(turret_ai.ATTACK_COOLDOWN, 1.5, "Attack cooldown should be 1.5")
	assert_eq(turret_ai.PROJECTILE_SPEED, 200.0, "Projectile speed should be 200.0")
	assert_eq(turret_ai.PROJECTILE_DAMAGE, 15, "Projectile damage should be 15")
	assert_eq(turret_ai.PROJECTILE_MAX_DISTANCE, 200.0, "Projectile max distance should be 200.0")
	assert_eq(turret_ai.SCAN_INTERVAL, 0.5, "Scan interval should be 0.5")

# ===== Task 13.5: Enemy Scanning and Target Selection =====

func test_turret_ai_initializes_with_no_target():
	# AI should start with no target
	assert_null(turret_ai.current_target, "AI should start with no target")

func test_select_closest_enemy_returns_null_for_empty_array():
	# Should return null for empty array
	var empty_array = []
	var result = turret_ai.select_closest_enemy(empty_array)
	assert_null(result, "Should return null for empty array")

func test_select_closest_enemy_returns_single_enemy():
	# Create mock enemy
	var enemy = Node2D.new()
	enemy.global_position = turret.global_position + Vector2(50, 0)
	add_child_autofree(enemy)
	
	var enemies_array = [enemy]
	var result = turret_ai.select_closest_enemy(enemies_array)
	assert_eq(result, enemy, "Should return the single enemy")

func test_select_closest_enemy_returns_closest_of_multiple():
	# Create multiple mock enemies at different distances
	var enemy1 = Node2D.new()
	enemy1.global_position = turret.global_position + Vector2(100, 0)
	add_child_autofree(enemy1)
	
	var enemy2 = Node2D.new()
	enemy2.global_position = turret.global_position + Vector2(50, 0)
	add_child_autofree(enemy2)
	
	var enemy3 = Node2D.new()
	enemy3.global_position = turret.global_position + Vector2(75, 0)
	add_child_autofree(enemy3)
	
	var enemies_array = [enemy1, enemy2, enemy3]
	var result = turret_ai.select_closest_enemy(enemies_array)
	assert_eq(result, enemy2, "Should return the closest enemy (50px away)")

func test_is_target_valid_returns_false_for_null():
	# Should return false for null target
	turret_ai.current_target = null
	assert_false(turret_ai.is_target_valid(), "Should return false for null target")

func test_is_target_valid_returns_false_for_out_of_range():
	# Create enemy outside scan range
	var enemy = Node2D.new()
	enemy.global_position = turret.global_position + Vector2(200, 0)  # Beyond 150px range
	add_child_autofree(enemy)
	
	turret_ai.current_target = enemy
	assert_false(turret_ai.is_target_valid(), "Should return false for out of range target")

func test_is_target_valid_returns_true_for_in_range():
	# Create enemy within scan range
	var enemy = Node2D.new()
	enemy.global_position = turret.global_position + Vector2(100, 0)  # Within 150px range
	add_child_autofree(enemy)
	
	turret_ai.current_target = enemy
	assert_true(turret_ai.is_target_valid(), "Should return true for in range target")

# ===== Task 13.7: Turret Rotation =====

func test_rotate_to_target_points_at_target():
	# Create enemy to the right of turret
	var enemy = Node2D.new()
	enemy.global_position = turret.global_position + Vector2(100, 0)
	add_child_autofree(enemy)
	
	turret_ai.current_target = enemy
	turret_ai.rotate_to_target(0.016)  # One frame
	
	# Turret should be pointing right (0 radians)
	assert_almost_eq(turret.rotation, 0.0, 0.01, "Turret should point right at target")

func test_rotate_to_target_points_down():
	# Create enemy below turret
	var enemy = Node2D.new()
	enemy.global_position = turret.global_position + Vector2(0, 100)
	add_child_autofree(enemy)
	
	turret_ai.current_target = enemy
	turret_ai.rotate_to_target(0.016)
	
	# Turret should be pointing down (PI/2 radians)
	assert_almost_eq(turret.rotation, PI/2, 0.01, "Turret should point down at target")

func test_rotate_to_target_points_left():
	# Create enemy to the left of turret
	var enemy = Node2D.new()
	enemy.global_position = turret.global_position + Vector2(-100, 0)
	add_child_autofree(enemy)
	
	turret_ai.current_target = enemy
	turret_ai.rotate_to_target(0.016)
	
	# Turret should be pointing left (PI radians)
	assert_almost_eq(abs(turret.rotation), PI, 0.01, "Turret should point left at target")

# ===== Task 13.9: Turret AI Main Loop =====

func test_turret_ai_scan_timer_decrements():
	# Set scan timer to known value
	turret_ai.scan_timer = 1.0
	
	# Process one frame
	turret_ai._process(0.1)
	
	# Timer should have decremented
	assert_almost_eq(turret_ai.scan_timer, 0.9, 0.01, "Scan timer should decrement")

func test_turret_ai_attack_cooldown_decrements_with_target():
	# Create enemy within range
	var enemy = Node2D.new()
	enemy.global_position = turret.global_position + Vector2(100, 0)
	add_child_autofree(enemy)
	
	turret_ai.current_target = enemy
	turret_ai.attack_cooldown_timer = 1.0
	
	# Process one frame
	turret_ai._process(0.1)
	
	# Cooldown should have decremented
	assert_almost_eq(turret_ai.attack_cooldown_timer, 0.9, 0.01, "Attack cooldown should decrement")

# ===== Collision Shape Sizing =====

func test_turret_collision_shape_size():
	# Collision shape should match grid size
	var collision_shape = turret.get_node("CollisionShape2D")
	var shape = collision_shape.shape as RectangleShape2D
	
	var expected_size = Vector2(float(turret.grid_size.x * 16), float(turret.grid_size.y * 16))
	assert_eq(shape.size, expected_size, "Collision shape should be 16x16 pixels")

func test_turret_visual_size():
	# Visual should match grid size
	var visual = turret.get_node("Visual") as ColorRect
	var visual_size = visual.size
	
	assert_eq(visual_size, Vector2(16.0, 16.0), "Visual should be 16x16 pixels")

func test_turret_has_directional_indicator():
	# Turret should have directional indicator
	var indicator = turret.get_node("Visual/DirectionalIndicator")
	assert_not_null(indicator, "Turret should have directional indicator")

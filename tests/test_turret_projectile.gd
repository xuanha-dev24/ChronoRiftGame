extends GutTest

## Unit tests for TurretProjectile
## Tests projectile movement, collision, and lifetime

var projectile_scene = preload("res://scenes/structures/TurretProjectile.tscn")
var projectile: Area2D

func before_each():
	projectile = projectile_scene.instantiate()
	add_child_autofree(projectile)

func after_each():
	projectile = null

# ===== Task 14.2: Projectile Properties =====

func test_projectile_initializes_with_correct_properties():
	# Initialize projectile
	var start_pos = Vector2(100, 100)
	var target_pos = Vector2(200, 100)
	var dmg = 15
	
	projectile.initialize(start_pos, target_pos, dmg)
	
	# Check properties
	assert_eq(projectile.global_position, start_pos, "Projectile should start at start_pos")
	assert_eq(projectile.damage, dmg, "Projectile should have correct damage")
	assert_eq(projectile.target_position, target_pos, "Projectile should have correct target")

func test_projectile_velocity_magnitude():
	# Initialize projectile moving right
	var start_pos = Vector2(100, 100)
	var target_pos = Vector2(200, 100)
	
	projectile.initialize(start_pos, target_pos, 15)
	
	# Velocity magnitude should be 200 px/s
	var velocity_magnitude = projectile.velocity.length()
	assert_almost_eq(velocity_magnitude, 200.0, 0.1, "Velocity magnitude should be 200 px/s")

func test_projectile_velocity_direction():
	# Initialize projectile moving right
	var start_pos = Vector2(100, 100)
	var target_pos = Vector2(200, 100)
	
	projectile.initialize(start_pos, target_pos, 15)
	
	# Velocity should point right (normalized direction = (1, 0))
	var direction = projectile.velocity.normalized()
	assert_almost_eq(direction.x, 1.0, 0.01, "Direction should point right")
	assert_almost_eq(direction.y, 0.0, 0.01, "Direction should be horizontal")

func test_projectile_velocity_diagonal():
	# Initialize projectile moving diagonally
	var start_pos = Vector2(100, 100)
	var target_pos = Vector2(200, 200)
	
	projectile.initialize(start_pos, target_pos, 15)
	
	# Velocity should point diagonally (normalized direction ≈ (0.707, 0.707))
	var direction = projectile.velocity.normalized()
	assert_almost_eq(direction.x, 0.707, 0.01, "Direction X should be ~0.707")
	assert_almost_eq(direction.y, 0.707, 0.01, "Direction Y should be ~0.707")

# ===== Task 14.2: Projectile Movement =====

func test_projectile_moves_toward_target():
	# Initialize projectile
	var start_pos = Vector2(100, 100)
	var target_pos = Vector2(200, 100)
	
	projectile.initialize(start_pos, target_pos, 15)
	
	# Process one frame (0.016s ≈ 60fps)
	projectile._process(0.016)
	
	# Projectile should have moved right
	assert_gt(projectile.global_position.x, start_pos.x, "Projectile should move right")
	assert_almost_eq(projectile.global_position.y, start_pos.y, 0.1, "Projectile should stay on Y axis")

func test_projectile_tracks_distance_traveled():
	# Initialize projectile
	var start_pos = Vector2(100, 100)
	var target_pos = Vector2(200, 100)
	
	projectile.initialize(start_pos, target_pos, 15)
	
	# Process one second
	projectile._process(1.0)
	
	# Distance traveled should be approximately 200 pixels (200 px/s * 1s)
	assert_almost_eq(projectile.distance_traveled, 200.0, 1.0, "Distance traveled should be ~200px")

# ===== Task 14.2: Projectile Lifetime =====

func test_projectile_despawns_after_max_distance():
	# Initialize projectile
	var start_pos = Vector2(100, 100)
	var target_pos = Vector2(400, 100)  # Far target
	
	projectile.initialize(start_pos, target_pos, 15)
	
	# Manually set distance traveled to just under max
	projectile.distance_traveled = 199.0
	
	# Process one frame
	projectile._process(0.1)  # Move 20 pixels
	
	# Projectile should be queued for deletion (distance_traveled >= 200)
	await wait_physics_frames(1)
	assert_false(is_instance_valid(projectile), "Projectile should despawn after 200px")

# ===== Collision Detection =====

func test_projectile_collision_mask():
	# Projectile should only collide with enemies (layer 2)
	assert_eq(projectile.collision_mask, 2, "Projectile should have collision mask 2 (enemies)")

func test_projectile_collision_layer():
	# Projectile should not be on any collision layer
	assert_eq(projectile.collision_layer, 0, "Projectile should have collision layer 0")

func test_projectile_has_collision_shape():
	# Projectile should have collision shape
	var collision_shape = projectile.get_node("CollisionShape2D")
	assert_not_null(collision_shape, "Projectile should have CollisionShape2D")
	
	var shape = collision_shape.shape as CircleShape2D
	assert_not_null(shape, "Collision shape should be CircleShape2D")
	assert_eq(shape.radius, 2.0, "Collision shape radius should be 2.0")

func test_projectile_visual_size():
	# Visual should be 4x4 pixels
	var visual = projectile.get_node("Visual") as ColorRect
	assert_not_null(visual, "Projectile should have Visual node")
	
	var visual_size = visual.size
	assert_eq(visual_size, Vector2(4.0, 4.0), "Visual should be 4x4 pixels")

func test_projectile_visual_color():
	# Visual should be yellow
	var visual = projectile.get_node("Visual") as ColorRect
	assert_eq(visual.color, Color(1, 1, 0, 1), "Visual should be yellow")

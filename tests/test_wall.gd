extends GutTest

## Unit tests for Wall structure
## Tests wall-specific properties and behavior

var wall_scene = preload("res://scenes/structures/Wall.tscn")
var wall: Structure

func before_each():
	wall = wall_scene.instantiate()
	add_child_autofree(wall)
	wall.initialize(Vector2i(10, 10))

func after_each():
	wall = null

# ===== Task 5.2: Wall Properties =====

func test_wall_has_correct_type():
	# REQ-005.2: Wall has correct structure type
	assert_eq(wall.structure_type, "wall", "Wall should have type 'wall'")

func test_wall_has_correct_max_health():
	# Wall should have 100 max health
	assert_eq(wall.max_health, 100, "Wall should have 100 max health")

func test_wall_has_correct_grid_size():
	# Wall should occupy 1x1 grid
	assert_eq(wall.grid_size, Vector2i(1, 1), "Wall should be 1x1 grid size")

func test_wall_has_correct_resource_costs():
	# Wall should cost 10 wood
	assert_eq(wall.resource_costs, {"wood": 10}, "Wall should cost 10 wood")

# ===== Task 5.3: Collision Shape Sizing =====

func test_wall_collision_shape_size():
	# REQ-018.3: Collision shape matches grid size
	var collision_shape = wall.get_node("CollisionShape2D")
	var shape = collision_shape.shape as RectangleShape2D
	
	var expected_size = Vector2(float(wall.grid_size.x * 16), float(wall.grid_size.y * 16))
	assert_eq(shape.size, expected_size, "Collision shape should be 16x16 pixels")

func test_wall_visual_size():
	# Visual should match grid size
	var visual = wall.get_node("Visual") as ColorRect
	var visual_size = visual.size
	
	assert_eq(visual_size, Vector2(16.0, 16.0), "Visual should be 16x16 pixels")

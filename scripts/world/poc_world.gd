# poc_world.gd
# POC World setup script
extends Node2D

func _ready() -> void:
	_spawn_test_tree()
	print("POC World loaded")
	print("Controls: WASD=Move | Z=Attack | X=Chrono Rift")

func _spawn_test_tree() -> void:
	# Create a test object for Y-Sort validation
	var tree = ColorRect.new()
	tree.size = Vector2(20, 60)
	tree.color = Color(0.3, 0.6, 0.2)
	tree.position = Vector2(200, 150)
	tree.z_index = 0  # Ensure it participates in Y-sort
	
	# Y-Sort uses position.y to determine layer
	# Player with higher Y (below tree) should render on top
	$YSortRoot.add_child(tree)
	
	print("Test tree spawned at (200, 150) for Y-Sort validation")
	print("Walk above (Y<150) and below (Y>150) the tree to test")

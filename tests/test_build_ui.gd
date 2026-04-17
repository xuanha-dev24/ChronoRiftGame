# test_build_ui.gd
# Unit tests for Build_UI
extends GutTest

var build_ui: CanvasLayer
var building_system: Node

func before_each():
	# Get Building_System autoload
	building_system = get_node("/root/Building_System")
	
	# Load and instantiate Build_UI scene
	var build_ui_scene = load("res://scenes/ui/Build_UI.tscn")
	build_ui = build_ui_scene.instantiate()
	add_child_autofree(build_ui)
	
	# Wait for ready
	await wait_physics_frames(1)

func after_each():
	# Clean up
	if build_ui and is_instance_valid(build_ui):
		build_ui.queue_free()

func test_build_ui_initializes():
	assert_not_null(build_ui, "Build_UI should instantiate")
	assert_false(build_ui.visible, "Build_UI should be hidden initially")

func test_build_ui_shows_on_build_mode_active():
	# Activate build mode
	EventBus.build_mode_changed.emit(true)
	await wait_physics_frames(1)
	
	assert_true(build_ui.visible, "Build_UI should be visible when build mode is active")

func test_build_ui_hides_on_build_mode_inactive():
	# Activate then deactivate build mode
	EventBus.build_mode_changed.emit(true)
	await wait_physics_frames(1)
	EventBus.build_mode_changed.emit(false)
	await wait_physics_frames(1)
	
	assert_false(build_ui.visible, "Build_UI should be hidden when build mode is inactive")

func test_resource_display_updates():
	# Show UI
	build_ui.show_build_ui()
	await wait_physics_frames(1)
	
	# Set resources
	ResourceManager.set_resource("wood", 50)
	ResourceManager.set_resource("stone", 30)
	
	# Trigger update
	build_ui.update_resource_display()
	await wait_physics_frames(1)
	
	# Check labels
	var wood_label = build_ui.get_node("Panel/VBoxContainer/ResourceDisplay/WoodRow/Label")
	var stone_label = build_ui.get_node("Panel/VBoxContainer/ResourceDisplay/StoneRow/Label")
	
	assert_eq(wood_label.text, "Wood: 50", "Wood label should show correct amount")
	assert_eq(stone_label.text, "Stone: 30", "Stone label should show correct amount")

func test_button_states_update_based_on_resources():
	# Show UI
	build_ui.show_build_ui()
	await wait_physics_frames(1)
	
	# Set insufficient resources
	ResourceManager.set_resource("wood", 5)
	ResourceManager.set_resource("stone", 0)
	
	# Update button states
	build_ui.update_button_states()
	await wait_physics_frames(1)
	
	# Check wall button (needs 10 wood)
	var wall_button = build_ui.get_node("Panel/VBoxContainer/StructureButtons/WallButton")
	assert_true(wall_button.disabled, "Wall button should be disabled with insufficient resources")
	assert_almost_eq(wall_button.modulate.a, 0.5, 0.01, "Wall button should have 50% opacity")
	
	# Set sufficient resources
	ResourceManager.set_resource("wood", 50)
	ResourceManager.set_resource("stone", 30)
	
	# Update button states
	build_ui.update_button_states()
	await wait_physics_frames(1)
	
	# Check wall button again
	assert_false(wall_button.disabled, "Wall button should be enabled with sufficient resources")
	assert_almost_eq(wall_button.modulate.a, 1.0, 0.01, "Wall button should have 100% opacity")

func test_button_highlight():
	# Show UI
	build_ui.show_build_ui()
	await wait_physics_frames(1)
	
	# Highlight wall button
	build_ui.highlight_button("wall")
	await wait_physics_frames(1)
	
	var wall_button = build_ui.get_node("Panel/VBoxContainer/StructureButtons/WallButton")
	assert_not_null(build_ui.highlighted_button, "Highlighted button should be set")
	assert_eq(build_ui.highlighted_button, wall_button, "Wall button should be highlighted")

func test_clear_button_highlights():
	# Show UI
	build_ui.show_build_ui()
	await wait_physics_frames(1)
	
	# Highlight then clear
	build_ui.highlight_button("wall")
	await wait_physics_frames(1)
	build_ui.clear_button_highlights()
	await wait_physics_frames(1)
	
	assert_null(build_ui.highlighted_button, "Highlighted button should be cleared")

func test_error_message_display():
	# Show UI
	build_ui.show_build_ui()
	await wait_physics_frames(1)
	
	# Show error message
	build_ui.show_error_message("Test error message")
	await wait_physics_frames(1)
	
	var error_label = build_ui.get_node("Panel/VBoxContainer/ErrorMessage")
	assert_eq(error_label.text, "Test error message", "Error message should be displayed")

func test_structure_button_calls_building_system():
	# Show UI
	build_ui.show_build_ui()
	await wait_physics_frames(1)
	
	# Set sufficient resources
	ResourceManager.set_resource("wood", 50)
	ResourceManager.set_resource("stone", 30)
	build_ui.update_button_states()
	await wait_physics_frames(1)
	
	# Click wall button
	var wall_button = build_ui.get_node("Panel/VBoxContainer/StructureButtons/WallButton")
	wall_button.pressed.emit()
	await wait_physics_frames(1)
	
	# Check that Building_System selected the structure
	assert_eq(building_system.selected_structure_type, "wall", "Building_System should have wall selected")

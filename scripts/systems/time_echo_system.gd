# time_echo_system.gd
# Manages Time Echo mechanic (player death creates echo with items)
extends Node

const TIME_ECHO_SCENE = preload("res://scenes/systems/TimeEcho.tscn")

var active_echoes: Array[Node2D] = []

func _ready() -> void:
	EventBus.player_died.connect(_on_player_died)

func create_time_echo(position: Vector2, items: Array) -> void:
	# TODO: Instantiate TimeEcho scene
	print("Time Echo created at: ", position, " with items: ", items)
	EventBus.time_echo_spawned.emit(position, items)
	
	# Placeholder for actual echo creation
	# var echo = TIME_ECHO_SCENE.instantiate()
	# echo.global_position = position
	# echo.set_items(items)
	# get_tree().current_scene.add_child(echo)
	# active_echoes.append(echo)

func collect_time_echo(echo: Node2D) -> void:
	if echo in active_echoes:
		active_echoes.erase(echo)
		# TODO: Return items to player inventory
		echo.queue_free()

func _on_player_died(position: Vector2) -> void:
	# Get items from player inventory
	var player_items: Array = []
	# TODO: Get actual items from player inventory
	
	create_time_echo(position, player_items)

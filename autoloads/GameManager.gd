# GameManager.gd
# Manages global game state and core systems
extends Node

enum GameState {
	MAIN_MENU,
	PLAYING,
	PAUSED,
	DEAD,
	LOADING
}

var current_state: GameState = GameState.MAIN_MENU
var player: CharacterBody2D = null
var is_game_paused: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and current_state == GameState.PLAYING:
		toggle_pause()

func set_game_state(new_state: GameState) -> void:
	current_state = new_state
	match new_state:
		GameState.PLAYING:
			resume_game()
		GameState.PAUSED:
			pause_game()
		GameState.DEAD:
			handle_player_death()

func pause_game() -> void:
	if current_state != GameState.PLAYING:
		return
	is_game_paused = true
	get_tree().paused = true
	EventBus.ui_opened.emit("pause_menu")

func resume_game() -> void:
	is_game_paused = false
	get_tree().paused = false
	EventBus.ui_closed.emit("pause_menu")

func toggle_pause() -> void:
	if is_game_paused:
		resume_game()
	else:
		pause_game()

func handle_player_death() -> void:
	# Placeholder for death handling logic
	print("Player died!")

func register_player(player_node: CharacterBody2D) -> void:
	player = player_node
	print("Player registered to GameManager")

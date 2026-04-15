# player_state_machine.gd
# State machine for player
class_name PlayerStateMachine
extends Node

enum State {
	IDLE,
	WALK,
	ATTACK,
	DEAD
}

var current_state: State = State.IDLE
var previous_state: State = State.IDLE

@onready var player: CharacterBody2D = get_parent()

func _ready() -> void:
	call_deferred("_enter_state", current_state)
	print("PlayerStateMachine initialized - Current state: %s" % State.keys()[current_state])

func _physics_process(_delta: float) -> void:
	match current_state:
		State.IDLE:
			process_idle()
		State.WALK:
			process_walk()
		State.ATTACK:
			process_attack()
		State.DEAD:
			process_dead()

func transition_to(new_state: State) -> void:
	if current_state == new_state:
		return
	
	_exit_state(current_state)
	previous_state = current_state
	current_state = new_state
	_enter_state(current_state)
	
	# Debug output
	print("State: %s → %s" % [State.keys()[previous_state], State.keys()[current_state]])

func _enter_state(state: State) -> void:
	match state:
		State.IDLE:
			enter_idle()
		State.WALK:
			enter_walk()
		State.ATTACK:
			enter_attack()
		State.DEAD:
			enter_dead()

func _exit_state(state: State) -> void:
	match state:
		State.IDLE:
			exit_idle()
		State.WALK:
			exit_walk()
		State.ATTACK:
			exit_attack()
		State.DEAD:
			exit_dead()

# ===== IDLE STATE =====
func enter_idle() -> void:
	pass

func process_idle() -> void:
	# Check for movement input
	if player.velocity.length() > 10:
		transition_to(State.WALK)
	
	# Check for attack input
	if player.is_attacking:
		transition_to(State.ATTACK)

func exit_idle() -> void:
	pass

# ===== WALK STATE =====
func enter_walk() -> void:
	pass

func process_walk() -> void:
	# Check if stopped moving
	if player.velocity.length() < 10:
		transition_to(State.IDLE)
	
	# Check for attack input
	if player.is_attacking:
		transition_to(State.ATTACK)

func exit_walk() -> void:
	pass

# ===== ATTACK STATE =====
func enter_attack() -> void:
	pass

func process_attack() -> void:
	# Return to previous state after attack
	if not player.is_attacking:
		if player.velocity.length() > 10:
			transition_to(State.WALK)
		else:
			transition_to(State.IDLE)

func exit_attack() -> void:
	pass

# ===== DEAD STATE =====
func enter_dead() -> void:
	player.velocity = Vector2.ZERO
	print("Player died!")

func process_dead() -> void:
	# Stay in dead state until respawn
	pass

func exit_dead() -> void:
	pass

# Helper function to get current state name
func get_state_name() -> String:
	return State.keys()[current_state]

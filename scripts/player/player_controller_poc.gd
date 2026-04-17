# player_controller_poc.gd
# POC: Handles isometric movement and basic attack
class_name PlayerControllerPOC
extends CharacterBody2D

const SPEED = 120.0

@onready var attack_area: Area2D = $AttackArea
@onready var attack_timer: Timer = $AttackCooldown

var can_attack: bool = true

func _physics_process(_delta: float) -> void:
	# Disable movement in build mode
	if Building_System.build_mode_active:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
		move_and_slide()
		return
	
	var input_dir = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
	
	if input_dir != Vector2.ZERO:
		input_dir = input_dir.normalized()
		# Convert to isometric space
		var iso_x = input_dir.x - input_dir.y
		var iso_y = (input_dir.x + input_dir.y) * 0.5
		velocity = Vector2(iso_x, iso_y).normalized() * SPEED
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
	
	move_and_slide()

func _input(event: InputEvent) -> void:
	# Disable attacks in build mode
	if Building_System.build_mode_active:
		return
	
	if event.is_action_pressed("attack") and can_attack:
		_do_attack()

func _do_attack() -> void:
	can_attack = false
	attack_timer.start()
	
	print("Player attacks!")
	
	# Damage enemies in AttackArea
	for body in attack_area.get_overlapping_bodies():
		if body.is_in_group("enemies") and body.has_method("take_damage"):
			body.take_damage(10)

func _on_attack_cooldown_timeout() -> void:
	can_attack = true

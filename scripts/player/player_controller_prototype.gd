# player_controller_prototype.gd
# Prototype player controller with animation support
class_name PlayerControllerPrototype
extends CharacterBody2D

const SPEED = 150.0
const ACCELERATION = 2500.0  # Increased for snappier response
const FRICTION = 1800.0

# HP System
@export var max_hp: int = 100
var current_hp: int = 100
var is_invincible: bool = false
var is_dead: bool = false

@onready var attack_area: Area2D = $AttackArea
@onready var attack_timer: Timer = $AttackCooldown
@onready var anim_controller: Node = $AnimationController
@onready var sprite: ColorRect = $Sprite

var can_attack: bool = true
var is_attacking: bool = false

func _ready() -> void:
	# Initialize HP
	current_hp = max_hp
	
	# Add to player group for enemy detection
	add_to_group("player")
	
	print("[Player] Initialized | HP: %d/%d" % [current_hp, max_hp])

func _physics_process(delta: float) -> void:
	var input_dir = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
	
	if input_dir != Vector2.ZERO:
		input_dir = input_dir.normalized()
		# Convert to isometric space
		var iso_x = input_dir.x - input_dir.y
		var iso_y = (input_dir.x + input_dir.y) * 0.5
		var target_velocity = Vector2(iso_x, iso_y).normalized() * SPEED
		
		# Faster acceleration for direction changes
		velocity = velocity.move_toward(target_velocity, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	move_and_slide()
	
	# Update animations
	if anim_controller:
		anim_controller.update_animation(velocity, is_attacking)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack") and can_attack:
		_do_attack()

func _do_attack() -> void:
	can_attack = false
	is_attacking = true
	attack_timer.start()
	
	print("Player attacks!")
	
	# Find closest enemy in AttackArea
	var closest_enemy: Node2D = null
	var closest_distance: float = INF
	
	for body in attack_area.get_overlapping_bodies():
		if body.is_in_group("enemies") and body.has_method("take_damage"):
			var distance = global_position.distance_to(body.global_position)
			if distance < closest_distance:
				closest_distance = distance
				closest_enemy = body
	
	# Damage only the closest enemy
	if closest_enemy:
		closest_enemy.take_damage(10)
		# Emit damage dealt signal for effects
		EventBus.damage_dealt.emit(closest_enemy, 10)
		
		# Print debug info (handle both POC and full enemies)
		var enemy_name = closest_enemy.enemy_type if "enemy_type" in closest_enemy else closest_enemy.get_class()
		print("Hit %s at distance %.1f" % [enemy_name, closest_distance])
	else:
		print("Attack missed - no enemies in range")
	
	# Reset attacking flag after animation
	await get_tree().create_timer(0.3).timeout
	is_attacking = false

func _on_attack_cooldown_timeout() -> void:
	can_attack = true

# ============================================================================
# COMBAT - DAMAGE SYSTEM
# ============================================================================

func take_damage(amount: int) -> void:
	"""Take damage from enemy attacks. Includes invincibility frames."""
	if is_invincible or is_dead:
		return  # Can't take damage during i-frames or when dead
	
	current_hp -= amount
	
	print("[Player] Took %d damage | HP: %d/%d" % [amount, current_hp, max_hp])
	
	# Emit signal for HUD update
	EventBus.player_damaged.emit(current_hp, max_hp)
	
	# Flash red for feedback
	_flash_damage()
	
	# Check for death
	if current_hp <= 0:
		_die()
	else:
		# Start invincibility frames
		_start_iframes()

func _flash_damage() -> void:
	"""Flash sprite red when taking damage."""
	if not sprite:
		return
	
	var original_color = sprite.color
	sprite.color = Color.RED
	
	await get_tree().create_timer(0.1).timeout
	
	if not is_dead:
		sprite.color = original_color

func _start_iframes() -> void:
	"""Start invincibility frames after taking damage."""
	is_invincible = true
	
	# Visual feedback: flashing sprite
	_flash_invincibility()
	
	# End i-frames after duration
	await get_tree().create_timer(0.5).timeout
	is_invincible = false
	
	print("[Player] I-frames ended")

func _flash_invincibility() -> void:
	"""Flash sprite during invincibility frames."""
	if not sprite:
		return
	
	var flash_count = 5
	var flash_duration = 0.1
	
	for i in range(flash_count):
		if is_dead:
			break
		
		sprite.modulate.a = 0.5
		await get_tree().create_timer(flash_duration).timeout
		sprite.modulate.a = 1.0
		await get_tree().create_timer(flash_duration).timeout

func _die() -> void:
	"""Handle player death."""
	if is_dead:
		return
	
	is_dead = true
	current_hp = 0
	
	print("[Player] DIED")
	
	# Emit death signal
	EventBus.player_died.emit(global_position)
	
	# Stop movement
	velocity = Vector2.ZERO
	
	# Disable input (could add a flag to check in _input)
	set_physics_process(false)
	
	# Fade out
	if sprite:
		var tween = create_tween()
		tween.tween_property(sprite, "modulate:a", 0.0, 1.0)
	
	# Wait for fade
	await get_tree().create_timer(1.0).timeout
	
	# Simple death message (will be replaced with proper death screen later)
	print("=== GAME OVER ===")
	print("Press R to restart (not implemented yet)")

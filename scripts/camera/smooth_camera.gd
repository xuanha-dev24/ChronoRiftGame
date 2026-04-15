# smooth_camera.gd
# Smooth camera that follows player
extends Camera2D

@export var follow_speed: float = 5.0
@export var look_ahead_distance: float = 50.0
@export var shake_decay: float = 5.0

var target: Node2D = null
var shake_strength: float = 0.0
var shake_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	# Find player
	await get_tree().process_frame
	target = get_tree().get_first_node_in_group("player")
	
	if target:
		global_position = target.global_position
		print("Camera locked on player")

func _process(delta: float) -> void:
	if not target:
		return
	
	# Calculate target position with look-ahead
	var target_pos = target.global_position
	if target is CharacterBody2D:
		var velocity = target.velocity
		if velocity.length() > 10:
			target_pos += velocity.normalized() * look_ahead_distance
	
	# Smooth follow
	global_position = global_position.lerp(target_pos, follow_speed * delta)
	
	# Apply screen shake
	if shake_strength > 0:
		shake_strength = max(shake_strength - shake_decay * delta, 0)
		shake_offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
		offset = shake_offset
	else:
		offset = Vector2.ZERO

func shake(strength: float) -> void:
	shake_strength = strength

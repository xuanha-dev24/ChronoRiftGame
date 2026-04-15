# player_animation_controller.gd
# Controls player animations based on state
extends Node

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: ColorRect = $"../Sprite"

var current_direction: Vector2 = Vector2.DOWN
var is_moving: bool = false
var is_attacking: bool = false

func _ready() -> void:
	_setup_animations()

func _setup_animations() -> void:
	# Create animations programmatically
	var anim_lib = AnimationLibrary.new()
	
	# Idle animation
	anim_lib.add_animation("idle", _create_idle_animation())
	
	# Walk animation
	anim_lib.add_animation("walk", _create_walk_animation())
	
	# Attack animation
	anim_lib.add_animation("attack", _create_attack_animation())
	
	animation_player.add_animation_library("", anim_lib)
	animation_player.play("idle")

func _create_idle_animation() -> Animation:
	var anim = Animation.new()
	anim.length = 1.0
	anim.loop_mode = Animation.LOOP_LINEAR
	
	# Bright color pulse for idle - very visible
	var track_idx = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(track_idx, "../Sprite:color")
	anim.track_insert_key(track_idx, 0.0, Color(0.2, 1.0, 0.2))  # Bright green
	anim.track_insert_key(track_idx, 0.5, Color(1.0, 1.0, 0.2))  # Yellow-green
	anim.track_insert_key(track_idx, 1.0, Color(0.2, 1.0, 0.2))  # Back to bright green
	
	return anim

func _create_walk_animation() -> Animation:
	var anim = Animation.new()
	anim.length = 0.4
	anim.loop_mode = Animation.LOOP_LINEAR
	
	# Color change for walking - cyan to blue
	var color_track = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(color_track, "../Sprite:color")
	anim.track_insert_key(color_track, 0.0, Color(0.2, 1.0, 1.0))  # Cyan
	anim.track_insert_key(color_track, 0.2, Color(0.2, 0.5, 1.0))  # Blue
	anim.track_insert_key(color_track, 0.4, Color(0.2, 1.0, 1.0))  # Back to cyan
	
	# Bounce effect for walking
	var bounce_track = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(bounce_track, "../Sprite:position:y")
	anim.track_insert_key(bounce_track, 0.0, -12.0)
	anim.track_insert_key(bounce_track, 0.2, -14.0)
	anim.track_insert_key(bounce_track, 0.4, -12.0)
	
	return anim

func _create_attack_animation() -> Animation:
	var anim = Animation.new()
	anim.length = 0.3
	anim.loop_mode = Animation.LOOP_NONE
	
	# Flash red and scale up for attack
	var color_track = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(color_track, "../Sprite:color")
	anim.track_insert_key(color_track, 0.0, Color(0.2, 0.8, 0.2))
	anim.track_insert_key(color_track, 0.1, Color(1.0, 0.3, 0.3))
	anim.track_insert_key(color_track, 0.3, Color(0.2, 0.8, 0.2))
	
	var scale_track = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(scale_track, "../Sprite:scale")
	anim.track_insert_key(scale_track, 0.0, Vector2(1.0, 1.0))
	anim.track_insert_key(scale_track, 0.15, Vector2(1.3, 1.3))
	anim.track_insert_key(scale_track, 0.3, Vector2(1.0, 1.0))
	
	return anim

func update_animation(velocity: Vector2, attacking: bool) -> void:
	is_moving = velocity.length() > 0
	is_attacking = attacking
	
	if is_attacking:
		if animation_player.current_animation != "attack":
			animation_player.play("attack")
	elif is_moving:
		if animation_player.current_animation != "walk":
			animation_player.play("walk")
		_update_direction(velocity)
	else:
		if animation_player.current_animation != "idle":
			animation_player.play("idle")

func _update_direction(velocity: Vector2) -> void:
	# Update sprite flip based on movement direction
	if velocity.x < 0:
		sprite.scale.x = -1
	elif velocity.x > 0:
		sprite.scale.x = 1

# effect_manager.gd
# Manages visual effects and screen shake
extends Node

const HIT_EFFECT_SCENE = preload("res://scenes/effects/HitEffect.tscn")
const PICKUP_EFFECT_SCENE = preload("res://scenes/effects/PickUpEffect.tscn")

var camera: Camera2D = null

func _ready() -> void:
	# Find camera
	await get_tree().process_frame
	camera = get_tree().get_first_node_in_group("camera")
	
	# Connect to events
	EventBus.damage_dealt.connect(_on_damage_dealt)
	EventBus.chrono_rift_used.connect(_on_chrono_rift_used)
	EventBus.spawn_effect.connect(_on_spawn_effect)

func _on_damage_dealt(target: Node, amount: int) -> void:
	# Screen shake
	if camera and camera.has_method("shake"):
		camera.shake(5.0)
	
	# Spawn hit effect
	if target and HIT_EFFECT_SCENE:
		var hit_effect = HIT_EFFECT_SCENE.instantiate()
		hit_effect.global_position = target.global_position
		get_tree().current_scene.add_child(hit_effect)

func _on_chrono_rift_used(type: String) -> void:
	# Screen shake for chrono rift
	if camera and camera.has_method("shake"):
		camera.shake(8.0)

func _on_spawn_effect(effect_name: String, position: Vector2) -> void:
	# Spawn effect by name at position
	print("[EffectManager] ========================================")
	print("[EffectManager] Received spawn_effect signal")
	print("[EffectManager] Effect name: %s" % effect_name)
	print("[EffectManager] Requested position: %s" % position)
	
	var effect_scene = null
	
	match effect_name:
		"hit_effect":
			effect_scene = HIT_EFFECT_SCENE
		"pickup_effect":
			effect_scene = PICKUP_EFFECT_SCENE
		_:
			push_warning("Unknown effect: %s" % effect_name)
			return
	
	if effect_scene:
		print("[EffectManager] Instantiating effect...")
		var effect = effect_scene.instantiate()
		
		print("[EffectManager] Adding to current_scene...")
		# Add to current scene first
		get_tree().current_scene.add_child(effect)
		
		print("[EffectManager] Effect added, setting global_position to: ", position)
		# Then set position (must be after add_child for global_position to work correctly)
		effect.global_position = position
		
		print("[EffectManager] Effect final global_position: ", effect.global_position)
		print("[EffectManager] Effect final position: ", effect.position)
		print("[EffectManager] ========================================")
	else:
		print("[EffectManager] ERROR: effect_scene is null for %s" % effect_name)

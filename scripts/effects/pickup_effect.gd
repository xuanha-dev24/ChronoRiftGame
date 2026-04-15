# pickup_effect.gd
# Visual effect when player picks up an item
extends Node2D

@onready var particles: CPUParticles2D = $CPUParticles2D
@onready var timer: Timer = $Timer

func _ready() -> void:
	# Wait for parent to set our position before emitting particles
	await get_tree().process_frame
	
	print("[PickupEffect] After process_frame, global_position: ", global_position)
	
	# Set high z-index to render on top
	z_index = 100
	
	# Start particle emission
	if particles:
		# Force all settings in code to ensure they work
		particles.amount = 30
		particles.lifetime = 1.0
		particles.one_shot = true
		particles.explosiveness = 1.0
		particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
		particles.emission_sphere_radius = 20.0
		particles.direction = Vector2(0, -1)
		particles.spread = 45.0
		particles.gravity = Vector2(0, 200)
		particles.initial_velocity_min = 80.0
		particles.initial_velocity_max = 150.0
		particles.scale_amount_min = 1.0
		particles.scale_amount_max = 2.0
		particles.color = Color(1.0, 1.0, 0.0, 1.0)  # Yellow
		
		# Ensure particles are at local origin (not offset from parent)
		particles.position = Vector2.ZERO
		
		particles.emitting = true
		print("[PickupEffect] Particles emitting at effect global_position: ", global_position)
	
	# Connect timer to cleanup
	if timer:
		timer.wait_time = 2.0
		timer.timeout.connect(_on_timer_timeout)
		timer.start()

func _on_timer_timeout() -> void:
	queue_free()

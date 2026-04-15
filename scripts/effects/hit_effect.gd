# hit_effect.gd
# Creates hit particle effect
extends Node2D

@onready var particles: CPUParticles2D = $CPUParticles2D

func _ready() -> void:
	particles.emitting = true
	# Auto-delete after particles finish
	await get_tree().create_timer(particles.lifetime + 0.5).timeout
	queue_free()

extends Area2D

## Turret Projectile - Fired by turrets to damage enemies
## Moves toward target position at constant speed, despawns after max distance or on hit

# Properties
var velocity: Vector2 = Vector2.ZERO
var damage: int = 15
var max_distance: float = 200.0
var distance_traveled: float = 0.0
var target_position: Vector2 = Vector2.ZERO
var start_position: Vector2 = Vector2.ZERO

const PROJECTILE_SPEED: float = 200.0

## Initialize projectile with start position, target position, and damage
func initialize(start_pos: Vector2, target_pos: Vector2, dmg: int) -> void:
	global_position = start_pos
	start_position = start_pos
	target_position = target_pos
	damage = dmg
	
	# Calculate velocity toward target
	var direction = (target_pos - start_pos).normalized()
	velocity = direction * PROJECTILE_SPEED

func _process(delta: float) -> void:
	# Move projectile
	var movement = velocity * delta
	global_position += movement
	distance_traveled += movement.length()
	
	# Check if max distance reached
	if distance_traveled >= max_distance:
		queue_free()

## Handle collision with enemies (Area2D)
func _on_area_entered(area: Area2D) -> void:
	# Check if it's an enemy
	if area.is_in_group("enemies"):
		# Deal damage
		if area.has_method("take_damage"):
			area.take_damage(damage)
		
		# Destroy projectile
		queue_free()

## Handle collision with enemies (CharacterBody2D or other body types)
func _on_body_entered(body: Node2D) -> void:
	# Check if it's an enemy
	if body.is_in_group("enemies"):
		# Deal damage
		if body.has_method("take_damage"):
			body.take_damage(damage)
		
		# Destroy projectile
		queue_free()

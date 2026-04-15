# slime_basic_poc.gd
# POC enemy — stands still, takes damage, dies
class_name SlimeBasicPOC
extends CharacterBody2D

@export var max_hp: int = 30

var current_hp: int
var base_speed: float = 60.0
var current_speed: float = 60.0

@onready var hp_label: Label = $HPLabel
@onready var sprite: ColorRect = $Sprite

func _ready() -> void:
	current_hp = max_hp
	add_to_group("enemies")
	_update_hp_display()

func take_damage(amount: int) -> void:
	current_hp -= amount
	_update_hp_display()
	
	# Flash red for feedback
	sprite.color = Color.RED
	await get_tree().create_timer(0.1).timeout
	sprite.color = Color(0.2, 0.8, 0.2)  # green
	
	if current_hp <= 0:
		_die()

func _die() -> void:
	# Spawn chrono dust (placeholder print)
	print("Slime died — dropped 5 chrono dust")
	EventBus.enemy_killed.emit("slime_basic", global_position)
	queue_free()

func _update_hp_display() -> void:
	hp_label.text = "%d / %d" % [current_hp, max_hp]

func apply_slow(factor: float) -> void:
	current_speed = base_speed * factor
	sprite.color = Color(1.0, 0.0, 1.0)  # magenta/pink when slowed - very visible!

func remove_slow() -> void:
	current_speed = base_speed
	sprite.color = Color(0.2, 0.8, 0.2)  # back to green

# test_mana_consumption.gd
# Temporary test script to verify mana consumption
extends Node

var player_stats: Node

func _ready():
	# Wait for player to be ready
	await get_tree().create_timer(1.0).timeout
	
	# Find player stats
	player_stats = get_tree().get_first_node_in_group("player")
	if player_stats and player_stats.has_node("PlayerStats"):
		player_stats = player_stats.get_node("PlayerStats")
	else:
		push_error("[Test] PlayerStats not found!")
		return
	
	print("[Test] Mana consumption test started")
	print("[Test] Press SPACE to consume 20 mana")

func _input(event):
	if event.is_action_pressed("attack") and player_stats:
		# Consume 20 mana on attack
		if player_stats.use_mana(20):
			print("[Test] Consumed 20 mana. Current: %d/%d" % [player_stats.current_mana, player_stats.max_mana])
		else:
			print("[Test] Not enough mana!")

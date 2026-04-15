# farming_system.gd
# Manages farming mechanics: planting, growing, harvesting
extends Node

signal crop_planted(crop_id: String, position: Vector2)
signal crop_harvested(crop_id: String, position: Vector2)

# Placeholder for farming system
# TODO: Implement crop growth, seasons, soil quality

# element_system.gd
# Manages elemental system and weakness calculations
extends Node

enum Element {
	EARTH,
	WATER,
	FIRE,
	LIGHT,
	DARK,
	WIND,
	NONE
}

# Weakness chart: Element -> What it's weak against
var weakness_chart: Dictionary = {
	Element.EARTH: Element.WATER,
	Element.WATER: Element.FIRE,
	Element.FIRE: Element.LIGHT,
	Element.LIGHT: Element.DARK,
	Element.DARK: Element.EARTH,
	Element.WIND: Element.NONE  # Wind is amplifier, no weakness
}

# Strength chart: Element -> What it's strong against
var strength_chart: Dictionary = {
	Element.EARTH: Element.DARK,
	Element.WATER: Element.EARTH,
	Element.FIRE: Element.WATER,
	Element.LIGHT: Element.FIRE,
	Element.DARK: Element.LIGHT,
	Element.WIND: Element.NONE
}

@export var weakness_multiplier: float = 1.5
@export var resistance_multiplier: float = 0.5
@export var wind_amplifier: float = 1.3

func calculate_damage(base_damage: int, attacker_element: Element, defender_element: Element) -> int:
	var final_damage: float = base_damage
	
	# Check if attacker element is strong against defender
	if strength_chart.get(attacker_element) == defender_element:
		final_damage *= weakness_multiplier
		print("Super effective! ", attacker_element, " vs ", defender_element)
	
	# Check if attacker element is weak against defender
	elif weakness_chart.get(attacker_element) == defender_element:
		final_damage *= resistance_multiplier
		print("Not very effective... ", attacker_element, " vs ", defender_element)
	
	return int(final_damage)

func apply_wind_amplifier(damage: int) -> int:
	return int(damage * wind_amplifier)

func get_element_color(element: Element) -> Color:
	match element:
		Element.EARTH:
			return Color(0.6, 0.4, 0.2)  # Brown
		Element.WATER:
			return Color(0.2, 0.5, 1.0)  # Blue
		Element.FIRE:
			return Color(1.0, 0.3, 0.1)  # Red-Orange
		Element.LIGHT:
			return Color(1.0, 1.0, 0.7)  # Yellow-White
		Element.DARK:
			return Color(0.3, 0.1, 0.4)  # Purple
		Element.WIND:
			return Color(0.7, 1.0, 0.8)  # Light Green
		_:
			return Color.WHITE

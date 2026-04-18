extends GutTest

const DECOR_ROCK_SCENE := "res://scenes/world/harvestable_objects/DecorRock.tscn"
const MAPPING_FILES := [
	"res://data/tileset_mappings/tiny_swords_map.json",
	"res://data/tileset_mappings/tiny_swords_color1_map.json",
	"res://data/tileset_mappings/tiny_swords_color2_map.json",
	"res://data/tileset_mappings/tiny_swords_color3_map.json",
	"res://data/tileset_mappings/tiny_swords_color4_map.json",
	"res://data/tileset_mappings/tiny_swords_color5_map.json"
]

func test_decor_rock_scene_exists() -> void:
	assert_true(ResourceLoader.exists(DECOR_ROCK_SCENE), "Decor rock harvestable scene should exist")

func test_all_tileset_mappings_use_harvestable_decor_rock() -> void:
	for mapping_path in MAPPING_FILES:
		var json_text: String = FileAccess.get_file_as_string(mapping_path)
		var parsed: Variant = JSON.parse_string(json_text)
		assert_true(parsed is Dictionary, "%s should parse as JSON object" % mapping_path)
		if not (parsed is Dictionary):
			continue

		var mapping_data: Dictionary = parsed
		var objects: Dictionary = mapping_data.get("objects", {})
		assert_true(objects.has("decor_rock"), "%s should contain decor_rock mapping" % mapping_path)
		if not objects.has("decor_rock"):
			continue

		var decor_rock: Dictionary = objects["decor_rock"]
		assert_eq(
			decor_rock.get("scene", ""),
			DECOR_ROCK_SCENE,
			"%s should point decor_rock to the harvestable scene" % mapping_path
		)
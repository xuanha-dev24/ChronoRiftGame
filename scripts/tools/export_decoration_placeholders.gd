extends SceneTree

class_name DecorationPlaceholderExporter

const EXPORT_SPECS := [
	{
		"source": "res://assets/third_party/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/Terrain/Decorations/Bushes/Bushe1.png",
		"output_dir": "res://assets/placeholder/decorations/bushes",
		"basename": "bushe1",
		"frame_width": 128,
		"frame_height": 128
	},
	{
		"source": "res://assets/third_party/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/Terrain/Decorations/Rocks in the Water/Water Rocks_01.png",
		"output_dir": "res://assets/placeholder/decorations/rocks_in_water",
		"basename": "water_rocks_01",
		"frame_width": 64,
		"frame_height": 64
	}
]

func _initialize() -> void:
	var exported_count: int = export_placeholders()
	print("Decoration placeholder export finished: %d frames" % exported_count)
	quit(0)

func export_placeholders() -> int:
	var total_exported: int = 0
	for spec_variant in EXPORT_SPECS:
		var spec: Dictionary = spec_variant
		total_exported += _export_sheet(spec)
	return total_exported

func _export_sheet(spec: Dictionary) -> int:
	var source: String = str(spec.get("source", ""))
	var output_dir: String = str(spec.get("output_dir", ""))
	var basename: String = str(spec.get("basename", "sprite"))
	var frame_width: int = int(spec.get("frame_width", 0))
	var frame_height: int = int(spec.get("frame_height", 0))

	if source == "" or output_dir == "" or frame_width <= 0 or frame_height <= 0:
		push_error("Invalid export spec: %s" % spec)
		return 0
	if not FileAccess.file_exists(source):
		push_error("Decoration sprite sheet not found: %s" % source)
		return 0

	var texture: Texture2D = load(source) as Texture2D
	if texture == null:
		push_error("Failed to load decoration sprite sheet: %s" % source)
		return 0

	var image: Image = texture.get_image()
	if image == null:
		push_error("Failed to read image from sprite sheet: %s" % source)
		return 0

	var output_fs: String = ProjectSettings.globalize_path(output_dir)
	DirAccess.make_dir_recursive_absolute(output_fs)

	var columns: int = int(image.get_width() / frame_width)
	var rows: int = int(image.get_height() / frame_height)
	var exported: int = 0
	for row in range(rows):
		for col in range(columns):
			var frame: Image = Image.create(frame_width, frame_height, false, image.get_format())
			frame.blit_rect(image, Rect2i(col * frame_width, row * frame_height, frame_width, frame_height), Vector2i.ZERO)
			var output_path: String = "%s/%s_%d.png" % [output_fs, basename, exported]
			var save_error: int = frame.save_png(output_path)
			if save_error != OK:
				push_error("Failed to save placeholder frame: %s" % output_path)
				continue
			exported += 1

	print("Exported %d frames from %s" % [exported, source])
	return exported
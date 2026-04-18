extends SceneTree

class_name TilesheetSlicer

@export var tilesheet_path: String = "res://assets/third_party/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/Terrain/Tileset/Tilemap_color1.png"
@export var tile_size: int = 32
@export var out_dir: String = "res://assets/placeholder/tiles/tiny_swords"
@export var mapping_json: String = "res://data/tileset_mappings/tiny_swords_map.json"
@export var update_mapping: bool = true

func _initialize() -> void:
    # When run with `-s` this script is the main loop, so use MainLoop lifecycle.
    var ok: bool = slice_tilesheet(tilesheet_path, tile_size, out_dir, mapping_json, update_mapping)
    print("Tilesheet slicer finished: %s" % ok)
    quit(0 if ok else 1)

func slice_tilesheet(sheet_path: String, tile_size: int = 32, out_dir: String = "res://assets/placeholder/tiles/tiny_swords", mapping_json_path: String = "", update_mapping: bool = true) -> bool:
    if not FileAccess.file_exists(sheet_path):
        push_error("Tilesheet not found: %s" % sheet_path)
        return false

    var tex = load(sheet_path)
    if tex == null:
        push_error("Failed to load texture: %s" % sheet_path)
        return false

    var img: Image = null
    if tex is Texture2D:
        img = tex.get_image()
    else:
        # try to load via Image
        img = Image.new()
        var err = img.load(sheet_path)
        if err != OK:
            push_error("Could not obtain Image from %s" % sheet_path)
            return false

    if img == null:
        push_error("Could not get Image from texture: %s" % sheet_path)
        return false

    var out_fs := ProjectSettings.globalize_path(out_dir)
    DirAccess.make_dir_recursive_absolute(out_fs)
    var cols := int(img.get_width() / tile_size)
    var rows := int(img.get_height() / tile_size)
    var count := 0
    for ry in range(rows):
        for rx in range(cols):
            var sub := Image.create(tile_size, tile_size, false, img.get_format())
            sub.blit_rect(img, Rect2i(rx * tile_size, ry * tile_size, tile_size, tile_size), Vector2i.ZERO)
            var save_path := out_fs + "/%d_%d.png" % [ry, rx]
            var save_err := sub.save_png(save_path)
            if save_err != OK:
                push_error("Failed saving tile: %s" % save_path)
            count += 1
    print("Sliced %d tiles into %s" % [count, out_dir])

    if update_mapping and mapping_json_path != "":
        _update_mapping_after_slice(mapping_json_path, sheet_path, out_dir)

    return true

func _update_mapping_after_slice(mapping_json_path: String, sheet_path: String, out_dir: String) -> void:
    var mapping_fs := ProjectSettings.globalize_path(mapping_json_path)
    if not FileAccess.file_exists(mapping_fs):
        print("Mapping JSON not found: %s" % mapping_json_path)
        return

    var text: String = FileAccess.get_file_as_string(mapping_fs)
    var parsed: Variant = JSON.parse_string(text)
    if not (parsed is Dictionary):
        print("Failed to parse mapping JSON: %s" % mapping_json_path)
        return

    var map: Dictionary = parsed
    var changed: bool = false
    var mappings: Dictionary = map.get("mappings", {}) as Dictionary
    if mappings == null:
        mappings = {}
    for key in mappings.keys():
        var info: Dictionary = mappings[key] as Dictionary
        if info == null:
            continue
        var sheet: String = info.get("sheet", "") as String
        var region: Array = info.get("region", null) as Array
        if sheet == sheet_path and region != null and region is Array and region.size() >= 2:
            var rx: int = int(region[0])
            var ry: int = int(region[1])
            var new_path: String = out_dir + "/%d_%d.png" % [ry, rx]
            info["sheet"] = new_path
            info["region"] = [0, 0]
            mappings[key] = info
            changed = true

    if changed:
        map["mappings"] = mappings
        var out_text := JSON.stringify(map, "\t")
        var f := FileAccess.open(mapping_fs, FileAccess.ModeFlags.WRITE)
        if f == null:
            print("Failed opening mapping json for write: %s" % mapping_json_path)
            return
        f.store_string(out_text)
        f.close()
        print("Updated mapping JSON to point to sliced tiles.")

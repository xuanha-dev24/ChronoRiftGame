# tileset_generator.gd
# Generates placeholder isometric tiles programmatically
extends Node

# Tile colors - more vibrant
const GRASS_COLOR = Color(0.3, 0.8, 0.3)
const GRASS_DARK = Color(0.2, 0.6, 0.2)
const DIRT_COLOR = Color(0.7, 0.5, 0.3)
const DIRT_DARK = Color(0.5, 0.3, 0.2)
const STONE_COLOR = Color(0.6, 0.6, 0.6)
const STONE_DARK = Color(0.4, 0.4, 0.4)
const WATER_COLOR = Color(0.3, 0.6, 0.9)
const WATER_DARK = Color(0.2, 0.4, 0.7)

# Isometric tile dimensions
const TILE_WIDTH = 64
const TILE_HEIGHT = 32

static func create_tileset() -> TileSet:
	var tileset = TileSet.new()
	
	# Set tile shape to isometric
	tileset.tile_shape = TileSet.TILE_SHAPE_ISOMETRIC
	tileset.tile_size = Vector2i(TILE_WIDTH, TILE_HEIGHT)
	
	# Create tiles with shading
	_add_tile(tileset, 0, GRASS_COLOR, GRASS_DARK, "Grass")
	_add_tile(tileset, 1, DIRT_COLOR, DIRT_DARK, "Dirt")
	_add_tile(tileset, 2, STONE_COLOR, STONE_DARK, "Stone")
	_add_tile(tileset, 3, WATER_COLOR, WATER_DARK, "Water")
	
	return tileset

static func _add_tile(tileset: TileSet, id: int, color: Color, dark_color: Color, tile_name: String) -> void:
	# Create isometric diamond with shading
	var image = Image.create(TILE_WIDTH, TILE_HEIGHT, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	
	# Draw isometric diamond with gradient
	for y in range(TILE_HEIGHT):
		for x in range(TILE_WIDTH):
			if _is_in_diamond(x, y, TILE_WIDTH, TILE_HEIGHT):
				# Calculate shading based on position
				var shade = _get_shade(x, y, TILE_WIDTH, TILE_HEIGHT)
				var pixel_color = color.lerp(dark_color, shade)
				image.set_pixel(x, y, pixel_color)
	
	var texture = ImageTexture.create_from_image(image)
	
	# Add to tileset
	var source_id = tileset.get_next_source_id()
	var atlas_source = TileSetAtlasSource.new()
	atlas_source.texture = texture
	atlas_source.texture_region_size = Vector2i(TILE_WIDTH, TILE_HEIGHT)
	
	# Create tile at (0, 0)
	atlas_source.create_tile(Vector2i(0, 0))
	
	tileset.add_source(atlas_source, source_id)

static func _is_in_diamond(x: int, y: int, width: int, height: int) -> bool:
	var center_x = width / 2.0
	var center_y = height / 2.0
	
	var dx = abs(x - center_x) / center_x
	var dy = abs(y - center_y) / center_y
	
	return (dx + dy) <= 1.0

static func _get_shade(x: int, y: int, width: int, height: int) -> float:
	# Create shading effect (darker on bottom-right)
	var center_x = width / 2.0
	var center_y = height / 2.0
	
	var dx = (x - center_x) / center_x
	var dy = (y - center_y) / center_y
	
	# Shade based on position
	return clamp((dx + dy) * 0.3, 0.0, 0.5)

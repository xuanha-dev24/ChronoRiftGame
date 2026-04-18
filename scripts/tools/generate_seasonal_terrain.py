from __future__ import annotations

import copy
import json
from pathlib import Path

from PIL import Image


TILE_SIZE = 32
DEFAULT_SEASON = "color2"
SEASONS = ["color1", "color2", "color3", "color4", "color5"]
REPO_ROOT = Path(__file__).resolve().parents[2]
SOURCE_DIR = REPO_ROOT / "assets" / "third_party" / "Tiny Swords (Free Pack)" / "Tiny Swords (Free Pack)" / "Terrain" / "Tileset"
OUTPUT_BASE_DIR = REPO_ROOT / "assets" / "placeholder" / "tiles" / "tiny_swords"
MAPPING_DIR = REPO_ROOT / "data" / "tileset_mappings"
BASE_MAPPING_PATH = MAPPING_DIR / "tiny_swords_map.json"
WATER_BACKGROUND_PATH = "res://assets/third_party/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/Terrain/Tileset/Water Background color.png"
LAND_TILE_FILES = {
	"grass": "2_2.png",
	"sand": "3_2.png",
	"rock": "9_1.png",
}


def _slice_sheet(source_path: Path, output_dir: Path) -> tuple[int, int]:
	if not source_path.exists():
		raise FileNotFoundError(f"Missing seasonal atlas: {source_path}")

	output_dir.mkdir(parents=True, exist_ok=True)
	for stale_tile in output_dir.glob("*.png"):
		stale_tile.unlink()

	with Image.open(source_path) as image:
		atlas = image.convert("RGBA")
		if atlas.width % TILE_SIZE or atlas.height % TILE_SIZE:
			raise ValueError(
				f"Atlas size {atlas.width}x{atlas.height} is not divisible by tile size {TILE_SIZE}: {source_path}"
			)

		rows = atlas.height // TILE_SIZE
		cols = atlas.width // TILE_SIZE
		for row in range(rows):
			for col in range(cols):
				tile = atlas.crop((col * TILE_SIZE, row * TILE_SIZE, (col + 1) * TILE_SIZE, (row + 1) * TILE_SIZE))
				tile.save(output_dir / f"{row}_{col}.png")

		return rows, cols


def _build_season_mapping(base_mapping: dict, season: str) -> dict:
	mapping = copy.deepcopy(base_mapping)
	mapping["mappings"] = {
		"grass": {
			"region": [0, 0],
			"sheet": f"res://assets/placeholder/tiles/tiny_swords/{season}/{LAND_TILE_FILES['grass']}",
		},
		"sand": {
			"region": [0, 0],
			"sheet": f"res://assets/placeholder/tiles/tiny_swords/{season}/{LAND_TILE_FILES['sand']}",
		},
		"rock": {
			"region": [0, 0],
			"sheet": f"res://assets/placeholder/tiles/tiny_swords/{season}/{LAND_TILE_FILES['rock']}",
		},
		"water": {
			"region": [0, 0],
			"sheet": WATER_BACKGROUND_PATH,
		},
	}
	return mapping


def _write_json(path: Path, payload: dict) -> None:
	path.parent.mkdir(parents=True, exist_ok=True)
	path.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")


def generate_seasonal_tiles() -> None:
	base_mapping = json.loads(BASE_MAPPING_PATH.read_text(encoding="utf-8"))
	manifest = {
		"default": DEFAULT_SEASON,
		"tile_size": TILE_SIZE,
		"mappings": {},
	}

	for season in SEASONS:
		source_path = SOURCE_DIR / f"Tilemap_{season}.png"
		output_dir = OUTPUT_BASE_DIR / season
		rows, cols = _slice_sheet(source_path, output_dir)

		mapping = _build_season_mapping(base_mapping, season)
		mapping_path = MAPPING_DIR / f"tiny_swords_{season}_map.json"
		_write_json(mapping_path, mapping)
		manifest["mappings"][season] = f"res://data/tileset_mappings/{mapping_path.name}"
		print(f"Generated {season}: {rows * cols} tiles -> {output_dir}")

	default_mapping = _build_season_mapping(base_mapping, DEFAULT_SEASON)
	_write_json(BASE_MAPPING_PATH, default_mapping)
	_write_json(MAPPING_DIR / "tiny_swords_season_manifest.json", manifest)
	print(f"Updated default mapping to {DEFAULT_SEASON}")


if __name__ == "__main__":
	generate_seasonal_tiles()
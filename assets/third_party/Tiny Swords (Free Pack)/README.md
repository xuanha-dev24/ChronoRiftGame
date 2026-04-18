Tiny Swords (Free Pack)
------------------------

This folder contains the Tiny Swords free asset pack pasted into the project.

Quick notes:

- Source / author: Please confirm the original author and license. If this is a Kenney asset, it is typically public domain (CC0), but verify and add the LICENSE file when confirmed.
- Tile size: `metadata.json` currently sets `tile_size` to 32 as a reasonable default — open the tilesheets to confirm and edit the metadata if needed.
- Cleanup: there are macOS helper files (`__MACOSX`, `.DS_Store`) in the pack; they are ignored by the provided `.gitignore` but you can remove them locally before committing.
- Usage: to use tiles in Godot, create a `TileSet` resource, add the tilesheet as an Atlas/Single tile source and configure region size to match `tile_size`.

Recommended next steps:

1. Verify license/author and add `LICENSE` or `ATTRIBUTION.md` in this folder.
2. Confirm `tile_size` by inspecting `Tilemap_color*.png` in an image editor and update `metadata.json` if necessary.
3. Create a Godot `TileSet` and configure autotiles/bitmasks for transitions.
4. Use `data/tileset_mappings/tiny_swords_map.json` to map logical tile names (grass, water, sand, rock) to sheet regions; edit regions to match tile indices.

Seasonal terrain workflow:

1. Run `scripts/tools/generate_seasonal_terrain.py` to slice `Tilemap_color1.png` through `Tilemap_color5.png` into per-season tile folders.
2. The generator writes seasonal mapping files to `data/tileset_mappings/tiny_swords_color*_map.json`.
3. `data/tileset_mappings/tiny_swords_map.json` is kept as the active default mapping and currently points at the generated `color2` tiles.

If you want, I can create a `TileSet` resource and configure autotiles for the main tilesheet — this requires confirming `tile_size`.

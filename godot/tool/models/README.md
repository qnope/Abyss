# tool/models

The Godot side of the model workshop (`tool/models/` at the repo root builds
the glb files): editor and review tools, not game code, left out of exports.

- `model_import.gd`: the import script of every scene (`project.godot`,
  `[importer_defaults]`): vertex colours as albedo, a model's atlas sampled
  anisotropically; `model_surfaces.gd` holds what it does, so that a test can
  run it. An atlas (`<model>_atlas.png` beside its glb) is a texture of the
  project: its `.png.import` asks for VRAM compression and mipmaps.
- `preview.gd`, `studio.gd`, `model_bounds.gd`: the renders of
  `tool/models/preview.sh`; `ModelTiers` (presentation/world/models) shows a
  building up to a tier (`TIER=n`: its nodes `Tier1`..`Tier3` add up) for them.
- `portrait.gd`, `portrait_camera.gd` (with `studio.gd` in its clear mode): the
  renders of `tool/models/portraits.sh` into `assets/portraits/`, 256 px
  square, transparent, from one fixed 3/4 camera that fits the model's box.
- `board.gd`, `board_row.gd`: the review board of `tool/models/board.sh`, one
  row of renders, portrait and budget figures a model; a building with tiers
  has two lines, its game views and its close views at tier 1, tiers 1+2 and
  all tiers.
- `poses.gd`: the renders of `tool/models/poses.sh`: three poses of each action
  of a creature (the animation player seeked) and how it reads at phone size
  (the game's camera on a 10 m ground, cut round the figure). `model_facing.gd`
  turns a creature (a model with a `Rig`) to the camera for every render, and
  `model_bounds.gd` boxes it as turned. `board_row.gd` lays them out under a
  creature's views.
- `cells.gd`, `cell_row.gd`, `board_cells.gd`: the renders of `tool/models/cells.sh`,
  models side by side on the cells of a map with the game's floor, light and camera
  (`MapTiles`, `UnderwaterEnvironment`, `KeyLight`, `MapCamera`), a name tinted
  (`@rrggbb`, the node `Tint`) or dimmed (`!`) as the game does; `board.sh` shows them
  at the head of a board with `CELLS=`.
- `grid_view.gd` (with `grid_floor.gd`, `grid_layout.gd`, `grid_cover.gd`,
  `grid_backdrop.gd`, `grid_instances.gd`): the renders of `tool/models/grid.sh`,
  a level's floor tiles on a grid of cells in the game's map camera, light and
  water, seen or under the fog. `board_row.gd` adds their line to the board.

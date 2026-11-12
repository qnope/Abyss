# tool/models

The Godot side of the model workshop (`tool/models/` at the repo root builds
the glb files): editor and review tools, not game code, left out of exports.

- `model_import.gd`: the import script of every scene (`project.godot`,
  `[importer_defaults]`): vertex colours as albedo, a model's atlas sampled
  anisotropically; `model_surfaces.gd` holds what it does, so that a test can
  run it. An atlas (`<model>_atlas.png` beside its glb) is a texture of the
  project: its `.png.import` asks for VRAM compression and mipmaps.
- `preview.gd`, `studio.gd`, `model_bounds.gd`: the renders of
  `tool/models/preview.sh`; `model_tiers.gd` shows a building up to a tier
  (`TIER=n`: its nodes `Tier1`..`Tier3` add up) for them.
- `portrait.gd`, `portrait_camera.gd` (with `studio.gd` in its clear mode): the
  renders of `tool/models/portraits.sh` into `assets/portraits/`, 256 px
  square, transparent, from one fixed 3/4 camera that fits the model's box.
- `board.gd`, `board_row.gd`: the review board of `tool/models/board.sh`, one
  row of renders, portrait and budget figures a model; a building with tiers
  has two lines, its game views and its close views at tier 1, tiers 1+2 and
  all tiers.

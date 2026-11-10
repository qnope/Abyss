# tool/models

The Godot side of the model workshop (`tool/models/` at the repo root builds
the glb files): editor and review tools, not game code, left out of exports.

- `model_import.gd`: the import script of every scene (`project.godot`,
  `[importer_defaults]`): vertex colours as albedo, a model's atlas sampled
  anisotropically; `model_surfaces.gd` holds what it does, so that a test can
  run it. An atlas (`<model>_atlas.png` beside its glb) is a texture of the
  project: its `.png.import` asks for VRAM compression and mipmaps.
- `preview.gd`, `studio.gd`, `model_bounds.gd`: the renders of
  `tool/models/preview.sh`.

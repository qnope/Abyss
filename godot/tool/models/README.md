# tool/models

The Godot side of the model workshop (`tool/models/` at the repo root builds
the glb files): editor and review tools, not game code, left out of exports.

- `model_import.gd`: the import script of every scene (`project.godot`,
  `[importer_defaults]`); `model_surfaces.gd` holds what it does, so that a
  test can run it.
- `preview.gd`, `studio.gd`, `model_bounds.gd`: the renders of
  `tool/models/preview.sh`.

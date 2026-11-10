# tool/models

The model workshop: every 3D model of the game is a Python script over
Blender's module (`bpy`), exported as a glb into `godot/assets/models/`. A glb
is never edited by hand: change its script and build it again.

    tool/models/build.py [name ...]           # all models without a name
    tool/models/preview.sh <name> [prefix]    # renders to /tmp/models_preview/
    cd tool/models && python -m unittest discover -s . -p '*_test.py'

Both Python commands need Python 3.13 with `pip install bpy==5.2.3` (the CI job
`models` runs the tests so). The exporter logs that Draco and MeshOptimizer are
missing from the wheel: harmless, neither is used.

## Layout

- `workshop/`: the library. `Model` gathers the geometry; `shapes` and `sweep`
  make it (bevelled boxes and prisms, cylinders, spheres, tubes, ribbons,
  lathes); `noise` and `scatter` vary it from a seed; `occlusion` bakes the
  ambient occlusion; `export` writes the glb; `glb` and `budget` read and check
  it with the stdlib only.
- `catalog/`: one script per model, listed in `catalog/__init__.py`, and
  `palette.py`, the materials they share. A script declares its `NAME`, `SEED`,
  `MATERIALS`, `BUDGET`, `OCCLUSION`, the `NODES` the game relies on, and
  `build(model)`.

## Conventions

- One unit is one cell of the base. Blender is Z up; the glTF export turns it
  Y up: Blender (x, y, z) becomes (x, z, -y) in Godot.
- `model.add(group, geometry, material, paint)` adds static geometry: the build
  joins it per material into one mesh `<Group>_<material>` under the node
  `<Group>`, so a group costs one draw call per material.
- `model.piece(path, location)` is a node of its own (a pad the game shows,
  hides or tints), its origin at `location`, all its materials in one mesh.
- Deterministic: everything random comes from `model.rng`, seeded by the
  script's `SEED`, or from `noise` with a fixed seed. The tests build each model
  twice and compare the geometry, and compare it with the committed glb.

## Materials

Mobile and WebGL 2 first, so no texture and no Blender procedural texture: a
material is glTF factors only (roughness, metallic, emission), and the albedo is
in the **vertex colours**, painted per corner by the script (`paint`) and then
multiplied by an **ambient occlusion baked per corner** (`Occlusion`: rays cast
against the whole model, favouring the sky). One material therefore serves
every rock or every coral, whatever its colour, which keeps the draw calls few.
The palette's materials are in `catalog/palette.py`.

Godot's glTF importer ignores vertex colours (`COLOR_0`) for the albedo, so
`godot/project.godot` gives every scene the import script
`godot/tool/models/model_import.gd`, which turns them on.

A model whose detail cannot live in vertex colours may bake a small atlas PNG
(512 or 1024 px) next to its glb; its budget then declares the texture size.
None does yet: the budgets say `texture_px=0`.

## Budgets

Each script's `BUDGET` caps its triangles (every mesh counted once per node
that draws it), materials and texture size. `build.py` refuses to write a model
over it, and so do the tests.

## Preview

`preview.sh` imports the project, then renders the model as the game imports
it in a neutral studio (a key light with shadows, a cool fill, a dark blue
background, a ground disc): `<prefix>_game.png` from the game's default 3/4
camera at the phone's portrait size, and `_front`, `_right`, `_back`, `_left`
from the four sides, all at 2x. It runs Godot's Compatibility renderer (the
web's) under `xvfb-run`. The renders go to `/tmp/models_preview/` by default:
never into the repo.

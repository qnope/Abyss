# tool/models

The model workshop: every 3D model of the game is a Python script over
Blender's module (`bpy`), exported as a glb into `godot/assets/models/`. A glb
is never edited by hand: change its script and build it again.

    tool/models/build.py [name ...]           # all models without a name
    tool/models/preview.sh <name> [prefix]    # renders to /tmp/models_preview/
    tool/models/preview.sh base_island+base_rampart   # several models together
    cd tool/models && python -m unittest discover -s . -p '*_test.py'

Both Python commands need Python 3.13 with `pip install bpy==5.2.3` (the CI job
`models` runs the tests so). The exporter logs that Draco and MeshOptimizer are
missing from the wheel: harmless, neither is used.

## Layout

- `workshop/`: the library. `Model` gathers the geometry; `shapes` and `sweep`
  make it (bevelled boxes and prisms, cylinders, spheres, tubes, ribbons,
  lathes); `noise` and `scatter` vary it from a seed; `occlusion` bakes the
  ambient occlusion; `atlas`, `canvas` and `uv` paint a texture atlas and map
  faces into it; `export` writes the glb, `glb_atlas` links its atlas; `glb`
  and `budget` read and check it with the stdlib only, `png` writes and reads
  the atlas.
- `catalog/`: one script (or package) per model, listed in
  `catalog/__init__.py`, and what they share: `palette.py` (materials),
  `colors.py`, `paints.py`, `textures/` (the tiles the atlases are painted
  from, `textures/colony.py` the buildings' atlas) and `parts/` (hatches,
  pipes, rails, fittings, props and reef clusters, mapped into an atlas). A script declares its `NAME`, `SEED`,
  `MATERIALS`, `BUDGET`, `OCCLUSION`, the `NODES` the game relies on, and
  `build(model)`; a textured one also its `ATLAS`.

## Conventions

- One unit is one cell of the base. Blender is Z up; the glTF export turns it
  Y up: Blender (x, y, z) becomes (x, z, -y) in Godot.
- `model.add(group, geometry, material, paint)` adds static geometry: the build
  joins it per material into one mesh `<Group>_<material>` under the node
  `<Group>`, so a group costs one draw call per material.
- `model.piece(path, location)` is a node of its own (a pad the game shows,
  hides or tints), its origin at `location`, all its materials in one mesh.
- Hard or soft edges: a geometry's `sharp_angle` is the angle between two
  smooth faces past which their edge is drawn hard: low for machined plates,
  higher for rocks, 95 degrees for living things (tubes, ribbons, spheres).
- Open bottoms: `prism`, `box` and `cylinder` take `bottom=False` for what
  stands on something, so no face is spent where nobody looks.
- Deterministic: everything random comes from `model.rng`, seeded by the
  script's `SEED`, or from `noise` with a fixed seed. The tests build each model
  twice and compare the geometry, and compare it with the committed glb within
  a tolerance (`workshop/glb_compare.py`): another machine computes the last
  bits of a float otherwise, which can also flip an occlusion ray on a few corners.

## Materials

Mobile and WebGL 2 first, so no Blender procedural texture and at most one
small texture a model (its atlas, below): a material is glTF factors
(roughness, metallic, emission), and the albedo is in the **vertex colours**, painted per corner by the script (`paint`) and then
multiplied by an **ambient occlusion baked per corner** (`Occlusion`: rays cast
against the whole model, favouring the sky; its `strength` per material keeps
coral and algae bright and leaves the glowing materials untouched). One material therefore serves
every rock or every coral, whatever its colour, which keeps the draw calls few.
The palette's materials are in `catalog/palette.py`.

Godot's glTF importer ignores vertex colours (`COLOR_0`) for the albedo, so
`godot/project.godot` gives every scene the import script
`godot/tool/models/model_import.gd`, which turns them on.

## Atlas

Vertex colours cannot carry fine detail on a low-poly face: panel lines,
rivets, grime, pores, lit panes. A model whose detail needs it declares an
`ATLAS` (`workshop/atlas.py`): a square PNG of 512 or 1024 px cut into a grid,
each `Tile` painted by a script with numpy on a `Canvas` (seeded noise that
can wrap around the tile, soft boxes and discs), with a gutter of repeated
edge pixels so that the mipmaps do not bleed. The build writes it as
`<name>_atlas.png` beside the glb, byte for byte the same from one build to
the next, and its budget declares its size (`texture_px`).

A tile is mostly near white: the glTF multiplies it by the vertex colours, so
it adds detail to a face and keeps its colour (a lit pane or a solar cell
carries its own). Faces are mapped into it by `model.add(..., uv=...)`:

- `atlas.fit(tile)`: each flat side stretched over the tile, upright (a plate,
  a door); the faces of one plane, as a side cut in a grid, share it.
- `atlas.tiled(tile, period)`: a seamless tile repeated every `period` units
  in world space, projected on the plane a face faces most: grime, pores.
- `atlas.planar(tile, right, up)`: the whole geometry seen along a plane (a
  porthole's pane, a badge).
- `atlas.solid(tile)`: one colour of the atlas; a face added without a
  mapping takes the white tile `plain`.

A part may map itself before it is turned into place, and pass the UVs it got.
Only the materials marked `textured` (`palette.py`) take the atlas; a glowing
one takes it as its emission too, so one lamp material gives every light of a
model its colour, from the tile it maps. Blender exports the UVs and no image:
`glb_atlas` then names the PNG in the glb (an image by `uri`, sampled with
mipmaps and clamped), so the game imports it as a texture of its own,
compressed for the GPU: its `.png.import` (committed) asks for `VRAM
Compressed` with mipmaps, and the import script samples it anisotropically.
A model with an atlas and a big flat side cuts it in a grid
(`geometry.subdivide`), so that its baked occlusion has corners to darken.

## Budgets

Each script's `BUDGET` caps its triangles (every mesh counted once per node
that draws it), materials and texture size. `build.py` refuses to write a model
over it, and so do the tests. A textured model costs one texture of its own:
1024 px in VRAM-compressed form is about 1.3 MB with its mipmaps.

## Preview

`preview.sh` imports the project, then renders the model as the game imports
it in a neutral studio (a key light with shadows, a cool fill, a dark blue
background, a ground disc): `<prefix>_game.png` from the game's default 3/4
camera at the phone's portrait size, and `_front`, `_right`, `_back`, `_left`
from the four sides, all at 2x, and `_close`, the game's view zoomed on the
front quarter, to judge the detail. It runs Godot's Compatibility renderer (the
web's) under `xvfb-run`. Models shown together with `base_island` stand on
its pad of the same name (`model_pads.gd`), as in the game. The renders go to `/tmp/models_preview/` by default:
never into the repo.

## The base

- `base_island`: the plateau of the base, 12 x 12 cells, its deck's top at the
  origin. Its plan (`catalog/base_island/layout.py`) copies the slots of
  `lib/presentation/widgets/base/base_layout.dart`, which its test checks: each
  slot is an empty pad, the node `Pads/<Building>` (`Pads/CoralMine`), its
  origin where the building stands, at (u - 6, 0.12, v - 6) in Godot.
- `base_rampart`: the coral wall around the deck, in the band the island keeps
  flat and free of decor for it, open where the walkways leave. It grows with
  the coral citadel as **3 tiers that add up**, the nodes `Tier1` (the low
  wall), `Tier2` (a second course, coral in the crenels, lit gate posts) and
  `Tier3` (merlons, crowned bastions, lanterns): the game shows the tiers up to
  the citadel's level. Pieces that stack rather than one wall scaled, so that
  stones, towers and coral keep their size at every level, and each tier stays
  joined per material.

The buildings stand at the origin of their pad, 1 unit a cell, their moving
parts as nodes the game can animate:

- `headquarters`: the command keep, the tallest piece. An octagonal hull of
  riveted plates on a plinth, four airlocks, a railed gallery, a drum of cyan
  bridge windows under a glass cupola, a mast with an amber yard; nodes
  `Beacon` and `Dish`. Cyan crown, amber living quarters.
- `solar_panel`: a heliostat. A low housing (gauges, capacitors, cables) and on
  its turntable the node `Array`, two wings of glass cells tilted to the light,
  algae hanging from them. Gold is its light.
- `coral_citadel`: a fortress grown rather than built: walls of living stone
  with thorns, four cupped towers, a keep crowned by a polyp calyx holding the
  node `Heart`, a pink crystal. Pink is its light.

Each has its own 1024 px atlas painted from `textures/colony.py`; the rampart
has a 512 px one, its seamless reef stone.

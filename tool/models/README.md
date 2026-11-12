# tool/models

The model workshop: every 3D model of the game is a Python script over
Blender's module (`bpy`), exported as a glb into `godot/assets/models/`. A glb
is never edited by hand: change its script and build it again.

    tool/models/build.py [name ...]           # all models without a name
    tool/models/preview.sh <name> [prefix] [tier]   # renders to /tmp/models_preview/
    tool/models/preview.sh base_island+base_rampart   # several models together
    tool/models/portraits.sh [name ...]       # the interface's pictures, committed
    tool/models/preview.sh headquarters@2     # a building up to its tier 2
    tool/models/board.sh a,b,c /tmp/lot.png   # the review board of a lot
    tool/models/poses.sh scout [prefix]       # three poses of each action, and the phone view
    tool/models/board.sh a,b /tmp/lot.png --tiers   # ... with each building's tiers
    tool/models/cells.sh a,b,c /tmp/cells     # models side by side on the map's cells (see The map)
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
Compressed` with mipmaps, and the import script samples it anisotropically. A new model's first import writes
the file with the defaults: set `compress/mode=2` and `mipmaps/generate=true` in it, import again.
A model with an atlas and a big flat side cuts it in a grid
(`geometry.subdivide`), so that its baked occlusion has corners to darken.

## Tiers

A building rises with its level (`BuildingTier`: tier 1 = levels 1-3, tier 2 = levels
4-7, tier 3 = level 8 and up), so its model holds three additive groups under its
root node: `<Root>/Tier1` (the base of the building, always shown), `<Root>/Tier2` (what
rising adds) and `<Root>/Tier3` (the crown). The game shows Tier1, then Tier1 + Tier2, then
all three; the budget counts the three together, so the lower tiers cost less. A moving
part the game already finds at a fixed path stays a child of the root, shown at every
tier (`Headquarters/Beacon`, `Headquarters/Dish`, `CoralCitadel/Heart`, and the hull
`Headquarters/Headquarters_hull`); the tiers add the rest. A script fills
`Into(model, f"{GROUP}/Tier{k}")`; `catalog/parts/command.py` has a `Collector` to build
a tier in its own frame and `lay` it turned toward the game's camera (`FACING`, 45
degrees). `preview.sh <name>@<tier>` renders a building up to that tier, framed as with
all three, and `board.sh ... --tiers` shows each building's game view at the three tiers
and the triangles of each tier added to the ones below.

## Budgets

Each script's `BUDGET` caps its triangles (every mesh counted once per node
that draws it), materials, texture size and, for a creature, bones and
keyframes. `build.py` refuses to write a model over it, and so do the tests. A
textured model costs one texture of its own: 1024 px in VRAM-compressed form is
about 1.3 MB with its mipmaps.

A script also declares its `FAMILY`, and its `BUDGET` must stay within the caps
of the family, `catalog/families.py` (checked by `families_test.py`):

| Family | Triangles | Materials | Texture | Bones | Keyframes |
| --- | --- | --- | --- | --- | --- |
| building | 20 000 | 5 | 1024 px | - | - |
| unit | 3 000 | 3 | 256 px | 24 | 3 000 |
| monster | 8 000 | 4 | 512 px | 40 | 6 000 |
| map (what stands on a cell) | 6 000 | 4 | 512 px | - | - |
| decor (island, rampart, terrain, backdrops) | 80 000 | 10 | 512 px | - | - |

Mobile and WebGL 2 first. The building row is the prototype's largest model
(the headquarters: 18 462 triangles, 5 materials, one 1024 px atlas), which ran
smooth on an iPhone, and the decor row is the island's (77 623 triangles, drawn
once). The others are first guesses, to be tightened by the bench of each lot:

- *unit*: the parade ground draws several figures of six types at once, so a
  figure is a sixth of a building (a few thousand triangles, three materials,
  a small atlas) with a skeleton of at most 24 bones (a mobile skinning limit
  that keeps the palette small). Keyframes are the times of every sampler of the
  four actions: 24 bones with their three channels over about 70 frames is
  already a few thousand, and an unmoving channel still costs two.
- *monster*: a few on screen, but the Kraken and the Leviathan are single big
  figures: a larger mesh, a 512 px atlas, up to 40 bones.
- *map*: dozens of contents are drawn at once on a level, so each is under a
  building's third (6 000), with few materials (one draw call each) and no
  animation (the living creatures of the map are monsters).

## Measure

A lot is measured before its integration, on two tools. `tool/scene_capture.sh`
(`godot/tool/scene/README.md`) renders the prototype and the base in the
Compatibility renderer under `xvfb-run` and prints each view's draw calls and
primitives: its frame rate means nothing in software, the counts do. Compare them
with the lot's models in `WorldModels` against the counts before it; a model
that adds more draw calls or primitives than its budget says is over. On a
device, open the web build with `?bench=1` (`?bench=40` for 40 s) in the
address, or run `-- --bench` natively: a fixed orbit of the prototype with the
frame counter (`godot/app/README.md`). A regression of the frame time, the draw
calls or the primitives against the previous lot blocks the lot.

## How a model lot goes

1. **Script**: one catalog script per model (its `FAMILY`, `BUDGET`, `NODES`,
   `PORTRAIT = True` for a type the interface shows; a rig for a creature),
   registered in `catalog/__init__.py`, with its tests first.
2. **Build**: `tool/models/build.py <names>` writes the glb (and atlas) into
   `godot/assets/models/`, refusing a model over its budget; commit them with
   their `.import` (a new atlas's `.png.import` is first imported uncompressed:
   set `compress/mode=2` and `mipmaps/generate=true` in it, as the other atlases
   have, and import again: `models_test.gd` checks it).
3. **Preview**: `tool/models/preview.sh <name>` to judge it while working.
4. **Board**: `tool/models/board.sh a,b,c /tmp/lot.png` composes the review board
   of the lot, each model's views, portrait and figures: the owner validates the
   lot from this one image. A creature (a model with actions) shows its game and
   side views, its portrait, how it reads at phone size and two lines of poses
   (`poses.sh`: three of each of idle, swim, attack, hit); its renders are turned
   to the camera (`ModelFacing`), since it is built facing Godot's forward, -Z. A building with tiers (`Tier1`..`Tier3`) shows its
   game and close views at tier 1, tiers 1+2 and all tiers, and the cost of each
   (`workshop/tiers.py`). Never commit it.
5. **Owner validates** the board; nothing enters the game before.
6. **Integrate** through `WorldModels` (`MODELS`, `UNIT_MODELS`...; a creature's
   `ModelAnimator` plays its actions), the interface and `app/` untouched.
7. **Portraits**: `tool/models/portraits.sh` renders the models' pictures; the
   interface picks them up by the type's name, no code.
8. **Bench**: measure as above before the pull request.

## Rigs and animations

A unit or a monster moves, so its script declares a skeleton, in
`workshop/rig.py`, with no Blender needed to read it:

    rig = model.rig
    rig.bone("Body", None, head=(0, -0.35, 0.5), tail=(0, 0.45, 0.5))
    tail = rig.chain("Tail", "Body", [(0, -0.35, 0.5), (0, -0.65, 0.5), ...])  # Tail1..
    rig.action("swim", 24, {"Tail1": [Key(0), Key(6, (0, 0, 22)), ...]}, loop=True)

A bone has a parent declared before it. A `Key(frame, rotation, location)`
poses a bone at a frame: rotation in degrees and location offset, **about the
model's own axes** at rest (Blender's, Z up) and on top of the parent's pose,
so a tail bone bends from the one before it. Actions play at `rig.fps` (24):
`idle` and `swim` loop (a loop must end where it starts, checked at
declaration), `attack` and `hit` play once. The units and monsters share these
four names; the game asks for them by name.

Geometry is skinned as it is added, `model.add(group, geometry, material,
paint, bone=...)`: a bone's name binds a rigid part to it alone, and
`skin.along(chain, rig.centres(chain))` blends a ribbon or a tail along a chain
of bones, from the weights of the vertex's place along it (`workshop/skin.py`).
Every part of a rigged model needs a bone. The meshes of a rigged model are the
children of the node `Rig` (the armature, `workshop/armature.py`), which is its
node to list in `NODES`; the group names only name the meshes.

The export writes each action as a glTF animation on an NLA track; a loop is
named `<action>_loop`, which Godot's importer reads as loop mode and drops
from the name (the game plays `swim`, not `swim_loop`). The budget gains
`bones` (the joints of the skin) and `keyframes` (the times of every sampler:
a channel that does not move still costs its two). In Godot,
`ModelAnimator` (`presentation/world/models/`) plays them by name.
`catalog/probe_fish` (a body and a three-bone tail with the four actions) is the
workshop's proof, tested in Python and played in a GDScript test; the game does
not show it.

## Preview

`preview.sh` imports the project, then renders the model as the game imports
it in a neutral studio (a key light with shadows, a cool fill, a dark blue
background, a ground disc): `<prefix>_game.png` from the game's default 3/4
camera at the phone's portrait size, and `_front`, `_right`, `_back`, `_left`
from the four sides, all at 2x, and `_close`, the game's view zoomed on the
front quarter, to judge the detail (a creature, which does not stand on the
plateau, is turned to the camera and framed whole, and has no `_close`). It runs Godot's Compatibility renderer (the
web's) under `xvfb-run`. Models shown together with `base_island` stand on
its pad of the same name (`model_pads.gd`), as in the game. The renders go to `/tmp/models_preview/` by default:
never into the repo. `TIER=n tool/models/preview.sh <name>` shows a building up to
its tier n (the nodes `Tier1`..`Tier3` add up, `ModelTiers` hides the
others) and renders only `_game` and `_close`.

## Tiers

A building the game shows at a level has three tiers that add up, in one glb:
the nodes `Tier1` (its base, always shown), `Tier2` (what rising adds) and
`Tier3` (its crown), listed in its `NODES` (a moving part is a piece under a
tier, `Tier3/Beacon`). The game shows `Tier1`, `Tier1 + Tier2`, then all three
(`BuildingTier.of_level`: levels 1-3, 4-7, 8 and up); the budget counts the three
together, so the lower tiers cost less. `preview.sh <name> <prefix> <1|2|3>` renders
the game and close views of a building up to that tier (`godot/tool/models/
model_tiers.gd` hides the others), and `board.sh` adds, for a model with a
`Tier1` node, a row of those views at each tier and the triangles and draw
calls of each stage (`workshop/tiers.py`). The occlusion is baked on the whole
model, so a lower tier alone is a little darker where a higher one would shade it.

## Portraits

The interface shows a building, a unit or a monster as a picture, rendered from
its model: `tool/models/portraits.sh [names]` writes
`godot/assets/portraits/<name>.png` (and its `.import`, committed like the
glb) for every model whose script declares `PORTRAIT = True`, or for the names
given. It is a fixed 3/4 camera (45 degrees round, 28 above, 30 of field,
`godot/tool/models/portrait_camera.gd` backs it off until the model's box just
fills the square), the studio's light, a transparent background, no ground, 256
px square: twice the largest portrait of the interface (128 points). The command
imports the project and draws under `xvfb-run` as `preview.sh` does, then asks
the import for mipmaps, which a portrait shown at half its size wants. A portrait
is never edited by hand and is regenerated whenever its model changes.

`Portrait` shows it when the file exists (`PortraitFiles`, in
`presentation/ui/common/`, names it after the lower-case enum value: a
building `headquarters`, `solar_panel`; a unit `scout`, `dome_breaker`; a monster
family `swarm`, `kraken`) and keeps the initials otherwise. So **a lot names
its model after its type (`scout`, `swarm`), declares `PORTRAIT = True`, runs
`portraits.sh`, and no code changes**: `portrait_files_test.gd` fails for a
portrait that no type is called.

The Models job of CI (`portraits_test.py`) checks that each declared portrait is
committed, a square PNG of the declared side with its `.import`, and that none is
committed for a model that declares none. It does not compare pixels: another
machine's renderer draws the last bits differently.

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
- `algae_farm`, `coral_mine`, `ore_extractor`, `solar_panel`: the production
  buildings, on a pad of two cells, each in **3 tiers that add up** (the nodes
  `Tier1`..`Tier3`, shown up to the building's tier) and with its own colour.
  The farm is a glasshouse of green panes, basins of kelp and a tank (Tier2: a
  ridge lantern, a second basin and the node `Drone`; Tier3: the bioreactor
  column). The mine is a headframe over a pink glowing shaft (the nodes
  `Wheel`, `CrownWheel`), with a crusher, bin and belt (Tier2) and an upper
  mast with a beacon (Tier3). The extractor is a blue tripod rig whose string
  is the node `Drill`, with a belt, hopper and cab (Tier2) and a silo (Tier3).
  The solar panel is a housing under its `Array` (the same at every tier), with
  battery cabinets (Tier2) and a gold collector tower (Tier3). Their parts
  (`parts/glasshouse.py`, `production.py`, `lattice.py`, `crystals.py`,
  `belts.py`) and textures (`textures/production.py`) are shared by the four.
- `coral_citadel`: a fortress grown rather than built: walls of living stone
  with thorns, four cupped towers, a keep crowned by a polyp calyx holding the
  node `Heart`, a pink crystal. Pink is its light.

- `descent_module`, `pressure_capsule`, `volcanic_kernel` (in tiers): the
  descent module, a gantry over a well of blue light with its pod on cables, in
  grey-green steel; the pressure capsule, a white and steel blue hull sphere
  with a cyan viewport, cradled by legs, then ribbed, then in gimbal rings,
  by two black chimneys; the base's volcanic kernel, a basalt mound with a
  molten core, then pillars caging a spire of lava, then a crown of obsidian
  prongs round a flame (nodes `Tier3/Beacon` for the first two, `Tier3/Flame`).
  Their tiles are `textures/deep.py` (lava and its fire, basalt, blue lights,
  painted plates, a hatch) in the colony atlas' free cells, their shared parts
  `parts/deep.py`.

Each has its own 1024 px atlas painted from `textures/colony.py`; the rampart
has a 512 px one, its seamless reef stone.

The command buildings (`textures/command.py` adds their tiles to the colony's atlas,
`parts/command.py` and `parts/command_tech.py` their parts) have three tiers each:

- `headquarters`: command post (hull, airlocks, gallery, a drum of cyan windows), headquarters
  (glass cupola, mast, tanks, generator, cargo), command tower (a lattice,
  sensor pods); the root's own hull, `Beacon` (on the gallery's deck) and `Dish` are always
  shown. By far the tallest.
- `laboratory`: field lab (a scrubbed ceramic hall, glowing specimen tanks), research wing
  (control room, bioreactor sphere), institute (a tower crowned by an atom, node `Tier3/Atom`).
  Teal is its light.
- `barracks`: bunker hall (banner, harpoon rack), garrison (gate tower, bunks), fortress (keep
  tower, harpoon launchers, red-lit portal, hedgehogs). Crimson cloth and red lights. It also
  stands at the back of the parade ground, on a round plot 2.3 wide (`ParadeBarracks`),
  at the deck's level: nothing of it may stand past that plot.
- `coral_citadel`: keep (polyp, calyx, the root's node `Heart`, low curtain, gate), stronghold
  (towers, merlons, thorns), crown of thorns (a cage of tentacles, spires, arches). It stays
  well inside `base_rampart`.

## The army

The six units, one figure of a squad each (family `unit`, 3 materials, one
256 px atlas, a skeleton of 14 to 16 bones, the four actions), standing on the
floor under their origin and facing +Y in Blender (Godot's -Z): `scout`,
`harpoonist`, `guardian`, `dome_breaker`, `abyss_admiral`, `saboteur`, named
after `UnitType` so that their portraits are found with no code. They share
`catalog/unit_kit/`: `body.py` (one diver's skeleton and a `Build` of
proportions each), `forms.py` and `looks.py` (shapes placed by points, and what a
part is made of: neoprene `suit`, `hull` metal, `lamp` lights, all from the one
atlas `textures/units.py`), `diver.py` (legs, arms, trunk, helmet) and
`actions.py`: a pose is a rotation (degrees, about the model's axes, at the bone's
head: positive X swings a hanging limb forward and a standing body back) and
a location; an action is poses at frames; idle, swim and hit are shared and
each unit has its own attack (`held` aims a tool, which turns with the arm
that carries it). Each unit's own parts are in `catalog/<name>/gear.py` and its
attack in `moves.py`. Their `catalog/units_test.py` checks the contract.

- `scout`: a small (0.8 m) blue diver with the biggest helmet, a wide cyan
  visor, an antenna with a red bulb, a thruster pack with swept fins, long
  flippers and a shock prod. Swims low and fast; attacks by lunging in.
- `harpoonist`: a red diver with a round brass helmet, three amber ports, twin tanks
  and a hose, and a harpoon taller than itself. Attacks by twisting and thrusting.
- `guardian`: a broad steel and white figure in a great helm with a cyan slit,
  a tower shield bearing the emblem and a maul. Attacks with a shield bash.
- `dome_breaker`: a hulking orange and charcoal diver, horned helmet, a spiked
  pauldron, hazard stripes and the breaching hammer. Attacks with an overhead smash.
- `abyss_admiral`: the tallest (1.45 m), a violet coat with tails on two bones,
  gold epaulettes and a bicorne, a violet visor, a gold baton. Attacks by giving the order.
- `saboteur`: a small mint-green hooded figure with red gas-mask lenses, a ragged
  cloak, a dagger and the limpet mine on its hip. Attacks by placing the mine.

## The map

One model per kind of content of the map (`MapContent.Kind`), family `map`,
named `map_<kind>`. Each stands on the floor under the centre of its cell, 1 unit
a cell (the volcano on the middle of its 2 x 2), its front toward -y; the node
`Body` holds everything static, joined per material (`catalog/mapkit/` is what
they share, `parts/bank.py`, `loot.py`, `fronds.py`, `lair.py`, `extrude.py`
their parts and `textures/map.py` their 512 px atlas, cut in 8 x 8 cells of 64 px,
of which each takes only the tiles it maps). The tintable ones also have the
node `Tint`: one lamp mesh in neutral white that the game recolours with a
`material_override` (the holder's colour).

| Model | What it is | Tint | Look |
|---|---|---|---|
| `map_treasure` | a chest, lid open on gold, on a bank of silt | - | gold, the smallest |
| `map_resource_algae` / `_coral` / `_ore` | a rosette of green blades, a pink and red coral, blue crystals in dark boulders | - | green, red-pink, blue |
| `map_ruins` | a drowned temple of pale stone, two columns and a lintel | - | cream, with a teal orb |
| `map_wreck` | a heeled hull of rusted plate, split open | - | rust orange |
| `map_lair_easy` / `_medium` / `_hard` | a mound with a toothed mouth, horns and bones, growing | - | salmon, red, dark crimson |
| `map_faille` | a violet portal in a field of black plates | ring, banner | violet |
| `map_cheminee` | three black smokers banded in sulphur, a plume of smoke | ring, banner | black and yellow, amber glow |
| `map_passage` | an opened way down, a steel collar with its lid thrown back | ring, banner | blue-grey, amber light |
| `map_kernel` | the volcano, 2 x 2 cells, 2 high: black cone, lava flows, molten kernel | seal | black and orange |
| `map_home` | the colony's dome (headquarters' language), cyan windows | - | pale, cyan |
| `map_faction_base` | a rival's walled outpost, four towers and a keep | ring, banner, pennants | dark steel, red gate |

The heights keep the legend: the volcano under `MapGrid.TALLEST` (2.0), then
the smokers, the hard lair over the medium one over the easy one, and the
treasure under all (`catalog/map_test.py`). To judge them side by side, as
the player's camera shows them:

    tool/models/cells.sh a,b,map_faille@69f0ae,map_wreck! /tmp/cells   # _near.png and _far.png
    CELLS=a,b,c tool/models/board.sh a,b,c /tmp/lot.png       # the same, at the head of the board

`cells.sh` lays the models on cells with the map's floor, camera and light
(`godot/tool/models/cell_row.gd`); `@rrggbb` tints a node `Tint` as the game
does and `!` dims the model as an emptied content is. Contents are drawn dozens
at a time, so each is held to under 4 800 triangles.

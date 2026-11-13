# presentation/world

The 3D world: the base's island and its buildings, the map, the units and the
battles, with their cameras, lights and effects.

Depends on `domain/` to read the state it shows. Never on `data/`, `app/` or
`presentation/ui/`.

## base/

The player's base (`BaseScene`): the island with its 11 pads, the rampart, the
buildings standing on the pads, lit from the surface and seen by the orbit
camera.

- `show_base(held, upgradable, locked)` draws a game's base: each building of
  `held` on its pad at its level (`PadState`), greyed and still when degraded
  (the headquarters is too low for it), the rampart at the tier of the Coral
  Citadel's level (`BuildingTier.rampart_of`: none at level 0, three tiers
  over its five levels), and the signs (`PadMarks`): the level over every
  building, an arrow over one that can rise, a warning over a degraded one, a
  plus over a plot that can be built on, a padlock over a plot a prerequisite
  holds back. `upgradable` and `locked` are sets
  (`Dictionary[BuildingType.Value, bool]`); `app/` fills them from the rules
  (`GameUpgradeReadiness`). The same base again changes nothing.
- `building_tapped(type)` is told for a tap on any pad, built or not (a plot
  is built by tapping it), through `BasePads.pick`; each pad is picked up to
  the top of the building on it, an empty one a little above its deck.
- `build(names)` stands the prototype's and the menus' base: those pads at
  level 1, the rampart at its first tier if the citadel is among them.
- `buildings.use_models = false` shows every building as its stand-in, to
  review the shapes (`tool/scene_capture.sh`).
- `PadHalos` glows behind each building that can rise (and works well: a degraded
  one is warned of, not glowed), beside the arrow of `PadMark`: a soft additive disc
  facing the camera at the building's mid height, sized by the building's height or
  its pad's width, all of them sharing one quad and one material that a single tween
  breathes (`CYCLE` 3 s, `reduced_motion` holds it at its brightest). The same
  `ParticleDot.dot` gradient as the specks; no extra model, one draw per building.
- `IsletLife` (`base.life`) is the base's own life over the snow and the bubbles:
  more bubbles (`RisingBubbles.new(30)`) round the buildings that carry a lamp
  (`LAMPS`: the headquarters, the citadel, the descent module, the capsule, the
  kernel; none for a degraded one), the map's turtle swimming round the island (a
  `CreatureLap`, the one `MapAmbient` is made of) and a `FishSchool` drifting round
  it (14 small ellipsoids in one `MultiMesh`, moved by the processor). It stops and
  hides with the quality panel's particles (`set_particles`).
- A building under construction is not drawn: the rules have none. An upgrade is
  immediate (`UpgradeBuildingAction` raises the level at once and `Worksite` only
  counts the upgrades of the turn), so no state says that a pad is a site.

## ambience/

The water around the scenes: `UnderwaterEnvironment` (the sky gradient that lights
the water, the fog, the glow), `KeyLight` (the one directional light and its
shadows), the light shafts, the marine snow and the bubbles, the fish and the
turtle. The light is a `LightMood` (the key light's colour and energy, the
sky's three colours, the ambient strength, the fog), the palette of
`LightMoods`: the base's (the one the base was reviewed in), and one for each
level of the map: the surface a bright teal under a clear key light, the
depths a twilight blue under a colder one, the core a dark red and orange.
`UnderwaterEnvironment.set_mood` and `KeyLight.set_mood` wear a mood at once (a
level is a cut, not a fade): `MapScene.show_level` lights its own key light and
tells `level_shown(level)`, and `WorldHost` (`app/world/`) lights the water,
which the base owns, with the mood of the level on the map view, the base's on
the others.

`LevelSpecks` are the specks of a level of the map, a `SpeckLook` of the palette
`SpeckLooks`: marine snow falling on the surface (140), bubbles rising from the
floor in the depths (70), warm ash and embers drifting up in the core (110).
Cheap on purpose, as the base's snow and bubbles: one `CPUParticles3D` (one draw
call, no particle shader to compile on the web), dots of `ParticleDot`, no
shadow, redrawn only when the level or its size changes. `MapSurroundings`
holds them with the backdrop and the creature of the level; `MapScene.set_particles`
(the quality panel's setting) stops and hides them, and a map out of sight is not
processed at all.

## guide/

The tutorial's halo in 3D: `GuideRing`, a pulsing cyan torus lying on the floor
(Flutter's `BaseSlotHalo` and `GuideCellHalo`), with the name of what it points
at floating over it. Each scene carries one: `BaseScene.guide` around the pad of
a building (`BasePads.radius_of` gives the pad's reach), `ParadeScene.guide`
around a squad's drill pad, `MapScene.guide` (a `MapGuide`) around a cell of a
level. `point_at(at, radius, name)` rings, `clear()` takes it away; the pulse
holds still with `reduced_motion`. `MapGuide.aim(level, x, y)` is told once and
follows the level the map shows (`shown_on`), so a level opened later finds its
cell ringed. This layer knows nothing of the guide's advice: `app/game/GuideController`
aims the rings. The ring's colour is `WorldPalette.GUIDE`, held equal to the
interface's cyan by a test in `app/`.

## parade/

The army's parade ground (`ParadeScene`), shown on the army tab as the base is
on the base tab: a deck (`ParadeGround`, with the army's crest in the middle),
the barracks at the back (`ParadeBarracks`) and one drill pad for each of the
six units (`Squad`), laid out by `ParadeLayout` (Flutter's `ArmyLayout`, in
metres). It has its own orbit camera and key light, and none of the base's
ambience: the water and the sky are the base's, which `WorldHost` leaves on.

- `show_army(squads, barracks)` draws an army: `squads` are `SquadState`s (the
  unit, how many serve, whether the barracks is too low for it, whether it can
  recruit, and the caption under its count, which `app/` writes in the language
  on: this layer writes no text), `barracks` the `PadState` the base uses (its
  level, degraded, can rise, a plot that can be built on, held back). A squad
  not given is hidden; the same army again changes nothing.
- A squad is its figures standing on its pad (`SquadSize`: one figure to 1
  unit, then 2, 3, 4, 5 and 6 at 2, 6, 16, 31 and 61 units, in the slots of
  `ParadeLayout.SLOTS`), the plaque over them (the count and the caption, in
  the unit's colour, faint while empty), and over that a green plus when it
  can recruit now, or a padlock, and one ghost in place of the figures, when
  the barracks is too low. The barracks wears its level, the arrow of a barracks
  that can rise, the warning of a degraded one, the plus of a plot to build.
- `squad_tapped(type)` and `barracks_tapped` are told for a tap, through
  `ParadePick` over the boxes of the squads (their pad, up to `Squad.REACH`)
  and of the barracks, as `BasePads.pick` does: a locked squad is tapped as the
  others.
- `frame(hud, foot)` fits the deck between the bars of the game screen, leaving
  `PLACE_BAR_ROOM` more at the bottom for the bar of the places.

## map/

The map of a level in 3D (`MapScene`), shown on the map tab as the base is on the
base tab, one level at a time: `show_level(state)` draws what `app/` reads from the
game (`MapLevelState`, built by `MapStates`), and `cell_tapped(level, x, y)` tells
a tap. The 2D painters, the projection, the slabs and the viewport of Flutter's
`GameMapView` are not ported: a 3D scene replaces them.

- `MapTiles` is one `MultiMesh` of a box per cell, coloured by `TerrainLook`
  (`WorldModels.terrain(terrain, revealed)`: the terrain's colour, a faint
  checker so the cells are told apart, and, for a cell not seen, the fog: dark
  and `FOG_DROP` lower). `MapLooks` is the port of Flutter's visuals builder:
  it reads the level once into a `MapLook` per cell (the whole volcano is seen as
  soon as one of its cells is, the wreck of the event is seen through the fog,
  a post is tinted by who holds it, a cell emptied is dimmed).
- `MapContents` stands what lies on the cells seen, one scene per content from
  `WorldModels.map_content(kind, tint, dimmed)` (the volcano, which covers 2x2
  cells, centred on them). `MapScouts` shows a `ScoutToken` for each scout on
  its way, sliding from the cell it left (`ScoutOrigin`) to its target, and
  swimming or hovering as Flutter's token does.
- `MapCamera` (a `MapRig`) looks down at a steep angle that never changes; a
  drag pans over the map (clamped to it), a pinch or the wheel zooms, and
  `fit_map` frames the whole level between the bars of the game screen (and
  `LEVEL_BAR_ROOM` more at the top for the level selector). A level not on show
  before is framed anew; the same level again keeps the view where the player left it.
- `MapPick` casts the tap's ray on the plane of the cells to the cell it
  falls in (`MapGrid.cell_at`). `MapPalette` holds every colour of the stand-ins.

Shadows are the costliest part of the map's frame (the shadow pass draws every caster
again, in two cascades: with none, a view of level 1 goes from 95 000 primitives and 249
draw calls to 48 000 and 149). The floor, the scenery and the clouds (`MapLayer`) cast
none: the tiles' relief is baked into their colours. What stands on the cells (`MapContents`)
casts its shadow only while the view is close (`MapCamera.zoomed(close)`, from `CLOSE` = 0.8 of
the default distance), when it can be seen; the key light's own shadow stays on, so that
nothing pops when the view comes close.

Taking a shadow costs as well. The Compatibility renderer (the web's) draws every lit
surface that receives shadows a second time, an additive pass over the first, and the
floor and the scenery (`MapTiles` and `MapBackdrop`, both `MapLayers`) fill most of the
screen: a fifth of the frame of a software render, and a phone too is bound by the
pixels it fills. So they
take shadows only while the view is close too (`receive_shadows`, told by the same
`zoomed`, and remembered for the levels drawn later): from far the contents cast none, and
the picture is the same but for the shadow of what still casts, the creature swimming by
and the scouts, which is no longer drawn there. Turning the key light's shadow off instead
would change the whole lighting. Nor does a material change its `disable_receive_shadows`:
a `BaseMaterial3D` frees a shader when its last user leaves it, so each crossing of
`CLOSE` would compile one again, a hitch on WebGL. A `MapLayer` swaps the mesh its
`MultiMesh` draws, the places kept, between the model's own and its `ShadowlessMesh`
(`models/`), so that both shaders stay alive. The murk of the fog takes no shadow by its
import: its layers are left as they are.

### map/effects/

What the map plays over a level (`lib/presentation/widgets/map/effects/`). `MapEffects`
(a part of `MapScene`) plays one `MapEffect` at a time: `play(effect, then)` ends the
one playing, calls `then` once the new one is over, and plays it over at once (never
staged) when the map is out of sight or `reduced_motion` is set; `finish()` ends the
one playing with its last moment shown, which is what the turn story uses to skip (`app/game/story/`).
An effect is told the time (`advance(seconds)`, so a test drives it), never reads a
clock, and leaves the map as it was drawn without it. `jolted(offset)` shakes the
`MapCamera` to the side (`MapJolt`). The seconds are `MapMotion`'s, the colours
`MapPalette`'s; both repeat the interface's and a test in `app/` holds them together.

- The fog. `MapFog` is the shroud over the cells not seen: `Cloud1..3` of `map_fog.glb`
  as three `MultiMesh`es (a cloud is 384 triangles, so every cell within `BAND` of a cell
  seen has one, the others every other cell), blended and shadowless. `FogLifts` tells the
  cells a level shows seen that it did not before; `FogLift` holds the clouds of those cells
  and the wisps along the fog still there, then lifts and fades the clouds as the wisps puff
  out and the contents show, a scout whose exploration is over (`ScoutToken.leave`) rising
  with them.
- A strike (`MapScene.strike(MapStrike, then)`): `StrikeEffect` over `StrikeTimeline`,
  `StrikeGeometry`, `StrikeCues` and `FightPace`, all pure. A `StrikeSquad` (the figures of
  `StrikeLead.figures`, the "×N" over them) swims to the cell beside the target
  (`StrikeGeometry.approach`), lunges at it once per round, and the `MonsterFigure` of the
  lair (`models/`: the model of its family scaled to a cell, the generic one when it has none)
  plays `hit` and strikes back; each blow flashes the target (`HitFlash`), shakes the camera
  and floats what each side lost (`FightLosses`). A monster beaten rolls over and shrinks into
  its foot, a place taken lights up in cyan, an army beaten falls back; the army shrinks
  away at the end.
- A siege (`MapScene.siege(MapSiege, then)`): `SiegeEffect` over `SiegeTimeline` and
  `SiegeGeometry`. A red ring (`FloorMark`) pulses twice round the place, three
  `SiegeAttackers` close in, clash once per round, then a cyan shield pushes them back or
  they break in under a red flash and a harder shake.

`WorldModels.map_content(kind, tint, dimmed)` is the seam for what stands on a
cell, as `building` and `unit` are: the `.glb` of `MAP_MODELS` (empty today: step 7
adds them there), a `MapStandIn` when it has none. The twelve kinds are told apart
by their solid and colour; a dimmed one (a cell already emptied) is the degraded grey:

| Content | Solid | Colour |
| --- | --- | --- |
| Treasure | small box | gold |
| Ruins | tapering drum | sand |
| Wreck | low prism | orange |
| Lair, easy | low prism (0.6 high) | light red |
| Lair, medium | prism (0.95 high) | red |
| Lair, hard | tall prism (1.3 high) | dark red |
| Faille (a post) | ring (a torus) | by holder: grey guardians, green the player, pink a rival |
| Cheminée (a post) | tapering drum | by holder |
| Passage | flat disc | by holder |
| Volcano | sphere over 2x2 cells, with a seal ring in the colour of whoever holds it | orange |
| Player's base | tapering drum | cyan |
| A rival's base | capsule | the faction's colour |

Terrain has one kind today (the plain): a blue-grey tile, the fog a darker one.
The wreck's glow and the terrain's variety are left to step 7.

## models/: the seam of step 7

`WorldModels.building(type, level, degraded)` is the one place that says what
a building looks like: the `.glb` of `assets/models/` when `MODELS` holds one
(the headquarters, the solar panel and the Coral Citadel today), a `StandIn`
when it does not. Its origin is the top centre of the building's pad. The base
asks nowhere else, so step 7 only adds models to `MODELS` (and their
animations in `BaseMotion`): the interface and `app/` never change.

`WorldModels.unit(type, ghost)` is the same for one figure of a squad, its
origin the floor under it: the `.glb` of `UNIT_MODELS` (empty today: step 7 adds
them there, and `ghost` veils a model in the degraded grey as `building` does),
a `UnitStandIn` when it has none. The six units are told apart by their solid
(`StandInShape.of_unit`) and their colour (`WorldPalette.unit`; the interface's
`UnitColors` repeats it and a test in `app/` holds the two together):

| Unit | Solid | Colour |
| --- | --- | --- |
| Scout | small sphere | blue |
| Harpoonist | tall slim prism (a spear tip) | red |
| Guardian | wide low box (a shield wall) | silver |
| Dome breaker | squat tapering drum | orange |
| Abyss admiral | tall capsule | lavender |
| Saboteur | flat ring (a torus) | green |

A locked unit's ghost is the same solid in the degraded grey, half there.

A `StandIn` is the building's `StandInShape` (one primitive solid: a box, a
cylinder, a prism, a capsule, a torus or a sphere, in proportions of its own)
in its `WorldPalette` colour, taller at each tier of levels
(`BuildingTier.of_level`: 1 to 3, 4 to 7, 8 and up) and in the degraded grey
(a model is veiled in it). The eleven are told apart by shape and colour:

| Building | Solid | Colour |
| --- | --- | --- |
| Headquarters | tall tapering cylinder | lavender |
| Algae farm | flat wide disc | green |
| Coral mine | pointed prism | rose |
| Coral citadel | tall square keep | peach |
| Ore extractor | squat tapering drum | blue |
| Solar panel | flat slab | yellow |
| Laboratory | fat capsule | teal |
| Barracks | wide low prism (a roof) | magenta |
| Descent module | flat ring (a torus) | silver |
| Pressure capsule | slim tall capsule | cyan |
| Volcanic kernel | sphere | orange |

`WorldPalette` is the world's: this layer never reads the interface's
`BuildingColors`, which repeats the buildings' colours (a test in `app/` holds
the two together). `ModelBounds.top_of` finds where a model or a stand-in ends,
so that the level and the signs clear it whatever it is. A degraded building
stays still: `BaseMotion` leaves its parts alone. Models are freed in the
tree, as `BaseBuildings` does: a node with its own materials freed outside it
makes the renderer complain.

`ShadowlessMesh.of(mesh)` is the twin of a model's mesh that takes no shadow: a copy
of the mesh (its surfaces and their levels of detail) drawn by copies of its materials
with `disable_receive_shadows`, one copy for all the meshes a material draws. The
model's mesh and materials are shared by every scene made of it and are never changed;
the twins are made once and kept, for the map to switch between the two without a
shader to compile (see `map/`).

`ModelAnimator.new(model)` plays the animations of a unit's or monster's model
by name: it finds the `AnimationPlayer` the glb's importer put in the scene,
stands the model in `idle`, `play(name, speed)` starts `swim`, `attack`, `hit`
or any action the script declared (a loop goes on, a one-shot ends by giving
back to `idle`) and says false for a name the model lacks. A model with no
animation, a building, is a model with nothing to play. The workshop's test
model `probe_fish` (a body, a tail of three bones, the four actions) proves it;
no scene shows it. `tool/models/README.md` says how a script declares a rig.

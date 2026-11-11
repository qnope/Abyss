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

## models/: the seam of step 7

`WorldModels.building(type, level, degraded)` is the one place that says what
a building looks like: the `.glb` of `assets/models/` when `MODELS` holds one
(the headquarters, the solar panel and the Coral Citadel today), a `StandIn`
when it does not. Its origin is the top centre of the building's pad. The base
asks nowhere else, so step 7 only adds models to `MODELS` (and their
animations in `BaseMotion`): the interface and `app/` never change.

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

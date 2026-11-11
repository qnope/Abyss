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

# Map Module

## Data Model

The map is the shared world every player inhabits. It is represented
by three core classes, all persisted with Hive:

- **`GameMap`** -- A 20x20 grid stored as a flat `List<MapCell>`. Holds
  the grid dimensions, the cell list, and the generation `seed`. It
  does **not** hold base coordinates -- each `Player` stores its own
  `baseX` / `baseY`. Provides `cellAt(x, y)` and `setCell(x, y, cell)`.
- **`MapCell`** -- A single cell containing a `TerrainType`, a
  `CellContentType`, an optional `MonsterLair lair`, an optional
  `collectedBy` string marking which player id looted the cell, and an
  optional `passageName` string referencing the transition base name
  from the level below. The computed getter `isCollected` returns
  `collectedBy != null`. Fog of war is **not** stored on the cell --
  it lives on `Player.revealedCellsList`, so every player has an
  independent view of the shared grid.
- **`GridPosition`** -- A value object pairing an `x` and `y` coordinate
  with equality and hash support.

### Monster lair

Monster cells are not described by a loose `MonsterDifficulty` enum
any more; they carry a structured **`MonsterLair`** (Hive typeId 17)
exposed as `MapCell.lair`:

- `difficulty: MonsterDifficulty` -- easy / medium / hard.
- `unitCount: int` -- how many monsters defend the lair.
- `level: int` (computed) -- `1` / `2` / `3` depending on difficulty,
  used by `MonsterUnitStats.forLevel` in the fight module to pick
  per-monster `{ hp, atk, def }`.

`ContentPlacer` fills in a `MonsterLair` whenever it places a
`monsterLair` cell; `MapCell.lair` is `null` for any other content
type. `FightMonsterAction` reads the lair, runs the fight, and on
victory stamps `collectedBy: player.id` on the cell (the lair stays
on the map for history, but `isCollected` prevents further fights).

## Terrain Types

| Value   | Description              |
|---------|--------------------------|
| `reef`  | Default terrain (~40%)   |
| `plain` | Walkable terrain (~30%)  |
| `rock`  | Impassable wall (~15%)   |
| `fault` | Special terrain (~15%)   |

## Cell Content Types

| Value           | Description                                                              |
|-----------------|--------------------------------------------------------------------------|
| `empty`         | Nothing special                                                          |
| `resourceBonus` | Treasure: collectable bundle of algae, coral and ore                     |
| `ruins`         | Collectable ruins yielding small amounts of coral, ore and pearl         |
| `monsterLair`   | Guarded by a monster (easy, medium, or hard)                             |
| `transitionBase`| Passage point guarded by a boss; connects two depth levels               |
| `passage`       | Reserved cell marking a transition base position from the level below    |

Monster difficulty scales with distance from the (first) player base:
cells farther than 7 tiles favor medium/hard monsters, while closer
cells favor easy/medium.

## Procedural Generation Pipeline

`MapGenerator.generate({int? seed, int level = 1, Map<GridPosition, String> reservedPassages = const {}})` returns a
`MapGenerationResult` bundling the `GameMap` with the chosen
`baseX` / `baseY`. The `level` parameter controls which transition
bases are placed (failles on level 1, cheminees on level 2, none on
level 3). The `reservedPassages` parameter marks positions that
correspond to transition bases on the parent level -- these cells
are excluded from content and transition base placement, then
stamped as `passage` cells with the parent base's name.

```
MapGenerator.generate(seed?, level, reservedPassages?)
    |
    v
pick baseX, baseY (center +/- 2)
    |
    v
compute reservedIndices from reservedPassages
    |
    v
TerrainGenerator.generate()     -- Fill 20x20 grid with terrain
    |                               Base cell forced to plain;
    |                               neighbors randomized (reef/plain);
    |                               remaining cells use weighted rolls.
    v
ContentPlacer.place(reservedIndices)
    |                            -- Place content on eligible cells
    |                               (distance > 2 from base, not rock,
    |                               not reserved). Rolls: 60% empty,
    |                               20% resource, 10% ruins, 10% monster
    |                               lair. Enforces 5-10 monsters total.
    v
TransitionBasePlacer.place(reservedIndices)
    |                            -- Place transition bases per level,
    |                               skipping reserved positions.
    |                               Level 1: 4 failles (one per quadrant,
    |                               outer edges, min 3 cells from base).
    |                               Level 2: 3 cheminees (spread across
    |                               grid with spacing constraints).
    |                               Level 3: none.
    v
Base cell cleared                -- Base cell content set to empty.
    |
    v
_markPassages()                  -- Stamp reserved positions as
    |                               CellContentType.passage with
    |                               passageName from parent base.
    v
MapGenerationResult { map, baseX, baseY }
```

## Transition Bases

Transition bases are guarded passage points connecting depth levels.
Each base is a `TransitionBase` (Hive typeId 32) stored on a `MapCell`.

### TransitionBaseType (Hive typeId 31)

| Type | Level | Target | Count | Guardians |
|------|-------|--------|-------|-----------|
| `faille` | 1 | Level 2 | 4 | 1 Leviathan (boss) + 5 Sentinelles |
| `cheminee` | 2 | Level 3 | 3 | 1 Titan Volcanique (boss) + 8 Golems |

### TransitionBase fields

| Field | Type | Description |
|-------|------|-------------|
| `type` | `TransitionBaseType` | faille or cheminee |
| `name` | `String` | Display name (e.g. "Faille Alpha") |
| `capturedBy` | `String?` | Player id or null |

Computed: `difficulty` (4 for faille, 5 for cheminee),
`targetLevel` (2 or 3).

### GuardianFactory

Static factory producing boss combatant lists per base type. Boss
combatants have `isBoss: true` on `Combatant`.

### ReinforcementOrder (Hive typeId 33)

Represents units in transit between levels through a captured base.

| Field | Type | Description |
|-------|------|-------------|
| `fromLevel` / `toLevel` | `int` | Source and destination levels |
| `units` | `Map<UnitType, int>` | Units being transferred |
| `departTurn` | `int` | Turn when sent |
| `arrivalPoint` | `GridPosition` | Where units arrive |

Resolves when `game.turn > departTurn` (1-turn transit).

## Fog of War (per-player)

Fog of war is a property of each `Player`, not of the map. Every
player carries its own `revealedCellsList: List<GridPosition>`. When a
new player is built via `Player.withBase`, the initial reveal window
is seeded via `RevealAreaCalculator` at Explorer level 2 (a 5x5
square) centered on the base. This is a deliberate choice so the
player can orient themselves in every direction from the very first
turn; it is independent of the explorer tech level the player actually
owns. Subsequent reveals come from exploration resolution.

## Collected State

`MapCell.collectedBy` records the id of the player that looted a
treasure or ruins cell. `isCollected` is a computed getter
(`collectedBy != null`). Once collected, the cell content icon stays
visible but is rendered greyed out, and `CollectTreasureAction`
refuses to collect it again. Reward generation lives in the action
itself, so the random rolls happen at collect time.

## Exploration

Players queue **scout** orders which are resolved at end of turn.

- **`ExplorationOrder`** -- Hive model (typeId 16) storing the target
  `GridPosition` and `level`. Queued orders live on
  `Player.pendingExplorations`. Pending exploration markers (cyan
  borders) are filtered by the currently viewed level so they only
  appear on the level where the exploration was ordered.
- **`CellEligibilityChecker`** -- Determines if a cell can be explored
  for a given player: revealed cells and unrevealed cells adjacent
  (Chebyshev distance 1) to a revealed cell are eligible. The player's
  own base cell is always excluded.
- **`RevealAreaCalculator`** -- Computes which cells are revealed based
  on Explorer tech level. **All sides are odd**, so the target cell is
  always exactly at the center of the revealed square. When the square
  overflows the grid, out-of-bounds cells are simply skipped (no
  shifting).

| Explorer Level | Square Side | Cells Revealed |
|----------------|-------------|----------------|
| 0              | 3           | 9              |
| 1              | 3           | 9              |
| 2              | 5           | 25             |
| 3              | 5           | 25             |
| 4              | 7           | 49             |
| 5              | 9           | 81             |

- **`ExplorationResolver.resolve(Game)`** -- iterates
  `game.players.values`, uses each player's Explorer level, reveals
  cells via `Player.addRevealedCell`, collects notable content from
  the shared map, then clears that player's pending list.
- **`ExplorationResult`** -- Non-persisted result object: target
  position, count of newly revealed cells, and list of notable
  `CellContentType` found.

## Files

| File                    | Role                              |
|-------------------------|-----------------------------------|
| `game_map.dart`         | Grid container (no base coords)   |
| `map_cell.dart`         | Single cell data                  |
| `grid_position.dart`    | (x, y) value object              |
| `terrain_type.dart`     | Terrain enum                      |
| `cell_content_type.dart`| Content enum                      |
| `monster_difficulty.dart`| Monster difficulty enum           |
| `monster_lair.dart`     | `MonsterLair` Hive type (difficulty + unitCount + level) |
| `map_generator.dart`    | Top-level generation orchestrator |
| `map_generation_result.dart` | `{ map, baseX, baseY }` result |
| `terrain_generator.dart`| Terrain assignment logic          |
| `content_placer.dart`   | Content placement logic           |
| `connectivity_checker.dart` | BFS reachability + path carving |
| `exploration_order.dart` | Pending exploration order (Hive) |
| `cell_eligibility_checker.dart` | Cell exploration eligibility |
| `reveal_area_calculator.dart` | Reveal area computation |
| `exploration_resolver.dart` | Per-player exploration resolution |
| `exploration_result.dart` | Per-exploration result data |
| `transition_base_type.dart` | `TransitionBaseType` enum (faille, cheminee) |
| `transition_base.dart` | `TransitionBase` Hive type |
| `transition_base_placer.dart` | Placement logic for transition bases |
| `guardian_factory.dart` | Boss combatant generation per base type |
| `reinforcement_order.dart` | `ReinforcementOrder` Hive type |

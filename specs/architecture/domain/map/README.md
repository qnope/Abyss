# Map Module

## Data Model

The map is the shared world every player inhabits. It is represented
by three core classes, all persisted with Hive:

- **`GameMap`** -- A 20x20 grid stored as a flat `List<MapCell>`. Holds
  the grid dimensions, the cell list, and the generation `seed`. It
  does **not** hold base coordinates -- each `Player` stores its own
  `baseX` / `baseY`. Provides `cellAt(x, y)` and `setCell(x, y, cell)`.
- **`MapCell`** -- A single cell containing a `TerrainType`, a
  `CellContentType`, an optional `MonsterDifficulty`, and an optional
  `collectedBy` string marking which player id looted the cell. The
  computed getter `isCollected` returns `collectedBy != null`. Fog of
  war is **not** stored on the cell -- it lives on
  `Player.revealedCellsList`, so every player has an independent view
  of the shared grid.
- **`GridPosition`** -- A value object pairing an `x` and `y` coordinate
  with equality and hash support.

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

Monster difficulty scales with distance from the (first) player base:
cells farther than 7 tiles favor medium/hard monsters, while closer
cells favor easy/medium.

## Procedural Generation Pipeline

`MapGenerator.generate({int? seed})` returns a `MapGenerationResult`
bundling the `GameMap` with the chosen `baseX` / `baseY`. The caller
(typically new-game setup) hands those coordinates to `Player.withBase`
so the player stores its own base location and initial fog-of-war.

```
MapGenerator.generate(seed?)
    |
    v
pick baseX, baseY (center +/- 2)
    |
    v
TerrainGenerator.generate()     -- Fill 20x20 grid with terrain
    |                               Base cell forced to plain;
    |                               neighbors randomized (reef/plain);
    |                               remaining cells use weighted rolls.
    v
ContentPlacer.place()            -- Place content on eligible cells
    |                               (distance > 2 from base, not rock).
    |                               Rolls: 60% empty, 20% resource,
    |                               10% ruins, 10% monster lair.
    |                               Enforces 5-10 monsters total.
    v
Base cell cleared                -- Base cell content set to empty.
    |
    v
MapGenerationResult { map, baseX, baseY }
```

## Fog of War (per-player)

Fog of war is a property of each `Player`, not of the map. Every
player carries its own `revealedCellsList: List<GridPosition>`. When a
new player is built via `Player.withBase`, the initial reveal window
is seeded via `RevealAreaCalculator` at Explorer level 0 centered on
the base. Subsequent reveals come from exploration resolution.

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
  `GridPosition`. Queued orders live on `Player.pendingExplorations`.
- **`CellEligibilityChecker`** -- Determines if a cell can be explored
  for a given player: revealed cells and unrevealed cells adjacent
  (Chebyshev distance 1) to a revealed cell are eligible. The player's
  own base cell is always excluded.
- **`RevealAreaCalculator`** -- Computes which cells are revealed based
  on Explorer tech level. Even-sized squares anchor the target at
  bottom-left; odd-sized squares center on the target.

| Explorer Level | Square Side | Cells Revealed |
|----------------|-------------|----------------|
| 0              | 2           | 4              |
| 1              | 3           | 9              |
| 2              | 4           | 16             |
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

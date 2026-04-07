# Map Module

## Data Model

The map is represented by three core classes, all persisted with Hive:

- **`GameMap`** -- A 20x20 grid stored as a flat `List<MapCell>`. Holds the grid dimensions, the player base coordinates (`playerBaseX`, `playerBaseY`), and the generation `seed`. Provides `cellAt(x, y)` and `setCell(x, y, cell)` for indexed access.
- **`MapCell`** -- A single cell containing a `TerrainType`, a `CellContentType`, an optional `MonsterDifficulty`, an `isRevealed` flag for fog of war, and an `isCollected` flag marking treasures and ruins already looted.
- **`GridPosition`** -- A value object pairing an `x` and `y` coordinate with equality and hash support.

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

Monster difficulty scales with distance from the player base: cells farther than 7 tiles favor medium/hard monsters, while closer cells favor easy/medium.

## Procedural Generation Pipeline

```
MapGenerator.generate(seed?)
    |
    v
TerrainGenerator.generate()     -- Fill 20x20 grid with terrain
    |                               Base cell forced to plain;
    |                               neighbors randomized (reef/plain);
    |                               remaining cells use weighted rolls.
    v
ConnectivityChecker              -- BFS from base; carve rock into plain
    |                               to guarantee a path to every grid edge.
    v
ContentPlacer.place()            -- Place content on eligible cells
    |                               (distance > 2 from base, not rock).
    |                               Rolls: 60% empty, 20% resource,
    |                               10% ruins, 10% monster lair.
    |                               Enforces 5-10 monsters total.
    v
Fog of war applied               -- Cells within radius 2 of the base
    |                               are revealed (isRevealed = true).
    v
Base cell cleared                -- Base cell content set to empty.
    |
    v
GameMap returned
```

## Fog of War

Every cell starts with `isRevealed = false`. During generation, cells within a Chebyshev distance of 2 from the player base are revealed. The `isRevealed` flag on `MapCell` controls whether the cell is visible to the player.

## Collected State

`MapCell.isCollected` marks treasures and ruins already looted. Once set, the cell content icon stays visible but is rendered greyed out, and the `CollectTreasureAction` refuses to collect it again. Reward generation lives in the action itself, not on the cell, so the underlying random rolls are decided at collect time.

## Exploration

Players can send **scouts** to explore map cells. Each exploration consumes 1 scout and queues an `ExplorationOrder` for turn resolution.

- **`ExplorationOrder`** -- Hive-persisted model (typeId 16) storing the target `GridPosition`. Queued orders live in `Game.pendingExplorations` until the next turn.
- **`CellEligibilityChecker`** -- Determines if a cell can be explored: revealed cells and unrevealed cells adjacent (Chebyshev distance 1) to a revealed cell are eligible. The base cell is always excluded.
- **`RevealAreaCalculator`** -- Computes which cells are revealed based on Explorer tech level. Even-sized squares anchor the target at bottom-left; odd-sized squares center on the target.

| Explorer Level | Square Side | Cells Revealed |
|----------------|-------------|----------------|
| 0              | 2           | 4              |
| 1              | 3           | 9              |
| 2              | 4           | 16             |
| 3              | 5           | 25             |
| 4              | 7           | 49             |
| 5              | 9           | 81             |

- **`ExplorationResolver`** -- Called during turn resolution. Iterates pending orders, reveals cells, collects notable content (ruins, monster lairs, resource bonuses), then clears the pending list.
- **`ExplorationResult`** -- Non-persisted result object returned per exploration: target position, count of newly revealed cells, and list of notable `CellContentType` found.

## Files

| File                    | Role                              |
|-------------------------|-----------------------------------|
| `game_map.dart`         | Grid container                    |
| `map_cell.dart`         | Single cell data                  |
| `grid_position.dart`    | (x, y) value object              |
| `terrain_type.dart`     | Terrain enum                      |
| `cell_content_type.dart`| Content enum                      |
| `monster_difficulty.dart`| Monster difficulty enum           |
| `map_generator.dart`    | Top-level generation orchestrator |
| `terrain_generator.dart`| Terrain assignment logic          |
| `content_placer.dart`   | Content placement logic           |
| `connectivity_checker.dart` | BFS reachability + path carving |
| `exploration_order.dart` | Pending exploration order (Hive) |
| `cell_eligibility_checker.dart` | Cell exploration eligibility |
| `reveal_area_calculator.dart` | Reveal area computation |
| `exploration_resolver.dart` | Turn-time exploration resolution |
| `exploration_result.dart` | Per-exploration result data |

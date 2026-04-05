# Map Module

## Data Model

The map is represented by three core classes, all persisted with Hive:

- **`GameMap`** -- A 20x20 grid stored as a flat `List<MapCell>`. Holds the grid dimensions, the player base coordinates (`playerBaseX`, `playerBaseY`), and the generation `seed`. Provides `cellAt(x, y)` and `setCell(x, y, cell)` for indexed access.
- **`MapCell`** -- A single cell containing a `TerrainType`, a `CellContentType`, an optional `MonsterDifficulty`, an optional bonus resource (`ResourceType` + amount), and an `isRevealed` flag for fog of war.
- **`GridPosition`** -- A value object pairing an `x` and `y` coordinate with equality and hash support.

## Terrain Types

| Value   | Description              |
|---------|--------------------------|
| `reef`  | Default terrain (~40%)   |
| `plain` | Walkable terrain (~30%)  |
| `rock`  | Impassable wall (~15%)   |
| `fault` | Special terrain (~15%)   |

## Cell Content Types

| Value           | Description                                        |
|-----------------|----------------------------------------------------|
| `empty`         | Nothing special                                    |
| `resourceBonus` | Grants a random `ResourceType` with 10-50 amount   |
| `ruins`         | Explorable ruins                                   |
| `monsterLair`   | Guarded by a monster (easy, medium, or hard)        |

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

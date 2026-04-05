# Map System — Architecture

## Overview

Procedurally generated 20x20 underwater map with fog of war, persisted via Hive. Displayed as a scrollable/zoomable grid in the GameScreen "Carte" tab.

## Domain Model

```
GameMap (typeId: 14)
├── width, height (20x20)
├── cells: List<MapCell> (flat array, index = y * width + x)
├── playerBaseX, playerBaseY
└── seed (for reproducibility)

MapCell (typeId: 13)
├── terrain: TerrainType (reef|plain|rock|fault)
├── content: CellContentType (empty|resourceBonus|ruins|monsterLair)
├── monsterDifficulty: MonsterDifficulty? (easy|medium|hard)
├── isRevealed: bool
├── bonusResourceType: ResourceType?
└── bonusAmount: int?
```

## Generation Pipeline

`MapGenerator.generate()` orchestrates three phases:

```
MapGenerator
├── 1. TerrainGenerator.generate()     → terrain layout
├── 2. ContentPlacer.place()           → resources, ruins, monsters
├── 3. _applyFogOfWar()               → reveal 5x5 around base
└── 4. _clearBaseContent()             → ensure base cell is empty
```

### Terrain rules
- Base placed near center (offset ±2), neighbors forced to reef/plain
- Distribution: reef 40%, plain 30%, rock 15%, fault 15%
- `ConnectivityChecker` ensures paths from base to all 4 edges (converts rock → plain)

### Content rules
- Excluded: base radius ≤2 and rock cells
- Distribution on eligible: empty 60%, resource 20%, ruins 10%, monster 10%
- Monster difficulty biased hard near edges (distance > 7 from base)
- Total monsters clamped to 5–10

### Fog of war
- Chebyshev radius 2 around base revealed (25 cells)
- Remaining 375 cells hidden

## Presentation

```
GameMapView (StatefulWidget)
├── InteractiveViewer (scroll + pinch-to-zoom)
│   └── 20x20 grid of MapCellWidget
│
MapCellWidget (StatelessWidget)
└── Stack: background → terrain SVG → content SVG → fog overlay
```

- Cell size: 48x48 logical pixels (grid = 960x960)
- Zoom: min = full map visible, max = ~4 cells visible, default = ~8 cells
- Initial view centered on player base
- Fog: 95% opacity black overlay on unrevealed cells

## Assets

```
assets/icons/
├── terrain/        reef.svg, plain.svg, rock.svg, fault.svg
└── map_content/    player_base.svg, resource_bonus.svg, ruins.svg,
                    monster_easy.svg, monster_medium.svg, monster_hard.svg
```

## Hive Integration

| Type | typeId |
|------|--------|
| TerrainType | 10 |
| CellContentType | 11 |
| MonsterDifficulty | 12 |
| MapCell | 13 |
| GameMap | 14 |
| GridPosition | 15 |

`Game.gameMap` (HiveField 8, nullable) — auto-generated on first access if null.

## File Structure

```
lib/domain/
├── terrain_type.dart, cell_content_type.dart, monster_difficulty.dart
├── map_cell.dart, game_map.dart, grid_position.dart
├── terrain_generator.dart, content_placer.dart, connectivity_checker.dart
└── map_generator.dart

lib/presentation/
├── widgets/game_map_view.dart, map_cell_widget.dart
└── extensions/terrain_type_extensions.dart, cell_content_type_extensions.dart
```

## Design Decisions

1. **Flat cell array** — `List<MapCell>` indexed by `y * width + x` for Hive-friendly serialization.
2. **Seed-based generation** — Deterministic output for reproducibility and debugging.
3. **Connectivity guarantee** — BFS ensures walkable paths to all map edges, preventing soft-locks.
4. **Stateless widgets** — `MapCellWidget` is pure; `GameMapView` only holds the `TransformationController`.
5. **No interaction yet** — This scope covers display only; cell selection and unit movement are deferred.

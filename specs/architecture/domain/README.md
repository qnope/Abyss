# Domain Layer

The domain layer (`lib/domain/`) contains all game logic as pure Dart code.
It has no dependency on Flutter, Hive APIs beyond annotations, or any UI concern.
Every rule -- resource production, building upgrades, turn resolution -- lives here.

## Submodules

The layer is split into eight submodules, each in its own subfolder.

| Submodule | Path | Role |
|-----------|------|------|
| [action](action/README.md) | `lib/domain/action/` | Defines the `Action` interface and `ActionExecutor`. Each player action (upgrade building, research tech, recruit unit, unlock branch) is a concrete `Action` that validates preconditions then mutates the `Game`. |
| [building](building/README.md) | `lib/domain/building/` | `Building` model (type + level), cost calculator, upgrade eligibility check, and the `BuildingDeactivator` used during turn resolution when energy is insufficient. |
| [game](game/README.md) | `lib/domain/game/` | `Game` -- the root aggregate that holds all game state (resources, buildings, units, tech branches, map, turn counter). `Player` stores the player profile. Both are Hive-serializable. |
| [map](map/README.md) | `lib/domain/map/` | `GameMap` grid, `MapCell`, terrain types, cell content (monsters, resources), procedural generation (`MapGenerator`, `TerrainGenerator`, `ContentPlacer`), and `ConnectivityChecker`. |
| [resource](resource/README.md) | `lib/domain/resource/` | `Resource` model (type, amount, max storage), `ProductionCalculator`, `ConsumptionCalculator`, `MaintenanceCalculator`, and production formulas. |
| [tech](tech/README.md) | `lib/domain/tech/` | Technology tree with three branches (military, resources, explorer). `TechBranchState` tracks unlock status and research level. Includes cost calculator and eligibility check. |
| [turn](turn/README.md) | `lib/domain/turn/` | `TurnResolver` executes the multi-step end-of-turn sequence (production, consumption, deactivation, unit losses). `TurnResult` packages the outcomes for the UI. |
| [unit](unit/README.md) | `lib/domain/unit/` | `Unit` model (type + count), stats definitions, cost calculator, and `UnitLossCalculator` for algae-shortage casualties. |

## Design principles

- **Pure Dart** -- no Flutter imports, no widget references.
- **Hive annotations** -- domain models carry `@HiveType` / `@HiveField` annotations so the data layer can persist them directly, but the domain never calls Hive APIs.
- **No `initialize()` methods** -- objects are fully constructed via their constructors.
- **Small files** -- each file targets fewer than 150 lines of code.

## Dependency flow

```
action --> game, building, resource, tech, unit
turn   --> game, building, resource, unit
game   --> building, resource, tech, unit, map
```

Actions and turn resolution sit at the top; they read and mutate the `Game` aggregate.
The remaining submodules (building, resource, tech, unit, map) are standalone data and logic modules.

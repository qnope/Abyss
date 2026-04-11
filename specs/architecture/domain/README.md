# Domain Layer

The domain layer (`lib/domain/`) contains all game logic as pure Dart code.
It has no dependency on Flutter, Hive APIs beyond annotations, or any UI concern.
Every rule -- resource production, building upgrades, turn resolution -- lives here.

## Submodules

The layer is split into ten submodules, each in its own subfolder.

| Submodule | Path | Role |
|-----------|------|------|
| [action](action/README.md) | `lib/domain/action/` | Defines the `Action` interface and `ActionExecutor`. Each player action (upgrade building, research tech, recruit unit, unlock branch, explore, collect treasure, fight monster, attack transition base, descend, send reinforcements, end turn) is a concrete `Action` that validates `(Game, Player)` then mutates the target `Player`. |
| [building](building/README.md) | `lib/domain/building/` | `Building` model (type + level), cost calculator, upgrade eligibility check, and the `BuildingDeactivator` used during turn resolution when energy is insufficient. |
| [fight](fight/README.md) | `lib/domain/fight/` | Combat resolution: combatants, damage, crit, target picking, turn order, engine, loot, casualties. |
| [game](game/README.md) | `lib/domain/game/` | `Game` -- the multi-player container (players map, human id, turn, multi-level `levels` map). `Player` is the per-player state aggregate (resources, buildings, tech, units per level, pending explorations, revealed cells per level, base coords, pending reinforcements, history entries). Both are Hive-serializable. |
| [history](history/README.md) | `lib/domain/history/` | `HistoryEntry` hierarchy + `makeHistoryEntry` contract for Actions. Enforces a 100-entry FIFO on `Player.historyEntries`. |
| [map](map/README.md) | `lib/domain/map/` | `GameMap` grid, `MapCell`, terrain types, cell content (monsters, resources, transition bases), procedural generation (`MapGenerator`, `TerrainGenerator`, `ContentPlacer`, `TransitionBasePlacer`), `ConnectivityChecker`, `GuardianFactory`, and `ReinforcementOrder`. |
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
action  --> game, building, resource, tech, unit, map, fight, history, turn
turn    --> game, building, resource, unit, map
fight   --> map, unit, resource
game    --> building, resource, tech, unit, map, history
history --> building, tech, unit, resource, map, fight, turn
```

Actions and turn resolution sit at the top; they iterate per player
and mutate the target `Player` (and, where unavoidable, the shared
`GameMap`). The `fight` submodule is a pure combat resolver consumed
by `FightMonsterAction`; it never mutates `Game` or `Player` directly.
The `history` submodule is passive data: concrete `HistoryEntry`
subclasses depend on the models they record (buildings, tech, units,
resources, lairs, fight results, turn results) but nothing imports
`history` back — it is purely a sink that `ActionExecutor` appends to
on success. The remaining submodules (building, resource, tech, unit,
map) are standalone data and logic modules.

# Game Module

`lib/domain/game/`

This module contains the root aggregate of the entire game state and the player profile.

## Files

| File | Description |
|------|-------------|
| `game.dart` | Root `Game` class |
| `player.dart` | `Player` profile |

## Game

`Game` is the master container that groups every piece of mutable game state into a single Hive-serializable object.

### Fields

| Field | Type | Description |
|-------|------|-------------|
| `player` | `Player` | The player profile |
| `turn` | `int` | Current turn number (starts at 1) |
| `createdAt` | `DateTime` | Timestamp of game creation |
| `resources` | `Map<ResourceType, Resource>` | All resource stocks (algae, coral, ore, energy, pearl) |
| `buildings` | `Map<BuildingType, Building>` | All buildings with their current level |
| `techBranches` | `Map<TechBranch, TechBranchState>` | Technology branch states (military, resources, explorer) |
| `units` | `Map<UnitType, Unit>` | All unit types with their current count |
| `recruitedUnitTypes` | `List<UnitType>` | Units recruited during the current turn (cleared on turn end) |
| `gameMap` | `GameMap?` | The procedurally generated map (nullable until generated) |

### Default initialization

The constructor accepts optional maps and falls back to static factory methods:
- `defaultResources()` -- algae 100, coral 80, ore 50, energy 60, pearl 5 (each with a max storage cap).
- `defaultBuildings()` -- headquarters, algae farm, coral mine, ore extractor, solar panel, laboratory, barracks (all at level 0).
- `defaultTechBranches()` -- military, resources, explorer (all locked, research level 0).
- `defaultUnits()` -- one entry per `UnitType` with count 0.

## Player

`Player` holds the player's name. It is Hive-serializable (`typeId: 0`).

### Fields

| Field | Type | Description |
|-------|------|-------------|
| `name` | `String` | Player display name |

## Serialization

Both `Game` (`typeId: 1`) and `Player` (`typeId: 0`) use Hive annotations with generated adapters (`game.g.dart`, `player.g.dart`).

# Resource System — Architecture

## Overview

Five resources drive the game economy. Four are produced per turn by buildings; one (Pearl) is found by exploration only.

## Domain Model

```
ResourceType (enum, Hive typeId: 2)
  algae | coral | ore | energy | pearl

Resource (HiveObject, typeId: 3)
  ├── type: ResourceType
  ├── amount: int          (mutable — updated on turn)
  ├── productionPerTurn: int
  └── maxStorage: int

Game.resources: Map<ResourceType, Resource>
  └── Defaults via Game.defaultResources()
```

## Starting Values

| Resource | Amount | Production/turn | Max storage |
|----------|--------|----------------|-------------|
| Algae    | 100    | 10             | 500         |
| Coral    | 80     | 8              | 500         |
| Ore      | 50     | 5              | 500         |
| Energy   | 60     | 6              | 500         |
| Pearl    | 5      | 0              | 100         |

## Design Decisions

1. **ResourceType in domain layer** — Moved from presentation so it can be persisted and referenced across layers.
2. **Map keyed by ResourceType** — O(1) lookup; enum guarantees exactly one entry per type.
3. **Mutable `amount` and `productionPerTurn`** — `amount` updated each turn; `productionPerTurn` updated when production buildings are upgraded.
4. **Pearl is special** — Zero production, lower max storage. Separated visually in the UI.

## Hive Adapter Registration Order

ResourceType → Resource → Player → Game (dependencies must be registered first).

## File Structure

```
lib/domain/
  ├── resource_type.dart      # Enum + Hive annotations
  ├── resource.dart           # Resource model
  └── game.dart               # Game model (owns resources map)
lib/data/
  └── game_repository.dart    # Adapter registration
```

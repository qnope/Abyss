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
  └── maxStorage: int

Game.resources: Map<ResourceType, Resource>
  └── Defaults via Game.defaultResources()
```

## Starting Values

| Resource | Amount | Max storage |
|----------|--------|-------------|
| Algae    | 100    | 500         |
| Coral    | 80     | 500         |
| Ore      | 50     | 500         |
| Energy   | 60     | 500         |
| Pearl    | 5      | 100         |

## Design Decisions

1. **ResourceType in domain layer** — Moved from presentation so it can be persisted and referenced across layers.
2. **Map keyed by ResourceType** — O(1) lookup; enum guarantees exactly one entry per type.
3. **Dynamic production** — Production per turn is calculated from building levels
   via `ProductionCalculator.fromBuildings()` using `ProductionFormula` and the
   `productionFormulas` registry instead of being stored on `Resource`.
   Each building type has a non-linear formula (e.g., `3*level²+2` for Algae Farm).
   This avoids sync issues when multiple systems affect production.
4. **Pearl is special** — Zero production, lower max storage. Separated visually in the UI.

## Hive Adapter Registration Order

ResourceType → Resource → Player → Game (dependencies must be registered first).

## File Structure

```
lib/domain/
  ├── resource_type.dart            # Enum + Hive annotations
  ├── resource.dart                 # Resource model
  ├── production_formula.dart       # Formula class (resourceType + compute)
  ├── production_formulas.dart      # Registry mapping BuildingType → formula
  ├── production_calculator.dart    # Dynamic production from buildings
  └── game.dart                     # Game model (owns resources map)
lib/data/
  └── game_repository.dart    # Adapter registration
```

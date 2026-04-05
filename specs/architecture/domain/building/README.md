# Building Module

## Building Types

`BuildingType` is a Hive-persisted enum with 7 values:

- **headquarters** -- central building, prerequisite for all others
- **algaeFarm** -- produces algae (food)
- **coralMine** -- produces coral (construction material)
- **oreExtractor** -- produces ore (advanced material)
- **solarPanel** -- produces energy
- **laboratory** -- unlocks research
- **barracks** -- unlocks unit training

## Building

`Building` is a Hive-persisted object with two fields:

- `type` (`BuildingType`) -- immutable, set at construction
- `level` (`int`) -- starts at 0 (not yet built), mutable

## Cost Calculation

`BuildingCostCalculator.upgradeCost(type, currentLevel)` returns a `Map<ResourceType, int>`. All costs follow the formula `base * (level^2 + 1)`, where `base` varies per building and resource. For example, headquarters costs `30 * (level^2 + 1)` coral and `20 * (level^2 + 1)` ore. Returns an empty map when the building is at max level.

## Max Level

Headquarters has a max level of 10. All other buildings have a max level of 5.

## Upgrade Prerequisites

Every building except headquarters requires a minimum headquarters level to upgrade. `BuildingCostCalculator.prerequisites(type, targetLevel)` returns a `Map<BuildingType, int>` specifying the required HQ level. The thresholds differ by building category:

- **Production buildings** (algaeFarm, coralMine, oreExtractor, solarPanel): HQ 1/2/4/6/10 for levels 1-5
- **Laboratory**: HQ 2/3/5/7/10 for levels 1-5
- **Barracks**: HQ 3/4/6/8/10 for levels 1-5

## Upgrade Check

`BuildingCostCalculator.checkUpgrade(...)` takes the building type, current level, available resources, and all buildings. It returns an `UpgradeCheck` value object containing:

- `canUpgrade` -- true only if resources and prerequisites are both satisfied
- `isMaxLevel` -- true when the building is already at max level
- `missingResources` -- map of resource shortfalls
- `missingPrerequisites` -- map of unmet building level requirements

## Building Deactivation

`BuildingDeactivator.deactivate(...)` handles energy shortages. When total energy consumption exceeds production plus stock, buildings are deactivated from lowest to highest priority:

1. oreExtractor (disabled first)
2. coralMine
3. algaeFarm
4. laboratory
5. barracks
6. solarPanel

Headquarters is never disabled. The method iterates this list in reverse priority order, subtracting each building's consumption until the remaining consumption fits within the available energy.

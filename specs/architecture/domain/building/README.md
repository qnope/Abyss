# Building Module

## Building Types

`BuildingType` is a Hive-persisted enum with 8 values:

- **headquarters** -- central building, prerequisite for all others
- **algaeFarm** -- produces algae (food)
- **coralMine** -- produces coral (construction material)
- **oreExtractor** -- produces ore (advanced material)
- **solarPanel** -- produces energy
- **laboratory** -- unlocks research
- **barracks** -- unlocks unit training
- **coralCitadel** -- defensive building; consumes `1 * level` energy, deactivated last
- **descentModule** -- unlocks faille assault (max level 1, requires HQ 5)
- **pressureCapsule** -- unlocks cheminee assault (max level 1, requires HQ 8)

## Building

`Building` is a Hive-persisted object with two fields:

- `type` (`BuildingType`) -- immutable, set at construction
- `level` (`int`) -- starts at 0 (not yet built), mutable

## Cost Calculation

`BuildingCostCalculator.upgradeCost(type, currentLevel)` returns a `Map<ResourceType, int>`. All costs follow the formula `base * (level^2 + 1)`, where `base` varies per building and resource. For example, headquarters costs `30 * (level^2 + 1)` coral and `20 * (level^2 + 1)` ore. Returns an empty map when the building is at max level.

## Max Level

Headquarters has a max level of 10. All other buildings have a max level of 5.

## Defense bonus

`CoralCitadelDefenseBonus` reads the `coralCitadel` level from a buildings map and returns a multiplier applied to the defender's DEF when the base is attacked: level 0 -> 1.0 (neutral), levels 1-5 -> 1.2 / 1.4 / 1.6 / 1.8 / 2.0. `multiplierFromBuildings` tolerates missing entries (legacy saves) and returns 1.0 in that case. `bonusLabel` yields a human-readable `+X%` string (or `aucun` at level 0).

## Upgrade Prerequisites

Every building except headquarters requires a minimum headquarters level to upgrade. `BuildingCostCalculator.prerequisites(type, targetLevel)` returns a `Map<BuildingType, int>` specifying the required HQ level. The thresholds differ by building category:

- **Production buildings** (algaeFarm, coralMine, oreExtractor, solarPanel): HQ 1/2/4/6/10 for levels 1-5
- **Laboratory**: HQ 2/3/5/7/10 for levels 1-5
- **Barracks**: HQ 3/4/6/8/10 for levels 1-5
- **Coral Citadel**: HQ 3/5/7/9/10 for levels 1-5
- **Descent Module**: HQ 5 for level 1 (max level 1)
- **Pressure Capsule**: HQ 8 for level 1 (max level 1)

## Upgrade Check

`BuildingCostCalculator.checkUpgrade(...)` takes the building type, current level, available resources, and all buildings. It returns an `UpgradeCheck` value object containing:

- `canUpgrade` -- true only if resources and prerequisites are both satisfied
- `isMaxLevel` -- true when the building is already at max level
- `missingResources` -- map of resource shortfalls
- `missingPrerequisites` -- map of unmet building level requirements

## Building Deactivation

`BuildingDeactivator.deactivate(...)` handles energy shortages. When total energy consumption exceeds production plus stock, buildings are deactivated in reverse priority order (lowest-priority entries are disabled first). The priority list is:

0. headquarters (never disabled)
1. coralCitadel (disabled last)
2. solarPanel
3. barracks
4. laboratory
5. algaeFarm
6. coralMine
7. oreExtractor (disabled first)

The method walks the list from bottom to top, subtracting each building's consumption until the remaining consumption fits within the available energy.

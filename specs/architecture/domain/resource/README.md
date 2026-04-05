# Resource Module

## Resource Types

`ResourceType` is a Hive-persisted enum with 5 values:

- **algae** -- food, consumed by units each turn
- **coral** -- construction material, used in most building upgrades
- **ore** -- advanced material, used in higher-tier upgrades
- **energy** -- power, consumed by buildings each turn
- **pearl** -- rare currency (no production building currently)

## Resource

`Resource` is a Hive-persisted object with three fields:

- `type` (`ResourceType`) -- immutable, set at construction
- `amount` (`int`) -- current stock, mutable
- `maxStorage` (`int`) -- storage cap, defaults to 500

## Production Calculator

`ProductionCalculator.fromBuildings(buildings, {techBranches})` computes per-turn production by iterating over all buildings with `level > 0`, looking up each building's `ProductionFormula`, and calling `compute(level)`. Results are summed per resource type. If the `resources` tech branch has a research level above 0, a multiplier of `1.0 + 0.2 * researchLevel` is applied to all production (floored to int).

## Production Formulas

`ProductionFormula` pairs a `ResourceType` with a level-based computation function. It returns 0 for level 0 or below.

The `productionFormulas` constant maps building types to their formulas:

| Building       | Resource | Formula                  |
|----------------|----------|--------------------------|
| algaeFarm      | algae    | `30 * level^2 + 20`     |
| coralMine      | coral    | `20 * level^2 + 20`     |
| oreExtractor   | ore      | `20 * level^2 + 10`     |
| solarPanel     | energy   | `12 * level^2 + 6`      |

## Consumption Calculator

`ConsumptionCalculator` computes energy consumption for buildings and algae consumption for units:

- `buildingEnergyConsumption(type, level)` -- returns `multiplier * level`, where the multiplier is 1-4 depending on building type (laboratory is highest at 4, solarPanel lowest at 1)
- `totalBuildingConsumption(buildings, {excluded})` -- sums energy consumption across all buildings, optionally excluding a set of types
- `unitAlgaeConsumption(type)` -- returns 1-3 algae per unit type
- `totalUnitConsumption(units)` -- sums algae consumption across all unit counts

## Maintenance Calculator

`MaintenanceCalculator.fromUnits(units)` computes per-turn resource costs for maintaining an army. It delegates to `UnitCostCalculator.maintenanceCost(type)` for each unit type, multiplies by the unit count, and aggregates across all resource types. Units with a count of 0 or below are skipped.

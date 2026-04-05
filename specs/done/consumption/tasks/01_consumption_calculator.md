# Task 1: Create ConsumptionCalculator

## Summary

Create a stateless calculator that computes energy consumption for buildings and algae consumption for units. Follows the same pattern as `ProductionCalculator`.

## Implementation Steps

### 1. Create `lib/domain/consumption_calculator.dart`

- Class `ConsumptionCalculator` with static methods only
- **`buildingEnergyConsumption(BuildingType type, int level) → int`**: returns energy consumed by a single building at given level. Formula per type:
  - `headquarters`: `3 × level`
  - `algaeFarm`: `2 × level`
  - `coralMine`: `2 × level`
  - `oreExtractor`: `3 × level`
  - `solarPanel`: `1 × level`
  - `laboratory`: `4 × level`
  - `barracks`: `3 × level`
  - Level 0 returns 0
- **`totalBuildingConsumption(Map<BuildingType, Building> buildings, {Set<BuildingType>? excluded}) → int`**: sums energy consumption across all buildings, optionally excluding a set of building types (used for deactivation calculations)
- **`unitAlgaeConsumption(UnitType type) → int`**: returns algae consumed per unit per turn:
  - `scout`: 1
  - `harpoonist`: 2
  - `guardian`: 3
  - `domeBreaker`: 3
  - `siphoner`: 2
  - `saboteur`: 2
- **`totalUnitConsumption(Map<UnitType, Unit> units) → int`**: sums algae consumption across all units (consumption × count per type)

## Dependencies

- `lib/domain/building_type.dart` (BuildingType enum)
- `lib/domain/building.dart` (Building class)
- `lib/domain/unit_type.dart` (UnitType enum)
- `lib/domain/unit.dart` (Unit class)

## Test Plan

- File: `test/domain/consumption_calculator_test.dart`
- See Task 2

## Notes

- Keep it stateless (static methods) like `ProductionCalculator`
- `excluded` parameter on `totalBuildingConsumption` allows TurnResolver to calculate consumption after disabling buildings without mutating state
- Should stay well under 150 lines

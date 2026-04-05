# Task 2: Test ConsumptionCalculator

## Summary

Write comprehensive unit tests for the `ConsumptionCalculator` class.

## Implementation Steps

### 1. Create `test/domain/consumption_calculator_test.dart`

#### Group: `buildingEnergyConsumption`
- `headquarters level 3 consumes 9 energy` → `ConsumptionCalculator.buildingEnergyConsumption(BuildingType.headquarters, 3)` == 9
- `algaeFarm level 5 consumes 10 energy` → == 10
- `coralMine level 2 consumes 4 energy` → == 4
- `oreExtractor level 4 consumes 12 energy` → == 12
- `solarPanel level 5 consumes 5 energy` → == 5
- `laboratory level 1 consumes 4 energy` → == 4
- `barracks level 3 consumes 9 energy` → == 9
- `level 0 returns 0` → == 0

#### Group: `totalBuildingConsumption`
- `sums all active buildings` → HQ(2) + AlgaeFarm(1) = 6+2 = 8
- `level 0 buildings are excluded` → all at level 0 = 0
- `excluded buildings are not counted` → HQ(2)+AlgaeFarm(1) with AlgaeFarm excluded = 6
- `empty map returns 0`

#### Group: `unitAlgaeConsumption`
- `scout consumes 1 algae` → == 1
- `harpoonist consumes 2 algae` → == 2
- `guardian consumes 3 algae` → == 3
- `domeBreaker consumes 3 algae` → == 3
- `siphoner consumes 2 algae` → == 2
- `saboteur consumes 2 algae` → == 2

#### Group: `totalUnitConsumption`
- `sums across unit types` → 10 scouts + 5 guardians = 10×1 + 5×3 = 25
- `zero count units contribute nothing` → all units at count 0 = 0
- `empty map returns 0`

## Dependencies

- Task 1 (ConsumptionCalculator must exist)

## Test Plan

- Run: `flutter test test/domain/consumption_calculator_test.dart`

## Notes

- Follow the same test style as `production_calculator_test.dart`
- Use inline helper functions for creating building/unit maps

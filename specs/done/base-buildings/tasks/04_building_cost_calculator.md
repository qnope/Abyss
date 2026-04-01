# Task 04 — BuildingCostCalculator

## Summary

Create a standalone class that calculates upgrade costs, max levels, and prerequisites for each building type.

## Implementation Steps

1. Create `lib/domain/building_cost_calculator.dart`
2. Define the class:

```dart
class BuildingCostCalculator {
  /// Cost to upgrade from [currentLevel] to currentLevel+1.
  /// Returns empty map if already at max level.
  Map<ResourceType, int> upgradeCost(BuildingType type, int currentLevel) {
    if (currentLevel >= maxLevel(type)) return {};
    return switch (type) {
      BuildingType.headquarters => {
        ResourceType.coral: 30 * (currentLevel * currentLevel + 1),
        ResourceType.ore: 20 * (currentLevel * currentLevel + 1),
      },
    };
  }

  int maxLevel(BuildingType type) => switch (type) {
    BuildingType.headquarters => 10,
  };

  /// Other buildings required at a minimum level to upgrade [type] to [targetLevel].
  /// Empty map = no prerequisites.
  Map<BuildingType, int> prerequisites(BuildingType type, int targetLevel) {
    return switch (type) {
      BuildingType.headquarters => {},
    };
  }
}
```

3. Import `building_type.dart` and `resource_type.dart`

## Files

| Action | Path |
|--------|------|
| Create | `lib/domain/building_cost_calculator.dart` |

## Dependencies

- Task 01 (BuildingType enum)
- No dependency on Task 02 (Building model)

## Test Plan

- Tested in task 07 (`building_cost_calculator_test.dart`)

## Notes

- `baseCoral = 30`, `baseOre = 20` — values from SPEC
- Formula: `base * (N² + 1)` where N is the current level
- Level 0→1 costs: coral=30, ore=20 (N=0: 0²+1=1)
- Level 1→2 costs: coral=60, ore=40 (N=1: 1²+1=2)
- Level 9→10 costs: coral=2430, ore=1620 (N=9: 81+1=82)
- Prerequisites return empty map for QG; future buildings will return e.g. `{BuildingType.headquarters: 3}`
- `upgradeCost` returns empty map at max level — this signals "no upgrade possible"

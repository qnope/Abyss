# Task 14: Domain Tests — UnitType, UnitStats, UnitCostCalculator

## Summary

Write unit tests for the core domain models and the cost calculator.

## Implementation Steps

### 1. Create `test/domain/unit_type_test.dart`

- `UnitType.values` has 6 entries
- All 6 values are distinct

### 2. Create `test/domain/unit_stats_test.dart`

- group 'forType':
  - Scout: hp=10, atk=2, def=1
  - Harpoonist: hp=15, atk=5, def=2
  - Guardian: hp=25, atk=2, def=6
  - Dome Breaker: hp=20, atk=8, def=3
  - Siphoner: hp=12, atk=3, def=2
  - Saboteur: hp=8, atk=10, def=1

### 3. Create `test/domain/unit_cost_calculator_test.dart`

- group 'recruitmentCost':
  - Scout costs {algae: 10, coral: 5}
  - Harpoonist costs {algae: 15, coral: 10, ore: 5}
  - Guardian costs {coral: 20, ore: 15}
  - Dome Breaker costs {ore: 25, energy: 15}
  - Siphoner costs {algae: 20, energy: 10, pearl: 2}
  - Saboteur costs {coral: 15, energy: 20, pearl: 3}

- group 'unlockLevel':
  - Scout → 1, Harpoonist → 1
  - Guardian → 3, Dome Breaker → 3
  - Siphoner → 5, Saboteur → 5

- group 'isUnlocked':
  - Scout at barracks 1 → true
  - Scout at barracks 0 → false
  - Guardian at barracks 2 → false
  - Guardian at barracks 3 → true

- group 'maxRecruitableCount':
  - Scout with 100 algae + 50 coral, barracks 1 → min(100, min(10, 10)) = 10
  - Scout with 100 algae + 50 coral, barracks 5 → min(500, 10) = 10
  - Scout with 5 algae + 5 coral, barracks 1 → 0 (floor(5/10)=0)
  - Barracks level cap: 200 algae + 200 coral, barracks 1 → capped at 100

### 4. Create `test/domain/unit_test.dart`

- Unit default count is 0
- Count is mutable
- Custom count at construction

## Dependencies

- Tasks 01, 02, 03 (all domain models)

## Test Plan

This IS the test task. Files listed above.

## Notes

- Use `setUp(() => calculator = UnitCostCalculator())` pattern.
- Helper function `_resource(ResourceType type, int amount)` to create test resources.

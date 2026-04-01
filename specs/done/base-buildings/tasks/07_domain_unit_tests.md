# Task 07 — Domain Unit Tests

## Summary

Write unit tests for all new domain models: BuildingType, Building, BuildingCostCalculator, UpgradeCheck, and updated Game.

## Implementation Steps

### 1. Create `test/domain/building_type_test.dart`

Test cases:
- `BuildingType.headquarters` exists
- Enum has exactly 1 value (for now)

### 2. Create `test/domain/building_test.dart`

Test cases:
- Creates with required `type` field
- Default level is 0
- Level is mutable
- Accepts custom level

### 3. Create `test/domain/building_cost_calculator_test.dart`

Test cases:
- **upgradeCost:**
  - HQ level 0→1: coral=30, ore=20
  - HQ level 1→2: coral=60, ore=40
  - HQ level 5→6: coral=780, ore=520
  - HQ level 9→10: coral=2430, ore=1620
  - HQ at max level (10): returns empty map
- **maxLevel:**
  - HQ max level is 10
- **prerequisites:**
  - HQ has no prerequisites at any level (returns empty map)
- **checkUpgrade:**
  - Can upgrade when resources are sufficient
  - Cannot upgrade when coral is insufficient → missingResources contains coral deficit
  - Cannot upgrade when ore is insufficient → missingResources contains ore deficit
  - Cannot upgrade at max level → isMaxLevel is true
  - Cannot upgrade when prerequisite building level is too low → missingPrerequisites
  - canUpgrade is false when both resources and prerequisites are insufficient

### 4. Update `test/domain/game_test.dart`

Add test cases:
- Game creates with default buildings (1 building: headquarters at level 0)
- Game creates with custom buildings list

## Files

| Action | Path |
|--------|------|
| Create | `test/domain/building_type_test.dart` |
| Create | `test/domain/building_test.dart` |
| Create | `test/domain/building_cost_calculator_test.dart` |
| Modify | `test/domain/game_test.dart` — add buildings tests |

## Dependencies

- Task 01–06 (all domain tasks)

## Test Plan

Run: `flutter test test/domain/`

All tests must pass. Run `flutter analyze` to confirm no warnings.

## Notes

- Follow existing test patterns (see `test/domain/resource_test.dart` for style)
- Use `group()` for each class/concern
- For `checkUpgrade` tests, create helper resources maps with specific amounts

# Task 05: Update existing tests and add new ones

## Summary
Update existing tests that may break due to the new enum values, and add new tests as described in tasks 02-04.

## Implementation Steps

### 1. Update `test/domain/building_type_test.dart`
- Update the test that checks `BuildingType.values.length` (was 5, now 7)
- Add assertions that `BuildingType.laboratory` and `BuildingType.barracks` exist

### 2. Update `test/domain/building_cost_calculator_test.dart`
- Add cost tests for laboratory and barracks (level 0→1, max level)

### 3. Update `test/domain/building_cost_calculator_prerequisites_test.dart`
- Add prerequisite tests for laboratory (HQ 2 at level 1) and barracks (HQ 3 at level 1)

### 4. Update `test/domain/building_cost_calculator_check_upgrade_test.dart`
- Add checkUpgrade tests for laboratory and barracks (blocked by HQ prerequisite, blocked by resources, success case)

### 5. Add extension tests if not existing
- Test displayName, iconPath for laboratory and barracks

## Dependencies
- Tasks 01-04 (all code changes must be done)

## Test Plan
- Run `flutter test` — all tests must pass
- Run `flutter analyze` — zero issues

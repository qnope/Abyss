# Task 04 — Update BuildingCostCalculator tests

## Summary

Change all `List<Building>` fixtures in `test/domain/building_cost_calculator_test.dart` to `Map<BuildingType, Building>`.

## Implementation steps

### Edit `test/domain/building_cost_calculator_test.dart`

5 occurrences of list fixtures to convert:

- Line 89–91: `final buildings = [Building(...)]` → `final buildings = {BuildingType.headquarters: Building(...)}`
- Line 117–119: same change
- Line 143–145: same change
- Line 169–171: same change
- Line 196: `final buildings = <Building>[]` → `final buildings = <BuildingType, Building>{}`

## Dependencies

- Task 03 (calculator API must be updated first).

## Test plan

- Run `flutter test test/domain/building_cost_calculator_test.dart` — all 10 tests must pass.

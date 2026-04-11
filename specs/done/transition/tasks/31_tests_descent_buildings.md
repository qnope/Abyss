# Task 31: Tests — Descent Buildings and Unit Rename

## Summary
Unit tests for descent building costs/constraints and the siphoner → abyssAdmiral rename.

## Implementation Steps

1. **Update/create test** `test/domain/building/building_cost_calculator_test.dart`:
   - `descentModule cost is {coral: 200, ore: 150, energy: 80, pearl: 5}`
   - `pressureCapsule cost is {coral: 400, ore: 300, energy: 150, pearl: 15}`
   - `descentModule maxLevel is 1`
   - `pressureCapsule maxLevel is 1`
   - `descentModule prerequisite is HQ level 5`
   - `pressureCapsule prerequisite is HQ level 8`
   - `checkUpgrade returns canUpgrade false when at max level (1)`
   - `checkUpgrade returns canUpgrade false when insufficient resources`

2. **Update test** `test/domain/unit/unit_stats_test.dart`:
   - `abyssAdmiral has HP 100, ATK 0, DEF 0`
   - `No siphoner references remain in codebase` (grep check)

3. **Verify exhaustive switches**:
   - Run `flutter analyze` — any non-exhaustive switch on `BuildingType` or `UnitType` will be caught

## Dependencies
- **Internal**: Task 01 (rename), Task 09 (descent buildings)
- **External**: None

## Test Plan
- Self — this IS the test task
- Run `flutter test test/domain/building/building_cost_calculator_test.dart`
- Run `flutter test test/domain/unit/unit_stats_test.dart`
- Run `flutter analyze`

## Notes
- These are straightforward value-check tests. Quick to write.

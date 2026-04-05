# Task 6: Test Building Deactivation

## Summary

Write unit tests for `BuildingDeactivator.deactivate()`.

## Implementation Steps

### 1. Create `test/domain/building_deactivator_test.dart`

#### Group: `deactivate`

- `no deficit returns empty list` — Energy production=50, stock=0, consumption=30 → []
- `exact balance returns empty list` — production+stock == consumption → []
- `disables ore extractor first` — Small deficit → only [oreExtractor]
- `disables multiple buildings in priority order` — Larger deficit → [oreExtractor, coralMine]
- `never disables headquarters` — Even with huge deficit, HQ not in result
- `skips level 0 buildings` — OreExtractor at level 0, deficit → skip to next priority (coralMine)
- `uses stock to cover deficit` — production=10, stock=20, consumption=25 → no deactivation
- `stock not enough triggers deactivation` — production=10, stock=5, consumption=25 → deactivation
- `all non-HQ buildings deactivated in extreme deficit` — production=0, stock=0, all buildings active → 6 buildings deactivated (all except HQ)
- `solar panel disabled last (before HQ)` — Very large deficit → solar panel in deactivated list only when all others already disabled

## Dependencies

- Task 5 (BuildingDeactivator must exist)
- Task 1 (ConsumptionCalculator)

## Test Plan

- Run: `flutter test test/domain/building_deactivator_test.dart`

## Notes

- Use helper function to create buildings at specific levels
- Test the ordering of the returned list matches the expected deactivation order

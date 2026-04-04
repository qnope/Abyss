# Task 05 — Update upgrade action production tests

## Summary

Update `test/domain/upgrade_building_action_production_test.dart` to expect non-linear production values after building upgrades.

## Implementation Steps

### 1. Edit `test/domain/upgrade_building_action_production_test.dart`

Update expected values:

| Test | Old expected | New expected |
|---|---|---|
| `execute algaeFarm increases production via calculator` | algae: 5 | algae: 5 (3×1+2=5) — unchanged! |
| `execute algaeFarm twice cumulates production` | algae: 10 | algae: 14 (3×4+2=14, single L2 building) |

Key insight: "execute algaeFarm twice" brings algaeFarm to level 2. With non-linear production, this is `3×4+2 = 14`, not `2×5 = 10`. The formula operates on the building's current level, not the sum of per-level bonuses.

## Dependencies

- Task 03 (ProductionCalculator updated).

## Test Plan

- **File**: `test/domain/upgrade_building_action_production_test.dart`
- Run: `flutter test test/domain/upgrade_building_action_production_test.dart`
- All 6 tests should pass.

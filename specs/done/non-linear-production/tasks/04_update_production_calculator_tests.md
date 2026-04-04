# Task 04 — Update ProductionCalculator tests for non-linear values

## Summary

Update `test/domain/production_calculator_test.dart` to expect non-linear production values from the new formulas instead of the old `level * basePerLevel`.

## Implementation Steps

### 1. Edit `test/domain/production_calculator_test.dart`

Update expected values in each test:

| Test | Old expected | New expected |
|---|---|---|
| `algaeFarm at level 3 produces X algae` | 15 | 29 (3×9+2) |
| `coralMine at level 2 produces X coral` | 8 | 10 (2×4+2) |
| `oreExtractor at level 1 produces X ore` | 3 | 3 (2×1+1) — unchanged |
| `solarPanel at level 4 produces X energy` | 12 | 33 (2×16+1) |
| `multiple buildings cumulate correctly` | algae:10, coral:12, ore:3, energy:6 | algae:14, coral:20, ore:3, energy:9 |
| `pearl is never in the result` | no value change | check still valid |

Detailed new values for "multiple buildings cumulate":
- algaeFarm L2: 3×4+2 = 14
- coralMine L3: 2×9+2 = 20
- oreExtractor L1: 2×1+1 = 3
- solarPanel L2: 2×4+1 = 9

Also update test names to remove linear hints (e.g., "produces 29 algae" instead of "15").

## Dependencies

- Task 03 (ProductionCalculator updated).

## Test Plan

- **File**: `test/domain/production_calculator_test.dart`
- Run: `flutter test test/domain/production_calculator_test.dart`
- All 7 tests should pass.

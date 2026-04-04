# Task 08 — Final validation

## Summary

Run the full test suite and analyzer to confirm zero errors and no regressions.

## Implementation Steps

### 1. Run `flutter analyze`

Verify zero issues. In particular check:
- No remaining references to `productionPerLevel` in `lib/`.
- No unused imports.

### 2. Run `flutter test`

All tests must pass. Key test files:
- `test/domain/production_formula_test.dart` (new)
- `test/domain/production_formulas_test.dart` (new)
- `test/domain/production_calculator_test.dart` (updated)
- `test/domain/upgrade_building_action_production_test.dart` (updated)
- `test/domain/building_cost_calculator_prerequisites_test.dart` (updated)
- All other existing tests (unchanged, should still pass).

## Dependencies

- All previous tasks (01–07).

## Test Plan

- `flutter analyze` → 0 issues
- `flutter test` → all green

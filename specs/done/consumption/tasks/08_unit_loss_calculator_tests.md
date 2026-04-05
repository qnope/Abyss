# Task 8: Test Unit Loss Calculator

## Summary

Write unit tests for `UnitLossCalculator.calculateLosses()`.

## Implementation Steps

### 1. Create `test/domain/unit_loss_calculator_test.dart`

#### Group: `calculateLosses`

- `no deficit returns empty map` — algae production=100, consumption=50 → {}
- `exact balance returns empty map` — production+stock == consumption → {}
- `proportional losses across types` — 50% deficit → each type loses ceil(50% of count)
  - Example: 10 scouts (1 algae each = 10), 10 guardians (3 algae each = 30). Total=40. Available=20. Deficit=20. Ratio=0.5. Scouts lose ceil(10×0.5)=5. Guardians lose ceil(10×0.5)=5.
- `losses rounded up (ceil)` — 3 scouts, deficit ratio 0.33 → ceil(3×0.33) = 1 scout lost
- `losses cannot exceed unit count` — ratio = 1.0 (total deficit) → lose all units, not more
- `zero count units not in result` — units with count=0 not in returned map
- `single unit type` — Only scouts, small deficit → correct loss
- `stock covers deficit` — production=10, stock=30, consumption=35 → no losses
- `stock not enough` — production=10, stock=5, consumption=30 → losses based on deficit=15
- `100% deficit kills all units` — production=0, stock=0 → all units lost

## Dependencies

- Task 7 (UnitLossCalculator must exist)
- Task 1 (ConsumptionCalculator)

## Test Plan

- Run: `flutter test test/domain/unit_loss_calculator_test.dart`

## Notes

- Use helper function to create unit maps with specific counts

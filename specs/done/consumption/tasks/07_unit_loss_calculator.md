# Task 7: Add Unit Loss Calculator

## Summary

Create a stateless class that calculates proportional unit losses when algae is insufficient.

## Implementation Steps

### 1. Create `lib/domain/unit_loss_calculator.dart`

```dart
class UnitLossCalculator {
  /// Returns map of unit losses per type when algae is insufficient.
  /// Losses are proportional: each type loses the same percentage,
  /// rounded UP for losses (ceil).
  ///
  /// Algorithm:
  /// 1. totalConsumption = sum of all units' algae consumption
  /// 2. available = algaeProduction + algaeStock
  /// 3. If available >= totalConsumption: return empty map
  /// 4. deficit = totalConsumption - available
  /// 5. lossRatio = deficit / totalConsumption (0.0 to 1.0)
  /// 6. For each unit type with count > 0:
  ///    losses[type] = ceil(count × lossRatio)
  ///    Ensure losses[type] <= count
  static Map<UnitType, int> calculateLosses({
    required Map<UnitType, Unit> units,
    required int algaeProduction,
    required int algaeStock,
  }) {
    // ... implementation
  }
}
```

**Key details:**
- `lossRatio` is based on total algae deficit vs total algae consumption
- Each unit type loses `ceil(count × lossRatio)` units (rounded UP = harsher penalty)
- If a type has 0 units, skip it
- Losses cannot exceed the unit's count

## Dependencies

- Task 1 (`ConsumptionCalculator` for `unitAlgaeConsumption` and `totalUnitConsumption`)
- `lib/domain/unit.dart`
- `lib/domain/unit_type.dart`

## Test Plan

- File: `test/domain/unit_loss_calculator_test.dart`
- See Task 8

## Notes

- File should be ~40-50 lines
- The ceil rounding means even a tiny deficit kills at least 1 unit of each type that has units

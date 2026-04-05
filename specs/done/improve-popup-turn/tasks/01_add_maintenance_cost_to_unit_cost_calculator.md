# Task 1: Add maintenance cost to UnitCostCalculator

## Summary

Add a `maintenanceCost(UnitType)` method to `UnitCostCalculator` that returns the per-unit per-turn maintenance cost. All units cost only algae.

## Implementation Steps

### 1. Add `maintenanceCost` method to `UnitCostCalculator`

**File**: `lib/domain/unit_cost_calculator.dart`

Add the following method to the `UnitCostCalculator` class:

```dart
Map<ResourceType, int> maintenanceCost(UnitType type) => switch (type) {
  UnitType.scout => {ResourceType.algae: 1},
  UnitType.harpoonist => {ResourceType.algae: 2},
  UnitType.guardian => {ResourceType.algae: 3},
  UnitType.domeBreaker => {ResourceType.algae: 2},
  UnitType.siphoner => {ResourceType.algae: 3},
  UnitType.saboteur => {ResourceType.algae: 2},
};
```

### 2. Add tests

**File**: `test/domain/unit_cost_calculator_test.dart`

Add a new `group('maintenanceCost', ...)` with tests:
- `scout costs 1 algae` — verify `maintenanceCost(UnitType.scout)` returns `{ResourceType.algae: 1}`
- `harpoonist costs 2 algae`
- `guardian costs 3 algae`
- `domeBreaker costs 2 algae`
- `siphoner costs 3 algae`
- `saboteur costs 2 algae`
- `all unit types have maintenance` — verify all `UnitType.values` return a non-empty map

## Dependencies

- None (standalone addition to existing file)

## Test Plan

- **File**: `test/domain/unit_cost_calculator_test.dart`
- Run: `flutter test test/domain/unit_cost_calculator_test.dart`
- Verify all existing tests still pass (no regression)
- Verify each unit type has a defined maintenance cost

## Notes

- Maintenance is algae-only for all unit types (user decision)
- The method mirrors the pattern of existing `recruitmentCost(UnitType)` method
- Values: Scout=1, Harpoonist=2, Guardian=3, DomeBreaker=2, Siphoner=3, Saboteur=2

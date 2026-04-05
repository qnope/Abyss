# Task 2: Create MaintenanceCalculator

## Summary

Create a stateless `MaintenanceCalculator` that computes total maintenance costs from all units, following the same pattern as `ProductionCalculator`.

## Implementation Steps

### 1. Create `MaintenanceCalculator`

**File**: `lib/domain/maintenance_calculator.dart`

```dart
import 'resource_type.dart';
import 'unit.dart';
import 'unit_cost_calculator.dart';
import 'unit_type.dart';

class MaintenanceCalculator {
  static Map<ResourceType, int> fromUnits(Map<UnitType, Unit> units) {
    final calculator = UnitCostCalculator();
    final result = <ResourceType, int>{};
    for (final entry in units.entries) {
      if (entry.value.count <= 0) continue;
      final cost = calculator.maintenanceCost(entry.key);
      for (final c in cost.entries) {
        result[c.key] = (result[c.key] ?? 0) + c.value * entry.value.count;
      }
    }
    return result;
  }
}
```

### 2. Add tests

**File**: `test/domain/maintenance_calculator_test.dart`

Tests:
- `no units returns empty map` — all units with count=0
- `single unit type with count 1` — e.g. 5 scouts → 5 algae
- `single unit type with count 10` — e.g. 10 harpoonists → 20 algae
- `multiple unit types sum correctly` — e.g. 5 scouts + 3 guardians → 14 algae
- `units with zero count are ignored` — mix of count=0 and count>0

## Dependencies

- **Task 1**: `UnitCostCalculator.maintenanceCost()` must exist

## Test Plan

- **File**: `test/domain/maintenance_calculator_test.dart`
- Run: `flutter test test/domain/maintenance_calculator_test.dart`
- Verify all calculations aggregate correctly across multiple unit types

## Notes

- Follows the `ProductionCalculator.fromBuildings()` pattern: static method, stateless, returns `Map<ResourceType, int>`
- The calculator delegates per-unit costs to `UnitCostCalculator.maintenanceCost()`
- Currently all maintenance is algae-only, but the map-based approach supports future extension to other resource types

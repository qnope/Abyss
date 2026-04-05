# Task 5: Add Building Deactivation Logic

## Summary

Create a stateless class that determines which buildings must be deactivated when energy is insufficient, following the priority order from the spec.

## Implementation Steps

### 1. Create `lib/domain/building_deactivator.dart`

```dart
class BuildingDeactivator {
  /// Priority order: buildings later in this list are disabled first.
  /// HQ is never disabled (index 0, never reached).
  static const List<BuildingType> _priority = [
    BuildingType.headquarters,   // 0 - never disabled
    BuildingType.solarPanel,     // 1
    BuildingType.barracks,       // 2
    BuildingType.laboratory,     // 3
    BuildingType.algaeFarm,      // 4
    BuildingType.coralMine,      // 5
    BuildingType.oreExtractor,   // 6 - disabled first
  ];

  /// Returns list of buildings that must be deactivated.
  /// Algorithm:
  /// 1. Compute total energy consumption of all active buildings
  /// 2. Available energy = energyProduction + energyStock
  /// 3. While consumption > available, disable lowest priority building
  ///    (which reduces consumption since disabled = 0 consumption)
  /// 4. Return list of disabled building types
  static List<BuildingType> deactivate({
    required Map<BuildingType, Building> buildings,
    required int energyProduction,
    required int energyStock,
  }) {
    // ... implementation
  }
}
```

**Algorithm detail:**
1. Start with all buildings as active
2. Calculate total consumption using `ConsumptionCalculator.totalBuildingConsumption`
3. Available = energyProduction + energyStock
4. If consumption <= available: return empty list
5. Iterate `_priority` from end (index 6 → 1, skip HQ at 0):
   - If building level > 0, add to deactivated list, subtract its consumption
   - If consumption <= available: stop
6. Return deactivated list

## Dependencies

- Task 1 (`ConsumptionCalculator`)
- `lib/domain/building.dart`
- `lib/domain/building_type.dart`

## Test Plan

- File: `test/domain/building_deactivator_test.dart`
- See Task 6

## Notes

- HQ is never disabled (skip index 0)
- Only buildings with level > 0 can be disabled
- File should be ~50 lines

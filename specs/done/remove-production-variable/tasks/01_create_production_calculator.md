# Task 01 — Create ProductionCalculator

## Summary

Create a new `ProductionCalculator` class that computes per-resource production from building levels. This replaces the stored `productionPerTurn` variable with a dynamic calculation.

## Implementation Steps

### Step 1: Create `lib/domain/production_calculator.dart`

```dart
import 'building.dart';
import 'building_cost_calculator.dart';
import 'building_type.dart';
import 'resource_type.dart';

class ProductionCalculator {
  static Map<ResourceType, int> fromBuildings(
    Map<BuildingType, Building> buildings,
  ) {
    final result = <ResourceType, int>{};
    for (final building in buildings.values) {
      final prod = BuildingCostCalculator.productionPerLevel(building.type);
      if (prod != null && building.level > 0) {
        result[prod.key] = (result[prod.key] ?? 0) + building.level * prod.value;
      }
    }
    return result;
  }
}
```

Uses `BuildingCostCalculator.productionPerLevel()` which already maps each building type to its `(ResourceType, bonus)` pair. Formula: `level * bonus_per_level` per building, summed per resource.

### Step 2: Create `test/domain/production_calculator_test.dart`

Test cases:
1. All buildings at level 0 → returns empty map (no production)
2. AlgaeFarm at level 3 → `{algae: 15}` (3 * 5)
3. CoralMine at level 2 → `{coral: 8}` (2 * 4)
4. OreExtractor at level 1 → `{ore: 3}` (1 * 3)
5. SolarPanel at level 4 → `{energy: 12}` (4 * 3)
6. Multiple buildings with levels → cumulated correctly
7. Headquarters produces nothing regardless of level
8. Pearl is never in the result (no building produces it)

## Dependencies

- `lib/domain/building_cost_calculator.dart` — `productionPerLevel()` static method (exists, no changes)
- `lib/domain/building.dart` — `Building` model (exists, no changes)

## Test Plan

- File: `test/domain/production_calculator_test.dart`
- Run: `flutter test test/domain/production_calculator_test.dart`

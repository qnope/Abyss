# Task 03 — Update ProductionCalculator to use ProductionFormula

## Summary

Rewrite `ProductionCalculator.fromBuildings` to delegate to `productionFormulas` instead of `BuildingCostCalculator.productionPerLevel`. The calculator no longer does `level * basePerLevel` — it calls `formula.compute(level)`.

## Implementation Steps

### 1. Edit `lib/domain/production_calculator.dart`

**Before:**
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

**After:**
```dart
import 'building.dart';
import 'building_type.dart';
import 'production_formulas.dart';
import 'resource_type.dart';

class ProductionCalculator {
  static Map<ResourceType, int> fromBuildings(
    Map<BuildingType, Building> buildings,
  ) {
    final result = <ResourceType, int>{};
    for (final building in buildings.values) {
      final formula = productionFormulas[building.type];
      if (formula != null && building.level > 0) {
        final amount = formula.compute(building.level);
        result[formula.resourceType] =
            (result[formula.resourceType] ?? 0) + amount;
      }
    }
    return result;
  }
}
```

Key changes:
- Remove import of `building_cost_calculator.dart`.
- Add import of `production_formulas.dart`.
- Replace `BuildingCostCalculator.productionPerLevel(building.type)` with `productionFormulas[building.type]`.
- Replace `building.level * prod.value` with `formula.compute(building.level)`.

## Dependencies

- Task 01 (`ProductionFormula` class).
- Task 02 (`productionFormulas` map).

## Test Plan

- Existing tests in `test/domain/production_calculator_test.dart` will **fail** after this change because expected values change from linear to non-linear. Tests are updated in Task 04.
- Run: `flutter analyze` (should pass — no broken imports).

# Task 02 — Create production formulas registry

## Summary

Create a top-level map that associates each `BuildingType` to its `ProductionFormula` (or no entry for non-producing buildings). This replaces the role of `BuildingCostCalculator.productionPerLevel`.

## Implementation Steps

### 1. Create `lib/domain/production_formulas.dart`

```dart
import 'building_type.dart';
import 'production_formula.dart';
import 'resource_type.dart';

const Map<BuildingType, ProductionFormula> productionFormulas = {
  BuildingType.algaeFarm: ProductionFormula(
    resourceType: ResourceType.algae,
    compute: _algaeFarmProduction,
  ),
  BuildingType.coralMine: ProductionFormula(
    resourceType: ResourceType.coral,
    compute: _coralMineProduction,
  ),
  BuildingType.oreExtractor: ProductionFormula(
    resourceType: ResourceType.ore,
    compute: _oreExtractorProduction,
  ),
  BuildingType.solarPanel: ProductionFormula(
    resourceType: ResourceType.energy,
    compute: _solarPanelProduction,
  ),
};

int _algaeFarmProduction(int level) => 3 * level * level + 2;
int _coralMineProduction(int level) => 2 * level * level + 2;
int _oreExtractorProduction(int level) => 2 * level * level + 1;
int _solarPanelProduction(int level) => 2 * level * level + 1;
```

Key points:
- Headquarters is absent from the map (no production).
- Private top-level functions for each formula — simple, testable.
- The `const` map makes it a compile-time constant.

### 2. Create test file `test/domain/production_formulas_test.dart`

Test each formula at levels 1–5 against the spec table:

| Building | L1 | L2 | L3 | L4 | L5 |
|---|---|---|---|---|---|
| AlgaeFarm | 5 | 14 | 29 | 50 | 77 |
| CoralMine | 4 | 10 | 20 | 34 | 52 |
| OreExtractor | 3 | 9 | 19 | 33 | 51 |
| SolarPanel | 3 | 9 | 19 | 33 | 51 |

Additional tests:
- `productionFormulas` does not contain `BuildingType.headquarters`.
- Each formula returns the correct `resourceType`.

## Dependencies

- Task 01 (`ProductionFormula` class exists).

## Test Plan

- **File**: `test/domain/production_formulas_test.dart`
- Run: `flutter test test/domain/production_formulas_test.dart`
- Run: `flutter analyze`

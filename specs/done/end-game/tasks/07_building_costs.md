# Task 7: Add volcanic kernel building costs and max level

## Summary

Define the cost formula for the Noyau Volcanique building (pearl-heavy, high costs) and wire it into `BuildingCostCalculator`.

## Implementation Steps

### 1. Create `lib/domain/building/volcanic_kernel_costs.dart`

```dart
import '../resource/resource_type.dart';

Map<ResourceType, int> volcanicKernelCost(int currentLevel) {
  final scale = currentLevel * currentLevel + 1;
  return {
    ResourceType.coral: 50 * scale,
    ResourceType.ore: 40 * scale,
    ResourceType.energy: 30 * scale,
    ResourceType.pearl: 5 + 3 * (currentLevel + 1),
  };
}
```

Cost table (currentLevel → next level):
| From | Coral | Ore | Energy | Pearl |
|------|-------|-----|--------|-------|
| 0→1  | 50    | 40  | 30     | 8     |
| 1→2  | 100   | 80  | 60     | 11    |
| 4→5  | 850   | 680 | 510    | 20    |
| 9→10 | 4100  | 3280| 2460   | 35    |

Pearl costs stay within max storage (100). Other resources scale quadratically.

### 2. Edit `lib/domain/building/building_cost_calculator.dart`

Add import:
```dart
import 'volcanic_kernel_costs.dart';
```

Update `upgradeCost()` — replace placeholder with:
```dart
BuildingType.volcanicKernel => volcanicKernelCost(currentLevel),
```

Update `maxLevel()` — ensure:
```dart
BuildingType.volcanicKernel => 10,
```

## Dependencies

- Task 3: `BuildingType.volcanicKernel` must exist
- Task 4: `build_runner` must have been run

## Test Plan

- **File**: `test/domain/building/volcanic_kernel_costs_test.dart`
- Test: `volcanicKernelCost(0)` returns `{coral: 50, ore: 40, energy: 30, pearl: 8}`
- Test: `volcanicKernelCost(9)` returns `{coral: 4100, ore: 3280, energy: 2460, pearl: 35}`
- Test: all pearl costs from level 0-9 are <= 100 (within max storage)
- **File**: `test/domain/building/building_cost_calculator_test.dart` (add tests)
- Test: `maxLevel(BuildingType.volcanicKernel)` returns 10
- Test: `upgradeCost(BuildingType.volcanicKernel, 0)` returns correct map
- Test: `upgradeCost(BuildingType.volcanicKernel, 10)` returns `{}` (max level reached)

# Task 06 — Remove productionPerLevel from BuildingCostCalculator

## Summary

Delete the static method `BuildingCostCalculator.productionPerLevel` and remove its tests. All production logic is now handled by the formula system.

## Implementation Steps

### 1. Edit `lib/domain/building_cost_calculator.dart`

Remove the `productionPerLevel` static method (lines 97–105):

```dart
// DELETE this entire method:
static MapEntry<ResourceType, int>? productionPerLevel(BuildingType type) {
  return switch (type) {
    BuildingType.headquarters => null,
    BuildingType.algaeFarm => MapEntry(ResourceType.algae, 5),
    BuildingType.coralMine => MapEntry(ResourceType.coral, 4),
    BuildingType.oreExtractor => MapEntry(ResourceType.ore, 3),
    BuildingType.solarPanel => MapEntry(ResourceType.energy, 3),
  };
}
```

Also remove the `resource_type.dart` import if it becomes unused (check if `upgradeCost` or `checkUpgrade` still reference `ResourceType` — they do, so **keep the import**).

### 2. Edit `test/domain/building_cost_calculator_prerequisites_test.dart`

Remove the entire `productionPerLevel` test group (lines 51–90) and the `resource_type.dart` import.

## Dependencies

- Task 03 (ProductionCalculator no longer imports `building_cost_calculator.dart`).

## Test Plan

- Run: `flutter analyze` — no references to `productionPerLevel` should remain in `lib/`.
- Run: `flutter test` — all tests pass.

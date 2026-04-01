# Task 03 — Update BuildingCostCalculator

## Summary

Change `checkUpgrade()` parameter from `List<Building>` to `Map<BuildingType, Building>` and simplify the lookup.

## Implementation steps

### Edit `lib/domain/building_cost_calculator.dart`

- Line 32: change `required List<Building> allBuildings,` → `required Map<BuildingType, Building> allBuildings,`
- Lines 50–51: simplify building lookup from:
  ```dart
  final building = allBuildings.where((b) => b.type == entry.key).firstOrNull;
  final currentBuildingLevel = building?.level ?? 0;
  ```
  to:
  ```dart
  final currentBuildingLevel = allBuildings[entry.key]?.level ?? 0;
  ```

## Dependencies

- Task 01 (uses the updated `Building` map type).

## Test plan

- No tests to run yet (tests updated in Task 04).
- Verify `flutter analyze` passes.

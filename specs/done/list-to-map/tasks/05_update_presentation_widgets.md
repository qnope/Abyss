# Task 05 — Update presentation widgets

## Summary

Update `BuildingListView`, `UpgradeSection`, and `BuildingDetailSheet` to accept `Map<BuildingType, Building>` instead of `List<Building>`.

## Implementation steps

### 1. Edit `lib/presentation/widgets/building_list_view.dart`

- Line 2: add `import '../../domain/building_type.dart';`
- Line 8: change `final List<Building> buildings;` → `final Map<BuildingType, Building> buildings;`
- Line 21: change `itemCount: buildings.length;` → `itemCount: buildings.length,` (unchanged)
- Lines 22–23: extract values for indexed access:
  ```dart
  itemBuilder: (context, index) {
    final building = buildings.values.elementAt(index);
  ```

### 2. Edit `lib/presentation/widgets/upgrade_section.dart`

- Line 15: change `final List<Building> allBuildings;` → `final Map<BuildingType, Building> allBuildings;`
- Lines 90–91: simplify prerequisite lookup from:
  ```dart
  final current = allBuildings.where((b) => b.type == type).firstOrNull?.level ?? 0;
  ```
  to:
  ```dart
  final current = allBuildings[type]?.level ?? 0;
  ```

### 3. Edit `lib/presentation/widgets/building_detail_sheet.dart`

- Line 2: add `import '../../domain/building_type.dart';`
- Line 14: change `required List<Building> allBuildings,` → `required Map<BuildingType, Building> allBuildings,`
- Line 32: change `final List<Building> allBuildings;` → `final Map<BuildingType, Building> allBuildings;`

### 4. No changes to `lib/presentation/screens/game_screen.dart`

`GameScreen` already passes `widget.game.buildings` as-is. The type flows through automatically.

## Dependencies

- Task 01 (Game model), Task 03 (BuildingCostCalculator).

## Test plan

- No tests to run yet (tests updated in Task 06).
- Verify `flutter analyze` passes.

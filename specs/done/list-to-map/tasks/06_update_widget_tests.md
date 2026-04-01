# Task 06 — Update widget tests

## Summary

Update widget test fixtures from `List<Building>` to `Map<BuildingType, Building>`.

## Implementation steps

### 1. Edit `test/presentation/widgets/building_list_view_test.dart`

- Line 5: add `import 'package:abyss/domain/building_type.dart';`
- Line 16: change `required List<Building> buildings,` → `required Map<BuildingType, Building> buildings,`
- Lines 32–34: change list to map:
  ```dart
  final buildings = {
    BuildingType.headquarters: Building(type: BuildingType.headquarters, level: 1),
  };
  ```
- Lines 43–45: same change
- Line 55: `tappedBuilding` comparison: `buildings.first` → `buildings[BuildingType.headquarters]`

### 2. Edit `test/presentation/widgets/building_detail_sheet_test.dart`

- Line 5: add `import 'package:abyss/domain/building_type.dart';`
- Line 26: change `allBuildings: [building]` → `allBuildings: {building.type: building}`

### 3. No changes to `test/presentation/screens/game_screen_test.dart`

This test creates a `Game` object directly, which now uses `Map` internally. No fixture changes needed.

## Dependencies

- Task 05 (widget APIs must be updated first).

## Test plan

- Run `flutter test test/presentation/` — all widget tests must pass.

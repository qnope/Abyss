# Task 01 — Update Game domain model

## Summary

Change the `buildings` field in `Game` from `List<Building>` to `Map<BuildingType, Building>` and regenerate the Hive adapter.

## Implementation steps

### 1. Edit `lib/domain/game.dart`

- Line 25: change `final List<Building> buildings;` → `final Map<BuildingType, Building> buildings;`
- Line 32: change constructor parameter `List<Building>? buildings,` → `Map<BuildingType, Building>? buildings,`
- Lines 72–76: change `defaultBuildings()` return type and body:

```dart
static Map<BuildingType, Building> defaultBuildings() {
  return {
    BuildingType.headquarters: Building(type: BuildingType.headquarters, level: 0),
  };
}
```

### 2. Regenerate Hive adapter

Run `dart run build_runner build --delete-conflicting-outputs` to regenerate `lib/domain/game.g.dart`. The generated `read()` will cast field 4 as `Map` instead of `List`.

## Dependencies

- None (this is the foundation task).

## Test plan

- No tests to run yet (tests updated in Task 02).
- Verify `flutter analyze` passes after this task.

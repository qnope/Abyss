# Task 06 — Wire Buildings into Game + Repository

## Summary

Add buildings to the `Game` model and register the new Hive adapters in `GameRepository`.

## Implementation Steps

### 1. Update `lib/domain/game.dart`

- Add a new HiveField for buildings:

```dart
@HiveField(4)
final List<Building> buildings;
```

- Update constructor:

```dart
Game({
  required this.player,
  this.turn = 1,
  DateTime? createdAt,
  Map<ResourceType, Resource>? resources,
  List<Building>? buildings,
})  : createdAt = createdAt ?? DateTime.now(),
      resources = resources ?? defaultResources(),
      buildings = buildings ?? defaultBuildings();
```

- Add `defaultBuildings()` static method:

```dart
static List<Building> defaultBuildings() {
  return [
    Building(type: BuildingType.headquarters, level: 0),
  ];
}
```

- Add import for `building.dart` and `building_type.dart`

### 2. Update `lib/data/game_repository.dart`

- Register new adapters **before** existing ones (dependencies first):

```dart
Hive.registerAdapter(BuildingTypeAdapter());
Hive.registerAdapter(BuildingAdapter());
```

- Add imports for `building.dart` and `building_type.dart`

### 3. Regenerate Game adapter

- Run: `dart run build_runner build --delete-conflicting-outputs`
- This regenerates `game.g.dart` with the new `buildings` field

## Files

| Action | Path |
|--------|------|
| Modify | `lib/domain/game.dart` — add `buildings` field + `defaultBuildings()` |
| Modify | `lib/data/game_repository.dart` — register BuildingType + Building adapters |
| Regenerated | `lib/domain/game.g.dart` |

## Dependencies

- Task 01 (BuildingType enum)
- Task 02 (Building model)
- Task 03 (generated adapters for Building and BuildingType)

## Test Plan

- Tested in task 07 (game_test.dart updates)

## Notes

- Adapter registration order matters: BuildingType → Building → ResourceType → Resource → Player → Game
- Existing saved games won't have `buildings` — Hive handles missing fields gracefully (returns null), and the constructor default handles it
- QG starts at level 0 (not built)

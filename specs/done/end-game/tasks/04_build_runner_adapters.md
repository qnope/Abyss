# Task 4: Run `build_runner` and register new Hive adapters

## Summary

Regenerate all Hive adapters after the model changes in tasks 1-3, and register the new adapters in `GameRepository`.

## Implementation Steps

### 1. Run `build_runner`

```bash
dart run build_runner build --delete-conflicting-outputs
```

This regenerates:
- `lib/domain/map/cell_content_type.g.dart` (new `volcanicKernel` field)
- `lib/domain/game/game_status.g.dart` (new file)
- `lib/domain/game/game.g.dart` (new `status` field)
- `lib/domain/building/building_type.g.dart` (new `volcanicKernel` field)

### 2. Edit `lib/data/game_repository.dart`

Add import:
```dart
import '../domain/game/game_status.dart';
```

Add adapter registration (after existing registrations):
```dart
Hive.registerAdapter(GameStatusAdapter());
```

### 3. Verify compilation

```bash
flutter analyze
```

## Dependencies

- Task 1: `CellContentType.volcanicKernel`
- Task 2: `GameStatus` enum + `Game.status`
- Task 3: `BuildingType.volcanicKernel`

## Test Plan

- Run `flutter test` to verify all existing tests still pass
- Run `flutter analyze` to verify no analysis errors

## Notes

- Only ONE new adapter needs registration: `GameStatusAdapter`. The existing adapters for `CellContentType`, `BuildingType`, and `Game` are already registered — `build_runner` just updates their `.g.dart` files.

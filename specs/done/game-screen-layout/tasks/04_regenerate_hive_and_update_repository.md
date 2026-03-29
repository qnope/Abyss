# Task 04: Regenerate Hive adapters and update data layer

## Summary

Run the Hive code generator to create adapters for `ResourceType` and `Resource`, register them in `GameRepository`, and ensure `NewGameScreen` works with the updated `Game` constructor.

## Implementation Steps

### Step 1: Run code generation

```bash
dart run build_runner build --delete-conflicting-outputs
```

This generates:
- `lib/domain/resource_type.g.dart`
- `lib/domain/resource.g.dart`
- Updates `lib/domain/game.g.dart` (new HiveField 3)

### Step 2: Update `lib/data/game_repository.dart`

Add the new adapter registrations **before** the existing ones (order matters for dependencies):

```dart
import '../domain/resource.dart';
import '../domain/resource_type.dart';

// In initialize():
static Future<void> initialize() async {
  await Hive.initFlutter();
  Hive.registerAdapter(ResourceTypeAdapter());  // NEW - typeId 2
  Hive.registerAdapter(ResourceAdapter());      // NEW - typeId 3
  Hive.registerAdapter(PlayerAdapter());
  Hive.registerAdapter(GameAdapter());
  await Hive.openBox<Game>(_boxName);
}
```

### Step 3: Verify NewGameScreen

`NewGameScreen` currently creates `Game(player: player)`. Since the constructor now defaults resources via `defaultResources()`, no changes are needed in `new_game_screen.dart`.

### Step 4: Verify tests

Run `flutter test` to ensure existing tests pass. The `game_test.dart` creates `Game(player: player)` which should now include default resources.

## Dependencies

- Task 01 (ResourceType with Hive annotations).
- Task 02 (Resource with Hive annotations).
- Task 03 (Game model updated).

## Test Plan

- Run `flutter test` — all existing tests should pass.
- Run `flutter analyze` — no analysis errors.

## Notes

- Adapter registration order: ResourceType before Resource (since Resource contains ResourceType).
- Player and Game adapters stay in their current order.
- If `build_runner` is not in `dev_dependencies`, add it: `dart pub add dev:build_runner dev:hive_generator`.

# Task 2: Add `GameStatus` enum and field on `Game`

## Summary

Create a `GameStatus` Hive enum to track the game's win/loss state, and add it as a field on the `Game` model.

## Implementation Steps

### 1. Create `lib/domain/game/game_status.dart`

```dart
import 'package:hive/hive.dart';

part 'game_status.g.dart';

@HiveType(typeId: 37)
enum GameStatus {
  @HiveField(0) playing,
  @HiveField(1) victory,
  @HiveField(2) defeat,
  @HiveField(3) freePlay,
}
```

- `playing`: normal gameplay
- `victory`: player won (volcanic kernel building reached level 10)
- `defeat`: rival won (deferred until AI players exist)
- `freePlay`: player chose to continue after victory, no further triggers

### 2. Edit `lib/domain/game/game.dart`

Add import:
```dart
import 'game_status.dart';
```

Add field:
```dart
@HiveField(5)
GameStatus status;
```

Update constructor — add `this.status = GameStatus.playing` as default parameter.

Update `Game.singlePlayer` factory to pass default status.

## Dependencies

- None (independent of tasks 1, 3)

## Test Plan

- **File**: `test/domain/game/game_status_test.dart`
- Verify `GameStatus.values` has 4 values
- Verify `Game()` defaults to `GameStatus.playing`
- Verify `Game.singlePlayer()` defaults to `GameStatus.playing`
- Verify status can be set to each value

## Notes

- Hive typeId 37 is the next available (existing range: 0-36)
- `build_runner` will be run in task 4

# Task 12: Create `VictoryChecker`

## Summary

Create a utility that checks whether the game has reached a victory or defeat state based on the volcanic kernel building level.

## Implementation Steps

### 1. Create `lib/domain/game/victory_checker.dart`

```dart
import 'package:abyss/domain/building/building_type.dart';
import 'game.dart';
import 'game_status.dart';

class VictoryChecker {
  static const int _winLevel = 10;

  /// Returns a new GameStatus if the game state should change, or null if no change.
  static GameStatus? check(Game game) {
    if (game.status == GameStatus.freePlay) return null;
    if (game.status != GameStatus.playing) return null;

    for (final player in game.players.values) {
      final kernelLevel = player.buildings[BuildingType.volcanicKernel]?.level ?? 0;
      if (kernelLevel >= _winLevel) {
        return player.id == game.humanPlayerId
            ? GameStatus.victory
            : GameStatus.defeat;
      }
    }
    return null;
  }
}
```

Logic:
- If game is in `freePlay` or already `victory`/`defeat` → no change (return null)
- If ANY player's volcanic kernel building is at level 10:
  - Human player → `victory`
  - Non-human player → `defeat` (deferred until AI exists, but logic is ready)
- Otherwise → null (no state change)

## Dependencies

- Task 2: `GameStatus` enum
- Task 3: `BuildingType.volcanicKernel`

## Test Plan

- **File**: `test/domain/game/victory_checker_test.dart`
- Test: returns `null` when no player has volcanic kernel at level 10
- Test: returns `GameStatus.victory` when human player's volcanic kernel is level 10
- Test: returns `GameStatus.defeat` when a non-human player's volcanic kernel is level 10
- Test: returns `null` when game status is `freePlay` (even if building is level 10)
- Test: returns `null` when game status is already `victory`
- Test: returns `null` when building is level 9 (not yet at 10)

## Notes

- The checker is intentionally stateless — it inspects the current game state and returns what the new status should be (or null)
- The caller (task 17) is responsible for setting `game.status`
- Defeat condition is spec'd (US-5) but deferred — the logic exists but no AI player will trigger it yet

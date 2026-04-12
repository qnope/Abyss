# Task 13: Create `GameStatisticsCalculator`

## Summary

Create a data class and calculator that computes end-game statistics from the game state and player history for display on the victory screen.

## Implementation Steps

### 1. Create `lib/domain/game/game_statistics.dart`

```dart
class GameStatistics {
  final int turnsPlayed;
  final int monstersDefeated;
  final int basesCaptured;
  final int totalResourcesCollected;

  const GameStatistics({
    required this.turnsPlayed,
    required this.monstersDefeated,
    required this.basesCaptured,
    required this.totalResourcesCollected,
  });
}
```

### 2. Create `lib/domain/game/game_statistics_calculator.dart`

```dart
import 'package:abyss/domain/history/history_entry.dart';
import 'game.dart';
import 'game_statistics.dart';

class GameStatisticsCalculator {
  static GameStatistics compute(Game game) {
    final player = game.humanPlayer;
    final entries = player.historyEntries;

    int monstersDefeated = 0;
    int basesCaptured = 0;
    int totalResources = 0;

    for (final entry in entries) {
      switch (entry) {
        case CombatEntry():
          if (entry.fightResult.isVictory) {
            monstersDefeated += entry.fightResult.initialMonsterCount;
          }
        case CaptureEntry():
          basesCaptured++;
        case CollectEntry():
          totalResources += entry.resources.values.fold(0, (a, b) => a + b);
        default:
          break;
      }
    }

    // Also sum current resource amounts as a proxy for total collected
    for (final resource in player.resources.values) {
      totalResources += resource.amount;
    }

    return GameStatistics(
      turnsPlayed: game.turn,
      monstersDefeated: monstersDefeated,
      basesCaptured: basesCaptured,
      totalResourcesCollected: totalResources,
    );
  }
}
```

### Statistics explained

- **Turns played**: `game.turn` (already tracked)
- **Monsters defeated**: count from `CombatEntry` victories in history (capped at 100 entries by FIFO, but captures the recent activity)
- **Bases captured**: count of `CaptureEntry` in history (failles + cheminees + volcanic kernel)
- **Total resources collected**: sum of `CollectEntry` resources + current player resources

## Dependencies

- None (uses existing history entries and game model)

## Test Plan

- **File**: `test/domain/game/game_statistics_calculator_test.dart`
- Test: empty history returns `turnsPlayed: game.turn, monstersDefeated: 0, basesCaptured: 0, totalResources: sum of initial resources`
- Test: with 3 CombatEntry victories → `monstersDefeated` counts initial monsters from each
- Test: with 2 CaptureEntry → `basesCaptured == 2`
- Test: with CollectEntry containing {coral: 50, ore: 30} → totalResources includes 80
- Test: defeated monsters from losing fights are NOT counted

## Notes

- History is capped at 100 entries (FIFO). For a very long game, early history may be lost. This is acceptable — the stats are a summary of recent and current state.
- `totalResourcesCollected` is an approximation (current stock + collected from history). An exact lifetime total would require a dedicated counter, which is out of scope.

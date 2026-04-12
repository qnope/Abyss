# Task 17: Wire victory check into building upgrade flow

## Summary

After a successful building upgrade, check if the game has been won and navigate to the victory screen if so.

## Implementation Steps

### 1. Edit `lib/presentation/screens/game/game_screen_actions.dart`

Add imports:
```dart
import '../../../domain/game/game_statistics_calculator.dart';
import '../../../domain/game/game_status.dart';
import '../../../domain/game/victory_checker.dart';
import 'victory_screen.dart';
import '../../screens/menu/main_menu_screen.dart';
```

Update `showBuildingDetailAction()`:

After the successful upgrade (`if (result.isSuccess)`), add victory check:

```dart
onUpgrade: () {
  final action = UpgradeBuildingAction(buildingType: building.type);
  final result = ActionExecutor().execute(action, game, human);
  if (result.isSuccess) {
    // Check for victory
    final newStatus = VictoryChecker.check(game);
    if (newStatus == GameStatus.victory) {
      game.status = GameStatus.victory;
      Navigator.pop(context); // close building sheet
      _showVictoryScreen(context, game, repository, onChanged);
      return;
    }
    onChanged();
    Navigator.pop(context);
  }
},
```

### 2. Add victory screen navigation helper

In the same file or a new helper:

```dart
void _showVictoryScreen(
  BuildContext context,
  Game game,
  GameRepository repository,
  VoidCallback onChanged,
) {
  final stats = GameStatisticsCalculator.compute(game);
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => VictoryScreen(
        statistics: stats,
        onContinue: () {
          game.status = GameStatus.freePlay;
          repository.save(game);
          Navigator.of(context).pop(); // pop victory screen
          onChanged();
        },
        onReturnToMenu: () {
          repository.save(game);
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute<void>(
              builder: (_) => MainMenuScreen(repository: repository)),
            (_) => false,
          );
        },
      ),
    ),
  );
}
```

### 3. Update `showBuildingDetailAction` signature

The function needs access to `repository` for saving. Add `GameRepository repository` parameter:

```dart
void showBuildingDetailAction(
  BuildContext context,
  Game game,
  GameRepository repository,
  Building building,
  VoidCallback onChanged,
)
```

### 4. Update caller in `game_screen.dart`

Pass `widget.repository` to `showBuildingDetailAction`:

```dart
onBuildingTap: (b) => showBuildingDetailAction(
  context, g, widget.repository, b, () => setState(() {})),
```

## Dependencies

- Task 12: `VictoryChecker`
- Task 13: `GameStatisticsCalculator`
- Task 16: `VictoryScreen`

## Test Plan

- **File**: `test/presentation/screens/game/game_screen_victory_test.dart`
- Test: upgrading a non-volcanic-kernel building does NOT trigger victory
- Test: upgrading volcanic kernel to level 9 does NOT trigger victory
- Test: upgrading volcanic kernel to level 10 triggers navigation to victory screen
- Test: choosing "continue" on victory screen sets `freePlay` status
- Test: choosing "return to menu" navigates to main menu

## Notes

- The victory check only runs after building upgrades, not during turn resolution. This is correct per the spec — victory happens when the building reaches level 10, which is a player action.
- The `repository` parameter addition to `showBuildingDetailAction` is a minor signature change. Update all callers.

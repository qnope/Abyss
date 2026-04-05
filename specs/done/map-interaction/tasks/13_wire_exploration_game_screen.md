# Task 13: Wire Exploration Action in Game Screen

## Summary

Connect the cell tap → bottom sheet → explore action flow in the game screen. Create a new helper file following the existing pattern of `game_screen_actions.dart`.

## Implementation Steps

### 1. Create `lib/presentation/screens/game/game_screen_exploration.dart`

New helper file (following the `game_screen_actions.dart` pattern):

```dart
import 'package:flutter/material.dart';
import '../../../domain/action/action_executor.dart';
import '../../../domain/action/explore_action.dart';
import '../../../domain/game/game.dart';
import '../../../domain/map/cell_eligibility_checker.dart';
import '../../../domain/map/reveal_area_calculator.dart';
import '../../../domain/tech/tech_branch.dart';
import '../../../domain/unit/unit_type.dart';
import '../../widgets/map/exploration_sheet.dart';

void showExplorationAction(
  BuildContext context,
  Game game,
  int x,
  int y,
  VoidCallback onChanged,
) {
  final scoutCount = game.units[UnitType.scout]?.count ?? 0;
  final explorerLevel =
      game.techBranches[TechBranch.explorer]?.researchLevel ?? 0;
  final isEligible =
      CellEligibilityChecker.isEligible(game.gameMap!, x, y);

  showExplorationSheet(
    context,
    targetX: x,
    targetY: y,
    scoutCount: scoutCount,
    explorerLevel: explorerLevel,
    isEligible: isEligible,
    onConfirm: () {
      final action = ExploreAction(targetX: x, targetY: y);
      final result = ActionExecutor().execute(action, game);
      if (result.isSuccess) {
        onChanged();
        Navigator.pop(context);
      }
    },
  );
}
```

### 2. Update `lib/presentation/screens/game/game_screen.dart`

Add import:
```dart
import 'game_screen_exploration.dart';
```

Implement the `_onMapCellTap` method (stubbed in Task 11):
```dart
void _onMapCellTap(int x, int y) {
  showExplorationAction(
    context, widget.game, x, y, () => setState(() {}),
  );
}
```

Also update `_buildMapTab` to save game after exploration:
```dart
void _onMapCellTap(int x, int y) {
  showExplorationAction(
    context,
    widget.game,
    x,
    y,
    () {
      widget.repository.save(widget.game);
      setState(() {});
    },
  );
}
```

## Dependencies

- Task 07 (ExploreAction)
- Task 11 (cell tap handler)
- Task 12 (exploration bottom sheet)

## Test Plan

No dedicated test — integration tested via manual testing. Domain logic is tested separately in Tasks 08, 04, 06.

## Notes

- Follows the exact pattern of `showBuildingDetailAction` and `showUnitDetailAction`
- Game is saved after successful exploration (persistence)
- `setState(() {})` triggers UI rebuild to show updated scout count and pending markers

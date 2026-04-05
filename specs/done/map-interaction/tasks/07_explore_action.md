# Task 07: ExploreAction

## Summary

Create the `ExploreAction` domain action that validates and executes a scout exploration order. Follows the existing Action pattern: validate checks eligibility and scout availability, execute consumes a scout and queues the exploration order.

## Implementation Steps

### 1. Add `explore` to `ActionType` enum

Update `lib/domain/action/action_type.dart`:
```dart
enum ActionType {
  upgradeBuilding,
  unlockBranch,
  researchTech,
  recruitUnit,
  explore,
}
```

### 2. Create `lib/domain/action/explore_action.dart`

```dart
import '../game/game.dart';
import '../map/cell_eligibility_checker.dart';
import '../map/exploration_order.dart';
import '../map/grid_position.dart';
import '../unit/unit_type.dart';
import 'action.dart';
import 'action_result.dart';
import 'action_type.dart';

class ExploreAction extends Action {
  final int targetX;
  final int targetY;

  ExploreAction({required this.targetX, required this.targetY});

  @override
  ActionType get type => ActionType.explore;

  @override
  String get description => 'Explorer ($targetX, $targetY)';

  @override
  ActionResult validate(Game game) {
    // Must have a map
    if (game.gameMap == null) {
      return const ActionResult.failure('Carte non générée');
    }

    // Must have scouts
    final scoutCount = game.units[UnitType.scout]?.count ?? 0;
    if (scoutCount <= 0) {
      return const ActionResult.failure('Aucun éclaireur disponible');
    }

    // Target cell must be eligible
    if (!CellEligibilityChecker.isEligible(
        game.gameMap!, targetX, targetY)) {
      return const ActionResult.failure('Cellule non éligible');
    }

    return const ActionResult.success();
  }

  @override
  ActionResult execute(Game game) {
    // Consume 1 scout
    game.units[UnitType.scout]!.count -= 1;

    // Queue exploration order
    game.pendingExplorations.add(
      ExplorationOrder(
        target: GridPosition(x: targetX, y: targetY),
      ),
    );

    return const ActionResult.success();
  }
}
```

## Key Validation Rules

1. **Map must exist** — `game.gameMap != null`
2. **Scout available** — `units[UnitType.scout].count > 0`
3. **Cell eligible** — delegates to `CellEligibilityChecker.isEligible()`

## Execution Effects

1. Decrements `units[UnitType.scout].count` by 1
2. Appends a new `ExplorationOrder` to `game.pendingExplorations`

## Dependencies

- Task 01 (ExplorationOrder model)
- Task 02 (pendingExplorations on Game)
- Task 05 (CellEligibilityChecker)
- Existing: `Action`, `ActionResult`, `ActionType`, `UnitType`

## Test Plan

- File: `test/domain/action/explore_action_test.dart` (Task 08)

## Notes

- Follows the exact same pattern as `RecruitUnitAction`, `UpgradeBuildingAction`
- French labels match existing convention (e.g., "Aucun éclaireur disponible")
- Scout consumption is immediate (not deferred to turn resolution)
- File should stay well under 150 lines

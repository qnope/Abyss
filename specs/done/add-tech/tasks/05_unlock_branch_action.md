# Task 05 — UnlockBranchAction

## Summary

Create an action that unlocks a tech branch, deducting resources and marking the branch as unlocked.

## Implementation Steps

### 1. Update `lib/domain/action_type.dart`

Add new values:
```dart
enum ActionType {
  upgradeBuilding,
  unlockBranch,
  researchTech,
}
```

### 2. Create `lib/domain/unlock_branch_action.dart`

```dart
class UnlockBranchAction extends Action {
  final TechBranch branch;

  UnlockBranchAction({required this.branch});

  @override
  ActionType get type => ActionType.unlockBranch;

  @override
  String get description => 'Debloquer branche $branch';

  @override
  ActionResult validate(Game game) {
    final state = game.techBranches[branch];
    if (state == null) {
      return ActionResult.failure('Branche introuvable');
    }
    if (state.unlocked) {
      return ActionResult.failure('Branche deja debloquee');
    }
    final labLevel = game.buildings[BuildingType.laboratory]?.level ?? 0;
    if (labLevel < 1) {
      return ActionResult.failure('Laboratoire requis');
    }
    final costs = TechCostCalculator.unlockCost(branch);
    for (final entry in costs.entries) {
      final available = game.resources[entry.key]?.amount ?? 0;
      if (available < entry.value) {
        return ActionResult.failure('Ressources insuffisantes');
      }
    }
    return ActionResult.success();
  }

  @override
  ActionResult execute(Game game) {
    final validation = validate(game);
    if (!validation.isSuccess) return validation;
    final costs = TechCostCalculator.unlockCost(branch);
    for (final entry in costs.entries) {
      game.resources[entry.key]!.amount -= entry.value;
    }
    game.techBranches[branch]!.unlocked = true;
    return ActionResult.success();
  }
}
```

## Files

| Action | Path |
|--------|------|
| Edit | `lib/domain/action_type.dart` |
| Create | `lib/domain/unlock_branch_action.dart` |

## Dependencies

- Task 01 (`TechBranch`).
- Task 03 (`Game.techBranches`).
- Task 04 (`TechCostCalculator.unlockCost`).

## Design Notes

- Follows the exact same validate-then-execute pattern as `UpgradeBuildingAction`.
- Defensive double validation in `execute()`.

## Test Plan

- **File:** `test/domain/unlock_branch_action_test.dart`
- Test `validate`: success, lab not built, branch already unlocked, insufficient resources.
- Test `execute`: resources deducted, branch marked unlocked; failure cases don't mutate.
- Covered in task 14.

# Task 06 — ResearchTechAction

## Summary

Create an action that researches the next tech node in a branch, deducting resources and incrementing `researchLevel`.

## Implementation Steps

### 1. Create `lib/domain/research_tech_action.dart`

```dart
class ResearchTechAction extends Action {
  final TechBranch branch;

  ResearchTechAction({required this.branch});

  @override
  ActionType get type => ActionType.researchTech;

  @override
  String get description => 'Rechercher tech $branch';

  @override
  ActionResult validate(Game game) {
    final state = game.techBranches[branch];
    if (state == null) {
      return ActionResult.failure('Branche introuvable');
    }
    if (!state.unlocked) {
      return ActionResult.failure('Branche verrouillee');
    }
    final targetLevel = state.researchLevel + 1;
    if (targetLevel > TechCostCalculator.maxResearchLevel) {
      return ActionResult.failure('Niveau maximum atteint');
    }
    final labLevel = game.buildings[BuildingType.laboratory]?.level ?? 0;
    if (labLevel < TechCostCalculator.requiredLabLevel(targetLevel)) {
      return ActionResult.failure('Niveau de laboratoire insuffisant');
    }
    final costs = TechCostCalculator.researchCost(branch, targetLevel);
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
    final targetLevel = game.techBranches[branch]!.researchLevel + 1;
    final costs = TechCostCalculator.researchCost(branch, targetLevel);
    for (final entry in costs.entries) {
      game.resources[entry.key]!.amount -= entry.value;
    }
    game.techBranches[branch]!.researchLevel = targetLevel;
    return ActionResult.success();
  }
}
```

## Files

| Action | Path |
|--------|------|
| Create | `lib/domain/research_tech_action.dart` |

## Dependencies

- Task 01 (`TechBranch`).
- Task 03 (`Game.techBranches`).
- Task 04 (`TechCostCalculator.researchCost`, `requiredLabLevel`, `maxResearchLevel`).
- Task 05 (ActionType already updated with `researchTech`).

## Design Notes

- Sequential research is enforced: `targetLevel = state.researchLevel + 1`. No skipping nodes.
- The action doesn't need a `level` parameter — it always researches the next available node.

## Test Plan

- **File:** `test/domain/research_tech_action_test.dart`
- Test `validate`: success, branch locked, max level reached, lab level too low, insufficient resources.
- Test `execute`: resources deducted, `researchLevel` incremented; failure cases don't mutate.
- Covered in task 14.

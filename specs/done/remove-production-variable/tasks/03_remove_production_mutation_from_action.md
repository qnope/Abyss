# Task 03 — Remove production mutation from UpgradeBuildingAction

## Summary

Remove the code in `UpgradeBuildingAction.execute()` that mutates `resource.productionPerTurn` after a building upgrade. Production is now computed dynamically.

## Implementation Steps

### Step 1: Edit `lib/domain/upgrade_building_action.dart`

Remove lines 50–53 in `execute()`:

```dart
// REMOVE these 3 lines:
final production = BuildingCostCalculator.productionPerLevel(buildingType);
if (production != null) {
  game.resources[production.key]!.productionPerTurn += production.value;
}
```

After edit, `execute()` should be:

```dart
@override
ActionResult execute(Game game) {
  final validation = validate(game);
  if (!validation.isSuccess) return validation;
  final costs = BuildingCostCalculator()
      .upgradeCost(buildingType, game.buildings[buildingType]!.level);
  for (final entry in costs.entries) {
    game.resources[entry.key]!.amount -= entry.value;
  }
  game.buildings[buildingType]!.level++;
  return ActionResult.success();
}
```

### Step 2: Clean unused import if needed

If `BuildingCostCalculator` is still used for `upgradeCost()` (it is), keep the import. No import cleanup needed.

## Dependencies

- Task 02 (productionPerTurn field removed from Resource)

## Test Plan

- Existing tests in `test/domain/upgrade_building_action_production_test.dart` will be updated in Task 07.

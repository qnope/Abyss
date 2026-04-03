# Task 03 — Update UpgradeBuildingAction (Production Bonus)

## Summary
After upgrading a production building, update the associated resource's `productionPerTurn`.

## Implementation Steps

### 1. Edit `lib/domain/upgrade_building_action.dart`

In the `execute()` method, after `game.buildings[buildingType]!.level++`, add:

```dart
final production = BuildingCostCalculator.productionPerLevel(buildingType);
if (production != null) {
  game.resources[production.key]!.productionPerTurn += production.value;
}
```

The full execute method becomes:
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
  final production = BuildingCostCalculator.productionPerLevel(buildingType);
  if (production != null) {
    game.resources[production.key]!.productionPerTurn += production.value;
  }
  return ActionResult.success();
}
```

## Dependencies
- Task 01 (BuildingType enum values)
- Task 02 (BuildingCostCalculator.productionPerLevel)

## Test Plan
- Tested in Task 08.

## Notes
- For HQ, `productionPerLevel` returns `null`, so existing HQ upgrades are unaffected.
- Each upgrade adds exactly `base` to `productionPerTurn` (e.g., algaeFarm adds +5 per upgrade).
- `productionPerTurn` is mutable on `Resource`, so this mutation is safe.

# Task 08 — Refactor GameScreen to use ActionExecutor

## Summary

Replace the inline upgrade logic in `GameScreen._upgradeBuilding()` with the new `ActionExecutor` + `UpgradeBuildingAction` pattern. This is the key integration point that connects the new domain action system to the UI.

## Implementation Steps

1. Open `lib/presentation/screens/game_screen.dart`
2. Add imports:
   ```dart
   import '../../domain/action_executor.dart';
   import '../../domain/upgrade_building_action.dart';
   ```
3. Remove import of `building_cost_calculator.dart` (no longer needed directly)
4. Replace `_upgradeBuilding()` method body:

   **Before** (current):
   ```dart
   void _upgradeBuilding(Building building) {
     final calculator = BuildingCostCalculator();
     final costs = calculator.upgradeCost(building.type, building.level);
     setState(() {
       for (final entry in costs.entries) {
         widget.game.resources[entry.key]!.amount -= entry.value;
       }
       building.level++;
     });
     Navigator.pop(context);
   }
   ```

   **After** (new):
   ```dart
   void _upgradeBuilding(Building building) {
     final action = UpgradeBuildingAction(buildingType: building.type);
     final result = ActionExecutor().execute(action, widget.game);
     if (result.isSuccess) {
       setState(() {});
       Navigator.pop(context);
     }
   }
   ```

5. Note: `setState(() {})` with empty body is needed to trigger a rebuild after the executor mutated the game. The mutation happens inside `action.execute()`.

## Dependencies

- Task 04 (`UpgradeBuildingAction`)
- Task 06 (`ActionExecutor`)

## Test Plan

- Existing test `game_screen_test.dart` → 'upgrade increases building level' must still pass.
- See Task 09 for full verification.

## Notes

- The `UpgradeSection` widget and `BuildingDetailSheet` do NOT change — they still use `BuildingCostCalculator.checkUpgrade()` directly for display purposes.
- The `BuildingCostCalculator` import can be removed from `game_screen.dart` since it's no longer used there directly.
- Keep file under 150 lines (currently 124 lines, no growth expected).

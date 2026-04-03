# Task 04 — Create UpgradeBuildingAction

## Summary

Create the first concrete `Action` implementation: `UpgradeBuildingAction`. It encapsulates the intent to upgrade a building, delegates validation to `BuildingCostCalculator`, and applies resource deduction + level increment on execution.

## Implementation Steps

1. Create `lib/domain/upgrade_building_action.dart`
2. Define class:
   ```dart
   class UpgradeBuildingAction extends Action {
     final BuildingType buildingType;

     UpgradeBuildingAction({required this.buildingType});

     @override
     ActionType get type => ActionType.upgradeBuilding;

     @override
     String get description => 'Ameliorer $buildingType';
   }
   ```
3. Implement `validate(Game game)`:
   - Get the building from `game.buildings[buildingType]`
   - If building is null, return `ActionResult.failure('Batiment introuvable')`
   - Call `BuildingCostCalculator().checkUpgrade(...)` with building's current level, game resources, game buildings
   - If `check.isMaxLevel`, return `ActionResult.failure('Niveau maximum atteint')`
   - If `!check.canUpgrade`, return `ActionResult.failure(...)` with details about missing resources/prerequisites
   - Otherwise return `ActionResult.success()`
4. Implement `execute(Game game)`:
   - Call `validate(game)` first
   - If validation fails, return the failure result (game untouched)
   - If validation succeeds:
     - Calculate costs via `BuildingCostCalculator().upgradeCost(buildingType, building.level)`
     - Deduct each cost from `game.resources[type]!.amount`
     - Increment `building.level++`
     - Return `ActionResult.success()`

## Dependencies

- Task 01 (`ActionType`)
- Task 02 (`ActionResult`)
- Task 03 (`Action` abstract class)
- Existing: `BuildingType` (`lib/domain/building_type.dart`)
- Existing: `BuildingCostCalculator` (`lib/domain/building_cost_calculator.dart`)
- Existing: `Game` (`lib/domain/game.dart`)

## Test Plan

- See Task 05

## Notes

- This moves the upgrade logic from `GameScreen._upgradeBuilding()` into the domain layer.
- `BuildingCostCalculator` is instantiated inside the action (stateless, no DI needed).
- Keep file under 50 lines.

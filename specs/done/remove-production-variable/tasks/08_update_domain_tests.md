# Task 08 — Update domain tests

## Summary

Update `resource_test.dart` and `upgrade_building_action_production_test.dart` to remove all references to `productionPerTurn`.

## Implementation Steps

### Step 1: Edit `test/domain/resource_test.dart`

Remove or rewrite tests that reference `productionPerTurn`:

- **Remove** test `'defaults: productionPerTurn=0, maxStorage=500'` (lines 13–17) — rewrite as `'defaults: maxStorage=500'` checking only `maxStorage`.
- **Remove** test `'accepts custom productionPerTurn and maxStorage'` (lines 19–28) — rewrite as `'accepts custom maxStorage'` checking only `maxStorage`.
- **Keep** test `'creates with required fields'` and `'amount is mutable'` unchanged.

### Step 2: Edit `test/domain/upgrade_building_action_production_test.dart`

**In `makeProductionGame()` helper** (lines 20–45):
- Remove all `productionPerTurn:` lines (lines 24, 29, 34, 39).

**Remove or rewrite these tests:**

1. `'execute algaeFarm updates productionPerTurn'` (lines 103–113) — **Replace** with a test that verifies production via `ProductionCalculator`:
   ```dart
   test('execute algaeFarm increases production via calculator', () {
     final game = makeProductionGame();
     final action = UpgradeBuildingAction(buildingType: BuildingType.algaeFarm);
     action.execute(game);
     final production = ProductionCalculator.fromBuildings(game.buildings);
     expect(production[ResourceType.algae], 5);
   });
   ```

2. `'execute algaeFarm twice updates productionPerTurn cumulatively'` (lines 115–126) — **Replace**:
   ```dart
   test('execute algaeFarm twice cumulates production', () {
     final game = makeProductionGame(hqLevel: 2);
     final action = UpgradeBuildingAction(buildingType: BuildingType.algaeFarm);
     action.execute(game);
     action.execute(game);
     final production = ProductionCalculator.fromBuildings(game.buildings);
     expect(production[ResourceType.algae], 10);
   });
   ```

3. `'execute HQ does not change any productionPerTurn'` (lines 128–138) — **Replace**:
   ```dart
   test('execute HQ does not affect production', () {
     final game = makeProductionGame();
     final before = ProductionCalculator.fromBuildings(game.buildings);
     final action = UpgradeBuildingAction(buildingType: BuildingType.headquarters);
     action.execute(game);
     final after = ProductionCalculator.fromBuildings(game.buildings);
     expect(after, equals(before));
   });
   ```

Add import at top:
```dart
import 'package:abyss/domain/production_calculator.dart';
```

## Dependencies

- Task 01 (ProductionCalculator exists)
- Task 02 (productionPerTurn removed from Resource)
- Task 03 (mutation removed from action)

## Test Plan

- `flutter test test/domain/resource_test.dart`
- `flutter test test/domain/upgrade_building_action_production_test.dart`

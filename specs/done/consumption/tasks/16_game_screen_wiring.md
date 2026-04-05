# Task 16: Wire GameScreen to Pass Consumption Data

## Summary

Update `GameScreen` to compute consumption and pass it to `ResourceBar`, `TurnConfirmationDialog`, and `TurnSummaryDialog`.

## Implementation Steps

### 1. Update `lib/presentation/screens/game_screen.dart`

**In `build()` method** — compute consumption alongside production:
```dart
final production = ProductionCalculator.fromBuildings(
  widget.game.buildings,
  techBranches: widget.game.techBranches,
);
final consumption = <ResourceType, int>{};
final energyConsumption = ConsumptionCalculator.totalBuildingConsumption(
  widget.game.buildings,
);
if (energyConsumption > 0) {
  consumption[ResourceType.energy] = energyConsumption;
}
final algaeConsumption = ConsumptionCalculator.totalUnitConsumption(
  widget.game.units,
);
if (algaeConsumption > 0) {
  consumption[ResourceType.algae] = algaeConsumption;
}
```

Pass to `ResourceBar`:
```dart
ResourceBar(
  resources: widget.game.resources,
  production: production,
  consumption: consumption,  // NEW
)
```

**In `_nextTurn()` method** — compute warnings for confirmation dialog:
```dart
// Calculate what will happen
final energyProd = production[ResourceType.energy] ?? 0;
final energyStock = widget.game.resources[ResourceType.energy]?.amount ?? 0;
final buildingsToDeactivate = BuildingDeactivator.deactivate(
  buildings: widget.game.buildings,
  energyProduction: energyProd,
  energyStock: energyStock,
);

// Calculate algae situation (with potentially deactivated buildings)
final activeBuildings = Map.of(widget.game.buildings);
for (final type in buildingsToDeactivate) {
  activeBuildings[type] = Building(type: type, level: 0);
}
final adjustedProd = ProductionCalculator.fromBuildings(
  activeBuildings, techBranches: widget.game.techBranches,
);
final algaeProd = adjustedProd[ResourceType.algae] ?? 0;
final algaeStock = widget.game.resources[ResourceType.algae]?.amount ?? 0;
final unitsToLose = UnitLossCalculator.calculateLosses(
  units: widget.game.units,
  algaeProduction: algaeProd,
  algaeStock: algaeStock,
);

final confirmed = await showTurnConfirmationDialog(
  context,
  production: production,
  consumption: consumption,
  buildingsToDeactivate: buildingsToDeactivate,
  unitsToLose: unitsToLose,
);
```

### 2. Imports to add
```dart
import '../../domain/consumption_calculator.dart';
import '../../domain/building_deactivator.dart';
import '../../domain/unit_loss_calculator.dart';
import '../../domain/resource_type.dart';
```

## Dependencies

- Task 1 (ConsumptionCalculator)
- Task 5 (BuildingDeactivator)
- Task 7 (UnitLossCalculator)
- Task 11 (ResourceBar accepts consumption)
- Task 13 (TurnConfirmationDialog accepts warnings)

## Test Plan

- File: `test/presentation/screens/game_screen_test.dart` (update existing)
- See Task 17

## Notes

- The `_nextTurn` method already computes production. Adding consumption calculation increases its complexity. Consider extracting a helper if the method grows too long.
- GameScreen is at 164 lines already (just over 150). May need to extract `_nextTurn` logic into a separate file (e.g., `game_screen_turn_actions.dart`) following the existing pattern of `game_screen_tech_actions.dart`.

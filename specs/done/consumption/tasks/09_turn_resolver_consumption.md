# Task 9: Integrate Consumption into TurnResolver

## Summary

Update `TurnResolver.resolve()` to apply the full consumption flow: building deactivation, production with active buildings, algae consumption, unit losses, and resource updates.

## Implementation Steps

### 1. Update `lib/domain/turn_resolver.dart`

New resolve flow:

```
resolve(Game game) → TurnResult:
  1. Calculate full production (all buildings active)
  2. Calculate total energy consumption
  3. Determine available energy = production[energy] + stock[energy]
  4. Run BuildingDeactivator.deactivate() → deactivatedBuildings
  5. If buildings were deactivated:
     - Recalculate production excluding deactivated buildings
  6. Calculate total algae consumption of all units
  7. Determine available algae = production[algae] + stock[algae]
  8. Run UnitLossCalculator.calculateLosses() → lostUnits
  9. Apply unit losses: subtract from game.units[type].count
  10. Recalculate algae consumption after losses
  11. Apply resource changes for each resource type:
      - For energy: net = production - consumption, apply to stock
      - For algae: net = production - consumption, apply to stock
      - For others: net = production, apply to stock
      - Cap at maxStorage, floor at 0
  12. Clear recruitedUnitTypes
  13. Increment turn
  14. Return TurnResult with changes, deactivatedBuildings, lostUnits
```

**Key details for resource application (step 11):**
- `netChange = produced - consumed`
- `newAmount = resource.amount + netChange`
- If `newAmount < 0`: set to 0 (shouldn't happen after deactivation/loss logic, but safety)
- If `newAmount > maxStorage`: set to maxStorage, mark wasCapped
- TurnResourceChange includes both `produced` and `consumed`

### 2. Handle ProductionCalculator with exclusions

`ProductionCalculator.fromBuildings` already accepts a `Map<BuildingType, Building>`. To exclude deactivated buildings, create a filtered copy of the buildings map where deactivated buildings have level set to 0, OR filter the map to exclude deactivated types.

Simpler approach: create a filtered buildings map:
```dart
final activeBuildings = Map.of(game.buildings);
for (final type in deactivatedBuildings) {
  activeBuildings[type] = Building(type: type, level: 0);
}
final production = ProductionCalculator.fromBuildings(activeBuildings, ...);
```

## Dependencies

- Task 1 (ConsumptionCalculator)
- Task 3 (TurnResult updated)
- Task 5 (BuildingDeactivator)
- Task 7 (UnitLossCalculator)

## Test Plan

- File: `test/domain/turn_resolver_test.dart` (extend existing)
- See Task 10

## Notes

- This is the most complex task — the resolve method will grow but should stay under 80 lines
- Ensure all existing tests still pass (they test production-only scenarios where consumption is 0 by default since all buildings are at level 0 or only one building is active with minimal consumption)
- Important: existing tests may need minor adjustments if they use buildings that now consume energy. Review test setup to ensure energy stock/production covers consumption.

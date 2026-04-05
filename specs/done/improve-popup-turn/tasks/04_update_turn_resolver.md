# Task 4: Update TurnResolver for before/after tracking and maintenance

## Summary

Update `TurnResolver.resolve()` to snapshot before-values, deduct maintenance costs, compute net production, and populate all new `TurnResult` fields.

## Implementation Steps

### 1. Update `TurnResolver.resolve()`

**File**: `lib/domain/turn_resolver.dart`

New logic:

```dart
import 'maintenance_calculator.dart';

class TurnResolver {
  TurnResult resolve(Game game) {
    final previousTurn = game.turn;
    final hadRecruitedUnits = game.recruitedUnitTypes.isNotEmpty;

    final production = ProductionCalculator.fromBuildings(
      game.buildings, techBranches: game.techBranches,
    );
    final maintenance = MaintenanceCalculator.fromUnits(game.units);

    // Compute net production per resource
    final allTypes = <ResourceType>{...production.keys, ...maintenance.keys};
    final changes = <TurnResourceChange>[];

    for (final type in allTypes) {
      final resource = game.resources[type];
      if (resource == null) continue;

      final prod = production[type] ?? 0;
      final maint = maintenance[type] ?? 0;
      final net = prod - maint;

      final beforeAmount = resource.amount;
      final newAmount = resource.amount + net;
      final capped = newAmount > resource.maxStorage;
      // Don't go below 0
      resource.amount = capped
          ? resource.maxStorage
          : (newAmount < 0 ? 0 : newAmount);

      changes.add(TurnResourceChange(
        type: type,
        produced: net,
        wasCapped: capped,
        beforeAmount: beforeAmount,
        afterAmount: resource.amount,
      ));
    }

    game.recruitedUnitTypes.clear();
    game.turn++;

    return TurnResult(
      changes: changes,
      previousTurn: previousTurn,
      newTurn: game.turn,
      hadRecruitedUnits: hadRecruitedUnits,
    );
  }
}
```

### 2. Update existing tests

**File**: `test/domain/turn_resolver_test.dart`

Update all existing tests to verify new fields:

- **Production tests**: verify `beforeAmount` and `afterAmount` are correct
  - `single building produces correctly`: beforeAmount=100, afterAmount=240, produced=140
  - `multiple buildings produce correctly`: check both resources
- **Capping tests**: verify `afterAmount` equals `maxStorage` when capped
  - `resource capped at maxStorage`: beforeAmount=498, afterAmount=500
  - `already at max`: beforeAmount=500, afterAmount=500
- **Edge cases**: verify `previousTurn` and `newTurn`
  - `no production buildings returns empty changes`: previousTurn=1, newTurn=2
- **Recruitment reset**: verify `hadRecruitedUnits`
  - `recruitedUnitTypes is cleared`: hadRecruitedUnits=true
  - `empty recruitedUnitTypes`: hadRecruitedUnits=false

### 3. Add new tests for maintenance

**File**: `test/domain/turn_resolver_test.dart`

Add a new `group('Maintenance deduction', ...)`:

- `maintenance reduces net production` — game with algae farm level 1 (produces 50) + 10 scouts (maintenance 10) → net should be 40
- `maintenance exceeding production floors at zero` — game with no production + 100 scouts → algae goes to max(0, current - 100)
- `maintenance only affects resources with costs` — coral/ore/energy unchanged when only algae maintenance exists
- `net production shown in changes` — verify `change.produced` is net (production - maintenance)

### 4. Add tests for turn tracking

Add to existing groups or new `group('Turn tracking', ...)`:

- `previousTurn and newTurn are correct` — start at turn 5, verify previousTurn=5, newTurn=6
- `hadRecruitedUnits true when units were recruited` — add to recruitedUnitTypes before resolve
- `hadRecruitedUnits false when no recruitment` — empty recruitedUnitTypes

## Dependencies

- **Task 1**: `UnitCostCalculator.maintenanceCost()` must exist
- **Task 2**: `MaintenanceCalculator.fromUnits()` must exist
- **Task 3**: Updated `TurnResourceChange` and `TurnResult` models must exist

## Test Plan

- **File**: `test/domain/turn_resolver_test.dart`
- Run: `flutter test test/domain/turn_resolver_test.dart`
- Verify all existing tests pass (with updated assertions)
- Verify new maintenance and tracking tests pass
- Run: `flutter analyze`

## Notes

- Resource amount cannot go below 0 (floor at 0) when maintenance exceeds production + current amount
- `produced` field now represents net production (can be negative if maintenance > production)
- The `allTypes` set ensures we create changes for resources affected by maintenance even if they have no building production
- Pearl is still untouched (no production formula, no maintenance)

# Task 02 — Create TurnResolver

## Summary

Create `TurnResolver`, a stateless class that resolves a turn: computes production via `ProductionCalculator`, applies it to resources (capped at `maxStorage`), increments the turn counter, and returns a `TurnResult` describing what happened.

## Implementation Steps

1. Create `lib/domain/turn_resolver.dart`
2. Implement:
   ```dart
   import 'game.dart';
   import 'production_calculator.dart';
   import 'turn_result.dart';

   class TurnResolver {
     TurnResult resolve(Game game) {
       final production = ProductionCalculator.fromBuildings(game.buildings);
       final changes = <TurnResourceChange>[];

       for (final entry in production.entries) {
         final resource = game.resources[entry.key];
         if (resource == null) continue;

         final produced = entry.value;
         final newAmount = resource.amount + produced;
         final capped = newAmount > resource.maxStorage;
         resource.amount = capped ? resource.maxStorage : newAmount;

         changes.add(TurnResourceChange(
           type: entry.key,
           produced: produced,
           wasCapped: capped,
         ));
       }

       game.turn++;
       return TurnResult(changes: changes);
     }
   }
   ```

## Dependencies

- Task 01 (`TurnResult`, `TurnResourceChange`)
- Existing: `Game`, `ProductionCalculator`, `Resource`, `ResourceType`

## Test Plan

- No dedicated tests in this task — see task 03.

## Notes

- Pearls are naturally excluded because `ProductionCalculator` never produces pearl entries.
- The resolver **mutates** the `Game` object in place (same pattern as `UpgradeBuildingAction.execute`).
- The resolver does NOT save — saving is the caller's responsibility (US-03).
- Keep file under 30 lines.

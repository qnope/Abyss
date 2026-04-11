# Task 17: Update TurnResolver for Reinforcement Transit

## Summary
Extend `TurnResolver` to resolve pending `ReinforcementOrder`s. After 1 turn of transit, units arrive on the target level.

## Implementation Steps

1. **Update TurnResolver.resolve** in `lib/domain/turn/turn_resolver.dart`:
   - After existing resolution steps (production, consumption, exploration), add:
   - **Resolve reinforcements**:
     ```dart
     final arrivedReinforcements = <ReinforcementOrder>[];
     for (final order in player.pendingReinforcements) {
       if (order.isReadyToArrive(game.turn)) {
         // Add units to target level
         final targetUnits = player.unitsOnLevel(order.toLevel);
         for (final entry in order.units.entries) {
           final existing = targetUnits[entry.key];
           if (existing != null) {
             existing.count += entry.value;
           } else {
             targetUnits[entry.key] = Unit(type: entry.key, count: entry.value);
           }
         }
         arrivedReinforcements.add(order);
       }
     }
     player.pendingReinforcements.removeWhere(arrivedReinforcements.contains);
     ```

2. **Update TurnResult** in `lib/domain/turn/turn_result.dart`:
   - Add `final List<ReinforcementOrder> arrivedReinforcements` field
   - Hive field for persistence

3. **Ensure unit map initialization**:
   - If `player.unitsPerLevel[toLevel]` doesn't exist, create it before adding units

## Dependencies
- **Internal**: Task 10 (ReinforcementOrder), Task 02 (Player.unitsPerLevel), Task 04 (TurnResolver already updated)
- **External**: None

## Test Plan
- **File**: `test/domain/turn/turn_resolver_test.dart`
  - Verify reinforcements sent on turn N arrive at start of turn N+2 (after end-turn N+1)
  - Verify arrived units are added to target level
  - Verify pending reinforcements list is cleared after arrival
  - Verify non-arrived reinforcements remain in pending list
  - Verify units are unavailable on both levels during transit
- Run `flutter analyze` and `flutter test`

## Notes
- Reinforcements depart when the action is executed (units removed from source level immediately).
- They arrive when `game.turn > order.departTurn`, meaning after the next end-of-turn resolution.
- During transit, units are not counted in consumption (they're not in any level's unit map).

# Task 10: Add ReinforcementOrder Model

## Summary
Create `ReinforcementOrder` model to track units in transit between levels. Units spend 1 turn in transit before arriving on the target level.

## Implementation Steps

1. **Create ReinforcementOrder class** in `lib/domain/map/reinforcement_order.dart`:
   ```dart
   @HiveType(typeId: 33)
   class ReinforcementOrder {
     @HiveField(0) final int fromLevel;
     @HiveField(1) final int toLevel;
     @HiveField(2) final Map<UnitType, int> units;  // type → count
     @HiveField(3) final int departTurn;             // turn when sent
     @HiveField(4) final GridPosition arrivalPoint;  // spawn on target level
   }
   ```
   - Add `bool isReadyToArrive(int currentTurn) => currentTurn > departTurn`

2. **Add to Player** in `lib/domain/game/player.dart`:
   - `@HiveField(13) final List<ReinforcementOrder> pendingReinforcements`
   - Initialize to empty list in constructor

3. **Regenerate Hive adapters**

## Dependencies
- **Internal**: Task 02 (Player model updated)
- **External**: None

## Test Plan
- **File**: `test/domain/map/reinforcement_order_test.dart`
  - Verify construction with all fields
  - Verify `isReadyToArrive(departTurn)` returns false
  - Verify `isReadyToArrive(departTurn + 1)` returns true
- Run `flutter analyze`

## Notes
- Hive typeId: 33
- During transit, units are removed from the source level (Task 17: SendReinforcementsAction) and not yet on the target level. They exist only in the `ReinforcementOrder`.
- The arrival point is the transition base's position on the target level (center of map for initial descent).

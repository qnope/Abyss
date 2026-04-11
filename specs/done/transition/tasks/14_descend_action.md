# Task 14: Create DescendAction

## Summary
New action to send units through a captured transition base to the next level. Generates the target level map on first descent. Units are transferred permanently (one-way).

## Implementation Steps

1. **Create DescendAction** in `lib/domain/action/descend_action.dart`:
   ```dart
   class DescendAction extends Action {
     final int transitionX;    // position of captured faille
     final int transitionY;
     final int fromLevel;
     final Map<UnitType, int> selectedUnits;

     ActionType get type => ActionType.descend;
   }
   ```

2. **Validate**:
   - Cell at (transitionX, transitionY) on `game.levels[fromLevel]` has a captured transition base owned by player
   - `selectedUnits` is not empty
   - Player has sufficient units on `fromLevel` for all selected types
   - Player has required building: `descentModule` for faille (from Level 1), `pressureCapsule` for cheminee (from Level 2)
   - Target level (faille → 2, cheminee → 3) does not already have a map? No — multiple descents are fine, map is generated once.

3. **Execute**:
   - Determine target level from transition base type
   - **If `game.levels[targetLevel]` is null**: generate new map via `MapGenerator.generate(level: targetLevel)`
     - Store in `game.levels[targetLevel]`
     - Initialize `player.unitsPerLevel[targetLevel]` with empty map
     - Initialize `player.revealedCellsPerLevel[targetLevel]` with initial reveal around spawn point
   - **Transfer units**: subtract from `player.unitsOnLevel(fromLevel)`, add to `player.unitsOnLevel(targetLevel)`
   - **Spawn point**: center of target map (from `MapGenerationResult.baseX/baseY`)

4. **Return DescendResult** with target level and units sent

## Dependencies
- **Internal**: Task 07 (TransitionBase), Task 06 (Game.levels), Task 02 (Player.unitsPerLevel), Task 12 (MapGenerator with level)
- **External**: MapGenerator (existing)

## Test Plan
- **File**: `test/domain/action/descend_action_test.dart`
  - Verify validation fails if transition base not captured
  - Verify validation fails if no units selected
  - Verify validation fails without required building
  - Verify first descent generates Level 2 map
  - Verify units transferred from Level 1 to Level 2
  - Verify Level 1 unit count decremented
  - Verify second descent reuses existing Level 2 map
  - Verify Level 2 revealed cells initialized
- Run `flutter analyze`

## Notes
- Descent is resolved immediately (not at end of turn). Units appear on the target level right away.
- The spawn point doubles as the player's "base" on the new level for fog-of-war initialization.

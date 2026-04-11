# Task 03: Update Domain Actions for unitsPerLevel

## Summary
Update all action classes that reference `player.units` to use `player.unitsOnLevel(level)` or `player.unitsPerLevel`. Recruitment targets Level 1. Combat uses the level where the fight happens.

## Implementation Steps

1. **RecruitUnitAction** (`lib/domain/action/recruit_unit_action.dart`):
   - Replace `player.units[unitType]` → `player.unitsOnLevel(1)[unitType]`
   - Recruited units go to Level 1 (where base/barracks is)

2. **FightMonsterAction** (`lib/domain/action/fight_monster_action.dart`):
   - Replace `player.units` → `player.unitsOnLevel(1)` (monster fights happen on the map the player is viewing)
   - Note: The level parameter will need to be added later when multi-level combat is wired in. For now, default to Level 1.
   - Update casualty application: modify units on the correct level

3. **ExploreAction** (`lib/domain/action/explore_action.dart`):
   - If it references `player.units` for scout count → `player.unitsOnLevel(1)` (scouts explore from Level 1 initially)

4. **EndTurnAction** (`lib/domain/action/end_turn_action.dart`):
   - If it delegates to TurnResolver, no changes needed here (TurnResolver updated in Task 04)

5. **Any other action** referencing `player.units` — search with `grep -r "player.units" lib/domain/action/`

## Dependencies
- **Internal**: Task 02 (Player model changed)
- **External**: None

## Test Plan
- **File**: `test/domain/action/recruit_unit_action_test.dart`
  - Verify recruitment adds units to Level 1
- **File**: `test/domain/action/fight_monster_action_test.dart`
  - Verify combat reads/modifies Level 1 units
- Run `flutter analyze` and `flutter test`

## Notes
- Multi-level combat (fighting on Level 2) will be handled by AttackTransitionBaseAction and future fight actions that take a `level` parameter.

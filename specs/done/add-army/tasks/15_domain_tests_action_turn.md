# Task 15: Domain Tests — RecruitUnitAction and TurnResolver

## Summary

Write unit tests for the recruitment action and verify that TurnResolver resets recruitment flags.

## Implementation Steps

### 1. Create `test/domain/recruit_unit_action_test.dart`

Helper: `_createGame({int algae, int coral, int ore, int energy, int pearl, int barracksLevel, List<UnitType> recruited})`

- group 'validate':
  - Success: barracks 1, enough resources, scout not recruited → success
  - Locked unit: barracks 0 → failure 'Unite verrouilee'
  - Already recruited this type: recruitedUnitTypes contains scout → failure
  - Insufficient resources: only 5 algae for scout (needs 10) → failure
  - Zero quantity → failure 'Quantite invalide'
  - Guardian at barracks 2 → failure (needs 3)

- group 'execute':
  - Deducts resources: recruit 1 scout → algae -10, coral -5
  - Adds units: recruit 3 scouts → unit count +3
  - Marks recruited: after recruiting scout, recruitedUnitTypes contains scout
  - Multiple types: recruit scout then harpoonist → both succeed
  - Same type twice: recruit scout, then recruit scout again → second fails

- group 'via ActionExecutor':
  - Executor validates then executes correctly

### 2. Update `test/domain/turn_resolver_test.dart`

Add to existing test file:

- group 'recruitment reset':
  - `recruitedUnitTypes` with [scout, harpoonist] → after resolve → empty list
  - `recruitedUnitTypes` empty → after resolve → still empty (no crash)

## Dependencies

- Tasks 04, 05, 06 (Game changes, RecruitUnitAction, TurnResolver update)

## Test Plan

This IS the test task. Files listed above.

## Notes

- Create helper `_createGame()` with sensible defaults (barracks level 1, 100 of each resource).
- For TurnResolver test, add to existing file — don't create a new one.

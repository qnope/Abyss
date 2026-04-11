# Task 29: Tests — Boss Combat and Capture Logic

## Summary
Unit tests for `AttackTransitionBaseAction` covering all 3 outcomes and `GuardianFactory` stats.

## Implementation Steps

1. **Create test file** `test/domain/action/attack_transition_base_action_test.dart`:

2. **Validation test cases**:
   - `Fails without abyssAdmiral in selection`: select units with 0 admirals → fail
   - `Fails without descentModule built`: module level = 0 → fail
   - `Fails if transition base already captured`: capturedBy != null → fail
   - `Fails if cell is not a transition base`: normal cell → fail
   - `Succeeds with valid inputs`: admiral selected + module built + uncaptured faille → success

3. **Execution test cases** (use seeded Random for deterministic fights):
   - `Victory + admiral alive → capture`: set up strong army, verify `transitionBase.capturedBy == playerId`
   - `Victory + admiral dead → no capture`: set up army where admiral dies but others win, verify `capturedBy` still null, surviving units return
   - `Defeat → army lost`: set up weak army, verify all selected units removed, `capturedBy` null
   - `Guardians reform after failed capture`: verify transition base can be attacked again after failure

4. **Casualty test cases**:
   - Verify unit counts decremented correctly after combat
   - Verify `abyssAdmiral` count decremented on death

5. **GuardianFactory test cases** (in `test/domain/fight/guardian_factory_test.dart`):
   - Faille: 1 boss (100/15/10) + 5 sentinelles (30/8/5)
   - Cheminee: 1 boss (200/25/15) + 8 golems (50/12/8)
   - Verify isBoss flags

## Dependencies
- **Internal**: Task 08 (GuardianFactory), Task 13 (AttackTransitionBaseAction)
- **External**: FightEngine (existing)

## Test Plan
- Self — this IS the test task
- Run `flutter test test/domain/action/attack_transition_base_action_test.dart`
- Run `flutter test test/domain/fight/guardian_factory_test.dart`

## Notes
- Use a seeded `Random` in `FightEngine` to control combat outcomes deterministically.
- For "victory + admiral dead" scenario, you may need to find a specific seed that produces this outcome, or mock the fight engine.

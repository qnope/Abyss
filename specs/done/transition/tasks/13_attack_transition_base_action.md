# Task 13: Create AttackTransitionBaseAction

## Summary
New action to assault a transition base. Uses `FightEngine` with guardian armies. Three outcomes: capture (victory + admiral alive), failed capture (victory + admiral dead), defeat (army lost + guardians reform).

## Implementation Steps

1. **Create AttackTransitionBaseAction** in `lib/domain/action/attack_transition_base_action.dart`:
   ```dart
   class AttackTransitionBaseAction extends Action {
     final int targetX;
     final int targetY;
     final int level;
     final Map<UnitType, int> selectedUnits;

     ActionType get type => ActionType.attackTransitionBase;
   }
   ```

2. **Validate**:
   - Cell at (targetX, targetY) on `game.levels[level]` has `CellContentType.transitionBase`
   - Transition base is not already captured
   - `selectedUnits` contains at least 1 `abyssAdmiral`
   - Player has required building: `descentModule` (level >= 1) for faille, `pressureCapsule` (level >= 1) for cheminee
   - Player has sufficient units on `level` for all selected types

3. **Execute**:
   - Build player combatants from `selectedUnits` (using `CombatantBuilder`)
   - Build guardian combatants from `GuardianFactory.forType(transitionBase.type)`
   - Run `FightEngine.resolve(playerSide, monsterSide)`
   - **Victory + abyssAdmiral alive**: set `transitionBase.capturedBy = player.id`, return success with fight result
   - **Victory + abyssAdmiral dead**: guardians reform (no state change), surviving units return (apply casualties), return partial success
   - **Defeat**: all sent units lost (apply full casualties), guardians reform, return failure with fight result

4. **Create AttackTransitionBaseResult** extending `ActionResult`:
   - `FightResult fightResult`
   - `bool captured`
   - `Map<UnitType, int> casualties`

5. **Check admiral survival**: after fight, check if any combatant with `typeKey == 'abyssAdmiral'` is alive

6. **Apply casualties**: subtract lost units from `player.unitsOnLevel(level)`

## Dependencies
- **Internal**: Task 07 (TransitionBase model), Task 08 (GuardianFactory), Task 09 (descent buildings), Task 06 (multi-level Game)
- **External**: FightEngine, CombatantBuilder (existing)

## Test Plan
- **File**: `test/domain/action/attack_transition_base_action_test.dart`
  - Verify validation fails without abyssAdmiral in selection
  - Verify validation fails without descentModule built
  - Verify validation fails if transition base already captured
  - Verify capture on victory + admiral alive
  - Verify no capture on victory + admiral dead (guardians reform)
  - Verify army lost on defeat
- Run `flutter analyze`

## Notes
- The FightEngine is deterministic with a seeded Random. Tests should use a known seed to control outcomes.
- "Guardians reform" means the transition base remains neutral with full-strength guardians — no mutation needed since TransitionBase doesn't store guardian HP.

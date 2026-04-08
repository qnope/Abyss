# Task 07 — Integration test: military tech improves combat outcome

## Summary

Add an integration-style test that proves the military research level
**concretely changes combat damage** end-to-end. Two equivalent
scenarios are run with the same `Random` seed and the same selected
units; one player has `military.researchLevel = 0`, the other
`military.researchLevel = 3`. The boosted player must inflict more
total damage than the baseline.

This is the spec's "Combat complet avec tech militaire" integration
case (Section 3 of SPEC.md).

## Files

- `test/domain/action/fight_monster_action_military_integration_test.dart`
  — new file (kept separate from the unit-test file for clarity).

## Implementation steps

1. Create the new test file.
2. Set up two helpers in the test:
   ```dart
   FightMonsterResult runFight({required int level, required int seed}) {
     final scenario = createFightScenario(
       difficulty: MonsterDifficulty.medium,
       unitCount: 4,
       stock: {UnitType.harpoonist: 6},
       militaryResearchLevel: level,
     );
     final action = FightMonsterAction(
       targetX: 1,
       targetY: 1,
       selectedUnits: {UnitType.harpoonist: 6},
       random: Random(seed),
     );
     return action.execute(scenario.game, scenario.player)
         as FightMonsterResult;
   }

   int totalDamageOnMonsters(FightMonsterResult r) =>
       r.fight.turnSummaries.fold<int>(
         0,
         (acc, t) => acc + t.damageDealtToMonsters,
       );
   ```
   (Adjust field names to match the actual `FightTurnSummary` API —
   confirm via `lib/domain/fight/fight_turn_summary.dart` before
   writing.)
3. Test cases:
   - **`military level 3 deals more damage than level 0`**:
     ```dart
     final r0 = runFight(level: 0, seed: 7);
     final r3 = runFight(level: 3, seed: 7);
     expect(totalDamageOnMonsters(r3),
            greaterThan(totalDamageOnMonsters(r0)));
     ```
   - **`military level 3 produces a victory at least as often`** —
     run both with the same seed. Either both win or the boosted side
     wins; assert
     `!(r0.victory && !r3.victory)` (boosted should never lose where
     baseline wins).
   - **`bonus also visible on initialPlayerCombatants atk`**:
     `expect(r3.fight.initialPlayerCombatants.first.atk,
       greaterThan(r0.fight.initialPlayerCombatants.first.atk));`
4. Verify imports: `dart:math`, `flutter_test`, the action, the
   result, the helper, and any fight types referenced.

## Test plan (sanity)

- File compiles and `flutter test
  test/domain/action/fight_monster_action_military_integration_test.dart`
  passes locally.
- Existing fight integration tests (`fight_monster_action_*` and
  `fight_summary_*`) keep passing with no modification.

## Dependencies

- Internal: tasks 01, 02, 03 must be completed first.
- External: none.
- Blocks: task 09.

## Notes

- If the chosen seed proves brittle (e.g., both runs deal identical
  damage in a degenerate case), pick a seed where the difference is
  unambiguous; document the choice with a comment.
- Do **not** mock `FightEngine`. The whole point of this test is to
  exercise the real engine + builder + action chain.
- Do not duplicate unit-level assertions already covered by tasks 01
  and 02 — focus this file on the **end-to-end behavior**.

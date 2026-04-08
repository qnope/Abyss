# Task 02 — FightMonsterAction: forward military research level

## Summary

Wire the new `militaryResearchLevel` parameter of
`CombatantBuilder.playerCombatantsFrom` (task 01) into
`FightMonsterAction.execute`. The value comes from the player's
`techBranches[TechBranch.military]`:

- If the branch entry is missing or `unlocked == false` → use `0`.
- Otherwise → use `state.researchLevel`.

This makes US-05 effective in production combat resolution.

## Files

- `lib/domain/action/fight_monster_action.dart` — read research level,
  pass to builder.
- `test/domain/action/fight_monster_action_helper.dart` — extend the
  helper to optionally seed the player's military research level (so
  task 03 and tests in this task can use it).
- `test/domain/action/fight_monster_action_casualty_test.dart` (or a
  new sibling file) — exercise the bonus end-to-end.

## Implementation steps

1. Open `lib/domain/action/fight_monster_action.dart`.
2. Add a small private helper at the bottom of the class:
   ```dart
   int _militaryResearchLevelOf(Player player) {
     final TechBranchState? state =
         player.techBranches[TechBranch.military];
     if (state == null || !state.unlocked) return 0;
     return state.researchLevel;
   }
   ```
   Add the necessary imports for `TechBranch` and `TechBranchState`.
3. In `execute`, replace
   ```dart
   final List<Combatant> playerCombatants =
       CombatantBuilder.playerCombatantsFrom(selectedUnits);
   ```
   with
   ```dart
   final int militaryLevel = _militaryResearchLevelOf(player);
   final List<Combatant> playerCombatants =
       CombatantBuilder.playerCombatantsFrom(
     selectedUnits,
     militaryResearchLevel: militaryLevel,
   );
   ```
4. Verify the file is still under 150 lines. If it crosses, extract
   `_militaryResearchLevelOf` into `FightMonsterHelpers` and re-import.

## Helper update

In `test/domain/action/fight_monster_action_helper.dart`:

1. Add a `militaryResearchLevel` named parameter (default `0`) to both
   `buildFightTestPlayer` and `createFightScenario`.
2. After constructing the player, if `militaryResearchLevel > 0`, do:
   ```dart
   final TechBranchState mil =
       player.techBranches[TechBranch.military]!;
   mil.unlocked = true;
   mil.researchLevel = militaryResearchLevel;
   ```
3. Add the missing imports.

## Test plan

Create a new file
`test/domain/action/fight_monster_action_military_bonus_test.dart`
with cases:

- **`combatant atk reflects player military level`** —
  `createFightScenario(stock: {harpoonist: 1}, militaryResearchLevel: 3)`,
  call `action.execute`, capture
  `result.fight.initialPlayerCombatants.first.atk` and assert it equals
  `(UnitStats.forType(harpoonist).atk * 1.6).round()`.
- **`level 0 leaves atk unchanged`** — same setup with
  `militaryResearchLevel: 0`, assert raw atk.
- **`unlocked == false yields no bonus`** — manually set the branch to
  `unlocked = false, researchLevel = 5` after scenario creation; assert
  raw atk in the resulting combatant.
- **`monster combatants are unaffected`** — same setup with level 3,
  inspect `result.fight` and assert
  `monster combatants .atk == MonsterUnitStats.forLevel(1).atk`. (Use
  the engine's per-turn snapshots or extend the action's return as
  needed; if not directly exposed, fetch via
  `CombatantBuilder.monsterCombatantsFrom(lair)` and compare.)

Use `Random(seed)` for determinism.

## Dependencies

- Internal: task 01 (signature change).
- External: none.
- Blocks: task 03 (will keep using the helper), task 06 (UI bonus
  computation must mirror this rule), task 07 (integration test).

## Notes

- Keep the lookup logic in **one** place (the private helper) so tasks
  06 (UI label) and 07 (integration) can reuse the same rule by
  calling it indirectly via the action, or by replicating the same
  three lines in a presentation helper. **Do not** duplicate the
  formula itself — reuse `CombatantBuilder` from task 01.

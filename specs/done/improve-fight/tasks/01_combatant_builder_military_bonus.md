# Task 01 — CombatantBuilder: military attack bonus

## Summary

Add an opt-in military research-level parameter to
`CombatantBuilder.playerCombatantsFrom` that boosts each player combatant's
`atk` by **+20% per level**, multiplicative on the base stat (US-05).

Formula: `atk_finale = (atk_base * (1 + 0.20 * researchLevel)).round()`.

The bonus must:
- only apply to **player** combatants (monsters keep raw stats),
- only modify `atk` (`hp` and `def` unchanged),
- default to `0` (no bonus) so existing call sites that don't yet pass it
  keep current behavior — but **task 02** will update the only production
  caller (`FightMonsterAction`) immediately after.

Pure-Dart change. No Flutter, no Hive.

## Files

- `lib/domain/fight/combatant_builder.dart` — modify
  `playerCombatantsFrom` signature and stat computation.
- `test/domain/fight/combatant_builder_test.dart` — extend with bonus
  cases.

## Implementation steps

1. Open `lib/domain/fight/combatant_builder.dart`.
2. Change the signature of `playerCombatantsFrom` to:
   ```dart
   static List<Combatant> playerCombatantsFrom(
     Map<UnitType, int> selectedUnits, {
     int militaryResearchLevel = 0,
   })
   ```
3. Inside the loop, after reading `UnitStats stats`, compute:
   ```dart
   final int boostedAtk =
       (stats.atk * (1 + 0.20 * militaryResearchLevel)).round();
   ```
   and pass `atk: boostedAtk` to the `Combatant` constructor. Keep
   `maxHp: stats.hp` and `def: stats.def` unchanged.
4. Leave `monsterCombatantsFrom` and `unitTypeFromKey` untouched.
5. Verify the file is still under 150 lines.

## Test plan

File: `test/domain/fight/combatant_builder_test.dart`

Add a new `group('military bonus')` containing:

- **`level 0 keeps base atk`** — call
  `playerCombatantsFrom({UnitType.harpoonist: 1})` with no bonus
  parameter; assert `combatants.first.atk == UnitStats.forType(harpoonist).atk`.
- **`level 3 multiplies by 1.6`** — call with
  `militaryResearchLevel: 3`; assert
  `atk == (UnitStats.forType(harpoonist).atk * 1.6).round()`.
- **`level 5 multiplies by 2.0`** — call with
  `militaryResearchLevel: 5`; assert
  `atk == UnitStats.forType(harpoonist).atk * 2`.
- **`bonus does not affect hp or def`** — pick guardian (def 6, hp 25);
  with level 3, assert `def == 6` and `maxHp == 25`.
- **`bonus does not affect monster combatants`** — call
  `monsterCombatantsFrom(MonsterLair(easy, 2))`; assert each combatant's
  `atk == MonsterUnitStats.forLevel(1).atk`. (No `militaryResearchLevel`
  parameter is exposed for monsters — verify by absence.)

Existing tests must keep passing untouched (default param = 0).

## Dependencies

- Internal: `lib/domain/unit/unit_stats.dart`, `lib/domain/fight/combatant.dart`.
- External: none.
- Blocks: task 02 (FightMonsterAction needs the new parameter).

## Notes

- Use `.round()` (banker's-free, deterministic) so the spec example
  `level 5` → `*2.0` lands exactly on integer values.
- Do **not** introduce a separate `MilitaryBonusCalculator` class for
  this single one-line formula — keep the math inline per CLAUDE.md
  rules ("Don't create helpers… for one-time operations").

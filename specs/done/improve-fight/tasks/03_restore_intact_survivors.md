# Task 03 — FightMonsterAction: restore intact survivors to stock

## Summary

Implement US-04: at the end of `FightMonsterAction.execute`, the
**intact survivors** (combatants whose `currentHp > 0` after the
fight) must rejoin the player's stock immediately, in addition to the
wounded that already do. Only `dead` units stay removed.

Invariant after a combat:
`stock_final[type] == stock_initial[type] - dead[type]`

The `FightMonsterResult` shape doesn't change — `survivorsIntact`,
`wounded`, and `dead` are already tracked separately.

## Files

- `lib/domain/action/fight_monster_action.dart` — restore the `alive`
  list at the same point where `restoreWounded` is called.
- `lib/domain/action/fight_monster_helpers.dart` — add a tiny
  `restoreSurvivors` helper (or generalize `restoreWounded` to take any
  list of combatants — preferred, see notes).
- `test/domain/action/fight_monster_action_casualty_test.dart` — assert
  the new invariant.

## Implementation steps

1. Open `lib/domain/action/fight_monster_helpers.dart`.
2. Rename `restoreWounded` to `restoreToStock` (single, generic
   helper). It already accepts a `List<Combatant>` — no body change.
   Update its dartdoc to "Restores the given combatants to
   `player.units` (one stock increment per combatant)."
3. Open `lib/domain/action/fight_monster_action.dart`. Replace the
   single call
   ```dart
   FightMonsterHelpers.restoreWounded(player, split.wounded);
   ```
   with two calls placed right after `alive` is built and `split` is
   computed:
   ```dart
   FightMonsterHelpers.restoreToStock(player, alive);
   FightMonsterHelpers.restoreToStock(player, split.wounded);
   ```
4. Confirm both files stay under 150 lines.
5. Search the project for any other call to `restoreWounded` and
   update it to `restoreToStock`:
   - `Grep` for `restoreWounded` across `lib/` and `test/`.

## Test plan

In `test/domain/action/fight_monster_action_casualty_test.dart`,
extend the existing `wounded units are restored to player stock` test
(or add a new sibling test) to also verify intact survivors:

- **`final stock == initial - dead`** — after `execute`, assert
  ```dart
  expect(finalStock, initialStock - dead);
  ```
  using the per-type `dead` count from `result.dead`.
- **`survivorsIntact are restored`** — pick a seed where survivors are
  guaranteed (e.g. send 6 harpoonists vs an easy 1-monster lair, seed
  `Random(0)` empirically chosen). Assert
  `result.survivorsIntact[harpoonist]! > 0` and the corresponding
  stock contribution.
- **`dead units stay removed`** — using a seed where `dead > 0`,
  assert that `finalStock + dead == initialStock - 0` (i.e., the
  delta against `initialStock` matches `dead` exactly).

If picking a deterministic seed for "guaranteed dead" or "guaranteed
survivors" proves brittle, instead **mathematically check the
invariant** without asserting specific counts:
```dart
expect(
  finalStock,
  initialStock - (result.dead[harpoonist] ?? 0),
);
```
This is the simplest, most robust assertion of US-04 and should be the
primary test.

Also add a regression test ensuring **wounded** still come back
(the current behavior). The previous test
`wounded units are restored to player stock` already does
`finalStock == initialStock - sent + wounded` — update it to the new
invariant `finalStock == initialStock - dead` (which is equivalent
because `sent == survivors + wounded + dead`).

## Dependencies

- Internal: helper rename ripples through the action and any tests
  that import it (search before assuming none).
- External: none.
- Blocks: task 07 (integration assertions rely on the new invariant).

## Notes

- Per CLAUDE.md ("Avoid backwards-compatibility hacks"), do **not**
  keep `restoreWounded` as an alias. Rename and update all callers.
- The order of restore calls (alive then wounded, or wounded then
  alive) does not matter — they target different combatants.
- Do not change the `FightMonsterResult` shape.

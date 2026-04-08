# Task 06 — ArmySelectionScreen: integrate slider + summary card

## Summary

Wire the new `UnitQuantityRow` slider behavior (task 04) and the new
`SelectionSummaryCard` (task 05) into `ArmySelectionScreen`. Compute
the running ATK/DEF totals and the military level to display, mirror
the same `+20%/level` formula used by `CombatantBuilder`.

This closes US-01, US-02, and US-03 in the UI.

## Files

- `lib/presentation/screens/game/fight/army_selection_screen.dart` —
  reorganize the body, add a `_buildSummary` helper, compute totals.
- (No new file unless the screen exceeds 150 lines — see step 5.)
- `test/presentation/screens/game/fight/army_selection_screen_test.dart`
  — extend with totals and bonus assertions.

## Implementation steps

1. Open `lib/presentation/screens/game/fight/army_selection_screen.dart`.
2. Add an import for `SelectionSummaryCard`, `UnitStats`, `TechBranch`,
   and `TechBranchState`.
3. Add a private getter on `_ArmySelectionScreenState`:
   ```dart
   int get _militaryLevel {
     final TechBranchState? s =
         widget.game.humanPlayer.techBranches[TechBranch.military];
     if (s == null || !s.unlocked) return 0;
     return s.researchLevel;
   }
   ```
4. Add two private getters that compute the running totals from
   `_selected`, applying the same `(atk * (1 + 0.20 * level)).round()`
   per **unit**, then summing:
   ```dart
   int get _totalAtk {
     int sum = 0;
     for (final MapEntry<UnitType, int> e in _selected.entries) {
       if (e.value <= 0) continue;
       final UnitStats stats = UnitStats.forType(e.key);
       final int boosted =
           (stats.atk * (1 + 0.20 * _militaryLevel)).round();
       sum += boosted * e.value;
     }
     return sum;
   }

   int get _totalDef {
     int sum = 0;
     for (final MapEntry<UnitType, int> e in _selected.entries) {
       if (e.value <= 0) continue;
       sum += UnitStats.forType(e.key).def * e.value;
     }
     return sum;
   }
   ```
5. In `_buildBody`, between the rows list and the launch button row,
   insert:
   ```dart
   SelectionSummaryCard(
     totalAtk: _totalAtk,
     totalDef: _totalDef,
     militaryLevel: _militaryLevel,
   ),
   const SizedBox(height: 12),
   ```
6. **150-line check.** Adding ~25 lines to a 128-line file may push it
   slightly over. If so:
   - Extract the three computation getters into a new file
     `lib/presentation/screens/game/fight/army_selection_summary.dart`
     as a top-level `class ArmySelectionSummary` with three pure
     methods that take `(Map<UnitType, int>, int militaryLevel)`. The
     screen calls them. Add a unit test for the class.
   - This is the *only* permitted extraction; do not start
     extracting other helpers proactively.
7. Run `wc -l` mentally on every touched file; ensure ≤ 150.

## Test plan

In `test/presentation/screens/game/fight/army_selection_screen_test.dart`:

- **`shows summary card with zero totals at start`** — pump with
  default stock; assert `find.byType(SelectionSummaryCard)` exists,
  and `find.text('0')` for both ATK and DEF (or fetch the widget and
  read its props).
- **`incrementing scout updates ATK total`** — pump with
  `{scout: 3}`, tap `+` once, assert the rendered ATK = `2`
  (`UnitStats.forType(scout).atk`). Tap `+` again → `4`.
- **`includes military bonus in ATK total`** — extend
  `createFightScenario` (already done in task 02) with
  `militaryResearchLevel: 5`, pump, tap `+` once on harpoonist
  (atk 5), assert ATK = `(5 * 2.0).round() == 10`.
- **`shows "Bonus militaire : aucun" with no military tech`** —
  pump with default scenario, assert
  `find.text('Bonus militaire : aucun')` or
  `find.textContaining('aucun')`.
- **`shows formatted bonus label when level > 0`** — pump with
  `militaryResearchLevel: 3`, assert
  `find.text('Bonus militaire : +60% ATK (niveau 3)')`.

The existing tests (`lists unit types`, `launch button disabled`,
etc.) must keep passing.

## Dependencies

- Internal: tasks 04 and 05 must be completed first.
- External: none.
- Blocks: task 07 (integration tests reference the same UI), task 09
  (final analyze/test).

## Notes

- The duplicated formula (here in the screen's `_totalAtk` and in
  `CombatantBuilder` from task 01) is **intentional and minimal**:
  one line of math in two places, easier to read than introducing a
  shared static helper just for the UI. If the formula ever becomes
  non-trivial, extract a `MilitaryBonus` value object — but not now.
- Do **not** call `CombatantBuilder.playerCombatantsFrom` from the
  presentation layer — `CombatantBuilder` is domain logic and the
  presentation must not allocate `Combatant` objects just to read
  numbers.

# Task 09 — Quality gates: analyze + tests + line budget

## Summary

Run the project's mandatory quality checks once everything is wired
in:

- `flutter analyze` — must report **no new errors or warnings**.
- `flutter test` — must pass **at 100%**.
- File-size sweep — every file touched in tasks 01-08 must be **≤ 150
  lines** (CLAUDE.md rule).

If any gate fails, fix the underlying issue rather than papering over
it (no `// ignore`, no skipped tests).

## Steps

1. From the worktree root run:
   ```
   flutter analyze
   ```
   - Investigate every diagnostic. Most likely sources: an unused
     import after the `restoreWounded` rename, a missing import for
     `TechBranchState`, or a `Slider` parameter type mismatch.
2. Run:
   ```
   flutter test
   ```
   - Re-run any failing test individually to read the failure quickly.
3. Line-budget sweep. Use Glob/Grep, not Bash, to enumerate the
   touched files, then `Read` each and confirm line count:
   - `lib/domain/fight/combatant_builder.dart`
   - `lib/domain/action/fight_monster_action.dart`
   - `lib/domain/action/fight_monster_helpers.dart`
   - `lib/presentation/widgets/fight/unit_quantity_row.dart`
   - `lib/presentation/widgets/fight/selection_summary_card.dart`
   - `lib/presentation/screens/game/fight/army_selection_screen.dart`
   - (Plus the optional `army_selection_summary.dart` from task 06 if
     it was created.)
4. If a file exceeds 150 lines, extract the smallest possible cohesive
   helper to a sibling file. Do **not** split files just to game the
   metric — extract along a meaningful seam.
5. Re-run analyze + test after any fixup.

## Acceptance

- `flutter analyze` exits with `No issues found!`.
- `flutter test` ends with `All tests passed!`.
- Every file listed above is at most 150 lines.

## Dependencies

- Blocked by tasks 01-08.
- Blocks: project finalization.

## Notes

- This task is the **only** place that runs the test suite full-pass.
  Earlier tasks can run targeted tests but should not block on the
  full suite — keeps each task ≤ 5 minutes.
- If a regression appears in an unrelated file, revert your blast
  radius and check whether a transitive change is implicated. Don't
  start fixing unrelated breakage without a TaskCreate entry.

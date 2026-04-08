# Task 23 — Run `flutter analyze` and `flutter test`; fix any remaining issues

## Summary

Final validation pass. Run the two quality gates called out in `CLAUDE.md` and resolve anything they flag. No new features — only lint/warning/test fixes surfaced by the gates.

## Implementation Steps

1. **Run `flutter analyze`**
   - Expect zero errors, zero warnings, zero infos in files touched by this project.
   - Common culprits after a big refactor:
     - Unused imports (remove).
     - `prefer_final_fields` on the new `revealedCells` / `recruitedUnitTypes` if they are never reassigned.
     - Dead code in `TurnResolver` or `ExplorationResolver` if old branches were left behind.
2. **Run `flutter test`**
   - All tests green.
   - If a test fails, fix the *code* rather than weakening the test — unless the test is asserting deprecated behaviour, in which case delete the outdated case and note it in the task commit message.
3. **Manual smoke test**
   - `flutter run -d chrome` (or iOS/Android simulator if available).
   - New game → observe fog around base, explore one cell, collect one treasure, upgrade one building, end turn.
   - Nothing crashes; resources update correctly.
4. **Check file-length rule**
   - Run a quick scan: any file in `lib/` that the project touched must be under 150 lines. Split further if needed (prefer extracting private helpers into sibling files).

## Dependencies

- Every preceding task.

## Test Plan

This task *is* the test plan. Success criteria:

- `flutter analyze` → "No issues found!".
- `flutter test` → all green.
- Manual smoke test passes.
- No file touched by the project exceeds 150 lines.

## Notes

- Keep the fix scope tight. If `flutter analyze` surfaces warnings in unrelated files, file a follow-up rather than fix them here.

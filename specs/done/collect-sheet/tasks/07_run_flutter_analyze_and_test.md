# Task 07 — Run flutter analyze and flutter test

## Summary

Final validation: the project's success criteria require `flutter analyze` to pass without errors, all tests to pass, and every modified/created file to stay under 150 lines.

## Implementation Steps

1. **Run `flutter analyze`** from the worktree root.
   - Fix any warnings or errors before moving on.
   - Special attention to: unused imports left over from the refactor in Task 02 (e.g. the old per-content private helpers), and to any cast warnings around `result is CollectTreasureResult`.

2. **Run `flutter test`**.
   - All existing tests + the new ones from Tasks 03, 04, and 05 must pass.
   - If a previously-passing test broke (e.g. one that depended on the old ruins reward ranges and lives outside `collect_treasure_action_execute_test.dart`), update it. Search the test directory for any file referencing "ruins" or `ResourceType.pearl` rolls before declaring done.

3. **Verify file sizes**
   - For each file touched in this project, confirm `wc -l` reports < 150 lines:
     - `lib/domain/action/collect_treasure_action.dart`
     - `lib/domain/action/collect_treasure_result.dart`
     - `lib/presentation/widgets/resource/resource_gain_dialog.dart`
     - `lib/presentation/screens/game/game_screen_map_actions.dart`
     - `test/domain/action/collect_treasure_action_execute_test.dart`
     - `test/presentation/widgets/resource/resource_gain_dialog_test.dart`
     - `test/presentation/screens/game/game_screen_map_actions_collect_test.dart`
     - Any architecture README touched by Task 06.

4. **Manual sanity check** (optional but recommended)
   - Run `flutter run -d chrome` (or any device), generate a map, find a `resourceBonus` cell, collect it, confirm the dialog shows correct amounts. Repeat for a `ruins` cell.

## Dependencies

- All previous tasks (01–06).

## Test Plan

- `flutter analyze` must report `No issues found!`.
- `flutter test` must report `All tests passed!`.

## Notes

- This is a validation task — no new code beyond fixes uncovered by analyze/test.
- If flutter analyze warns about an unused private member from the old `_collectResourceBonus` / `_collectRuins` helpers, delete them — Task 02 already noted to drop or refactor them, and dead code is not allowed.

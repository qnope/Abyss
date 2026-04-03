# Task 09 — Verify all tests and finalize

## Summary

Run the full test suite and static analysis to ensure no regressions. Fix any issues found.

## Implementation Steps

1. Run `flutter analyze` — must report no issues
2. Run `flutter test` — all tests must pass
3. Verify every new file is under 150 lines:
   - `lib/domain/action_type.dart`
   - `lib/domain/action_result.dart`
   - `lib/domain/action.dart`
   - `lib/domain/upgrade_building_action.dart`
   - `lib/domain/action_executor.dart`
   - `test/domain/action_result_test.dart`
   - `test/domain/upgrade_building_action_test.dart`
   - `test/domain/action_executor_test.dart`
4. If any test fails, fix the issue and re-run
5. If `flutter analyze` reports warnings, fix them

## Dependencies

- All previous tasks (01–08)

## Test Plan

- `flutter analyze` → 0 issues
- `flutter test` → all green
- Line count check → all files < 150 lines

## Notes

- This is the final validation step. No new code should be written here, only fixes if needed.
- Pay attention to the existing `game_screen_test.dart` 'upgrade increases building level' test — it's the key regression check.

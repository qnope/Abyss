# Task 07 — Turn summary dialog tests

## Summary

Widget tests for the turn summary dialog: correct display of resource changes and capping indicator.

## Implementation Steps

1. Create `test/presentation/widgets/turn_summary_dialog_test.dart`
2. Helper: wrap `showTurnSummaryDialog` in a `MaterialApp` with `AbyssTheme` and a button that triggers it.
3. Test cases:

### Display
- **Shows title**: finds `'Resume du tour'`
- **Shows gained resources**: with changes `[algae +5, coral +8]`, finds `'+5'`, `'+8'`, `'Algues'`, `'Corail'`
- **Shows capping indicator**: for a change with `wasCapped: true`, finds `'(max atteint)'`
- **No capping indicator when not capped**: for a change with `wasCapped: false`, does not find `'(max atteint)'` for that resource
- **Empty changes shows message**: finds `'Aucun changement ce tour.'`

### Actions
- **OK closes dialog**: tap `'OK'` → dialog closes

## Dependencies

- Task 06 (`turn_summary_dialog.dart`)
- Task 01 (`TurnResult`, `TurnResourceChange`)
- Existing: `AbyssTheme`, `ResourceType`, `test_svg_helper.dart`

## Test Plan

- **File**: `test/presentation/widgets/turn_summary_dialog_test.dart`
- Run: `flutter test test/presentation/widgets/turn_summary_dialog_test.dart`

## Notes

- Use `mockSvgAssets()` / `clearSvgMocks()` from `test_svg_helper.dart`.

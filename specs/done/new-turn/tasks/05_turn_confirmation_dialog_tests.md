# Task 05 — Turn confirmation dialog tests

## Summary

Widget tests for the turn confirmation dialog: correct display of production preview and button behaviors.

## Implementation Steps

1. Create `test/presentation/widgets/turn_confirmation_dialog_test.dart`
2. Helper: wrap `showTurnConfirmationDialog` in a `MaterialApp` with `AbyssTheme` and a button that triggers it.
3. Test cases:

### Display
- **Shows title**: finds `'Passer au tour suivant ?'`
- **Shows production for each resource**: with `{algae: 5, coral: 8}`, finds `'+5'` and `'+8'` and display names `'Algues'`, `'Corail'`
- **Hides resources with 0 production**: only resources in the map are shown
- **Empty production shows message**: when production is empty, finds `'Aucune production ce tour.'`

### Actions
- **Cancel returns false**: tap `'Annuler'` → dialog closes, returned value is false
- **Confirm returns true**: tap `'Confirmer'` → dialog closes, returned value is true

## Dependencies

- Task 04 (`turn_confirmation_dialog.dart`)
- Existing: `AbyssTheme`, `ResourceType`, `test_svg_helper.dart`

## Test Plan

- **File**: `test/presentation/widgets/turn_confirmation_dialog_test.dart`
- Run: `flutter test test/presentation/widgets/turn_confirmation_dialog_test.dart`

## Notes

- Use `mockSvgAssets()` / `clearSvgMocks()` from `test_svg_helper.dart` for SVG icons.
- Follow the same pattern as `building_detail_sheet_test.dart` for dialog testing.

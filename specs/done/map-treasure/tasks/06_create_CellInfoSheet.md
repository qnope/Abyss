# Task 06 — Create CellInfoSheet widget

## Summary

Create a reusable bottom sheet widget for displaying simple informational messages about map cells (empty, player base, already collected). No action button.

## Implementation Steps

1. **Create `lib/presentation/widgets/map/cell_info_sheet.dart`**

   - Create `showCellInfoSheet(BuildContext, {required String title, required String message, IconData? icon, Color? iconColor})` top-level function
   - Uses `showModalBottomSheet` like `ExplorationSheet`
   - Internal `_CellInfoSheet` stateless widget:
     - Optional icon (64px, colored with `iconColor ?? AbyssColors.onSurfaceDim`)
     - Title text (headlineSmall, `AbyssColors.biolumCyan`)
     - Message text (bodyMedium, `AbyssColors.onSurfaceDim`)
     - Padding: `EdgeInsets.fromLTRB(24, 0, 24, 32)` (same as ExplorationSheet)

## Dependencies

- None (standalone widget)

## Test Plan

- **File:** `test/presentation/widgets/map/cell_info_sheet_test.dart`
- Test: title text is displayed
- Test: message text is displayed
- Test: icon is displayed when provided
- Test: no icon when not provided

## Notes

- Reused for 3 cases: empty cell, player base, already collected cell.
- Follows the same visual pattern as `ExplorationSheet` for consistency.
- Keep under 80 lines — it's a simple informational sheet.

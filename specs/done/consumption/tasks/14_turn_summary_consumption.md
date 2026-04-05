# Task 14: Update TurnSummaryDialog with Consumption Results

## Summary

Update the turn summary dialog to show consumption amounts, deactivated buildings, and lost units from the `TurnResult`.

## Implementation Steps

### 1. Update `lib/presentation/widgets/turn_summary_dialog.dart`

The dialog already receives `TurnResult`. With the updated TurnResult (Task 3), it now has access to `deactivatedBuildings`, `lostUnits`, and `consumed` on each change.

**Resource changes display update:**
- For each `TurnResourceChange`:
  - If `consumed > 0`: show `+produced / -consumed` (net: `produced - consumed`)
  - If `consumed == 0`: show `+produced` as before
  - Keep `(max atteint)` indicator

**Deactivated buildings section (after resource changes):**
- If `result.deactivatedBuildings` is not empty:
  - Show divider
  - Title: "Batiments desactives" with warning icon
  - List each building `displayName` with `AbyssColors.warning` color

**Lost units section:**
- If `result.lostUnits` is not empty:
  - Show divider
  - Title: "Unites perdues" with error icon
  - List each unit type with count: "Eclaireur: -5" in `AbyssColors.error` color

### 2. Imports to add
- `building_type_extensions.dart`
- `unit_type_extensions.dart`

## Dependencies

- Task 3 (TurnResult must have new fields)

## Test Plan

- File: `test/presentation/widgets/turn_summary_dialog_test.dart` (update)
- See Task 16

## Notes

- Existing callers pass a TurnResult — new fields have defaults, so backward-compatible
- Keep under 150 lines — extract sections into helper methods if needed

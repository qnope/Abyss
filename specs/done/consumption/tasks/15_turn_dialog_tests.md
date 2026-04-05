# Task 15: Test Turn Confirmation and Summary Dialogs

## Summary

Write widget tests for the updated turn confirmation (warnings) and turn summary (consumption results) dialogs.

## Implementation Steps

### 1. Update `test/presentation/widgets/turn_confirmation_dialog_test.dart`

#### Group: `consumption warnings`
- `shows consumption for energy` — consumption={energy: 8} → finds "-8" text
- `shows consumption for algae` — consumption={algae: 12} → finds "-12" text
- `shows building deactivation warning` — buildingsToDeactivate=[oreExtractor] → finds "Extracteur de minerai" text
- `shows unit loss warning` — unitsToLose={scout: 5} → finds "Eclaireur" and "-5" text
- `no warnings when no deficits` — empty consumption/deactivation/losses → no warning widgets
- `existing production display still works` — production={algae: 50} → finds "+50"

### 2. Update `test/presentation/widgets/turn_summary_dialog_test.dart`

#### Group: `consumption display`
- `shows consumed amount` — TurnResourceChange with consumed=8 → finds "-8" text
- `shows deactivated buildings` — TurnResult with deactivatedBuildings=[coralMine] → finds "Mine de corail"
- `shows lost units` — TurnResult with lostUnits={guardian: 3} → finds "Gardien" and "-3"
- `no consumption sections when none` — Default TurnResult → no deactivation/loss sections
- `existing resource changes still display correctly` — Standard changes → "+50" text visible

## Dependencies

- Task 13 (TurnConfirmationDialog updated)
- Task 14 (TurnSummaryDialog updated)

## Test Plan

- Run: `flutter test test/presentation/widgets/turn_confirmation_dialog_test.dart`
- Run: `flutter test test/presentation/widgets/turn_summary_dialog_test.dart`

## Notes

- Use `mockSvgAssets()` / `clearSvgMocks()` for SVG icon tests
- Use `showTurnConfirmationDialog` / `showTurnSummaryDialog` helper functions to trigger dialogs

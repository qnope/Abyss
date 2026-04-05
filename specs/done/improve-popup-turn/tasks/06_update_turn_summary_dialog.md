# Task 6: Update TurnSummaryDialog

## Summary

Redesign the summary dialog to show resource progression with before/after values, capping indicators, turn transition, and an army recruitment section.

## Implementation Steps

### 1. Update the dialog widget

**File**: `lib/presentation/widgets/turn_summary_dialog.dart`

Update `_TurnSummaryDialog` to use the new `TurnResult` fields:

- **Title**: `'Tour ${result.previousTurn} → Tour ${result.newTurn}'`
- **Each resource change line**:
  - `ResourceIcon | Name | beforeAmount (+produced) → afterAmount`
  - If `wasCapped`: show line in `AbyssColors.warning` + append `(MAX)`
  - If `produced` is negative: show `(+produced)` in `AbyssColors.error` (red)
  - If `produced` is positive: show in resource color
  - If `produced` is zero: show in dim color
- **Army section** (only if `result.hadRecruitedUnits` is true):
  - Add a `Divider` after resource lines
  - Show an `Icon(Icons.shield)` + `Text('Recrutement disponible')` in `AbyssColors.success` color
  - This indicates recruitment slots have been reset
- **Empty state**: "Aucun changement ce tour." (unchanged, but now also checks `!hadRecruitedUnits`)
- **Button**: "OK" (unchanged)

### 2. Extract helpers to stay under 150 lines

Extract `_buildResourceLine` and `_buildArmySection` as private methods:

```dart
Widget _buildResourceLine(TurnResourceChange change) {
  final sign = change.produced >= 0 ? '+' : '';
  // ... build Row with beforeAmount, ($sign${change.produced}), →, afterAmount
}

Widget _buildArmySection() {
  return Row(children: [
    Icon(Icons.shield, color: AbyssColors.success, size: 20),
    SizedBox(width: 8),
    Text('Recrutement disponible', style: TextStyle(color: AbyssColors.success)),
  ]);
}
```

### 3. Update tests

**File**: `test/presentation/widgets/turn_summary_dialog_test.dart`

Update `createApp` to use new `TurnResult` constructor. Update/add tests:

- `shows turn transition title` — verify "Tour 3 → Tour 4"
- `shows resource progression` — verify format "100 (+50) → 150" with beforeAmount/afterAmount
- `shows capping indicator with MAX` — wasCapped=true, verify "(MAX)" text and warning color
- `no capping indicator when not capped` — unchanged logic
- `shows negative net in red` — produced < 0
- `shows army section when recruited` — hadRecruitedUnits=true, verify "Recrutement disponible"
- `hides army section when no recruitment` — hadRecruitedUnits=false, verify text absent
- `empty changes with no recruitment shows message` — no changes + hadRecruitedUnits=false
- `empty changes with recruitment shows army section` — no changes but hadRecruitedUnits=true → still show army section
- `OK closes dialog` — unchanged

## Dependencies

- **Task 3**: Updated `TurnResult` and `TurnResourceChange` with new fields

## Test Plan

- **File**: `test/presentation/widgets/turn_summary_dialog_test.dart`
- Run: `flutter test test/presentation/widgets/turn_summary_dialog_test.dart`
- Run: `flutter analyze`

## Notes

- The army section only appears when the player had recruited units the previous turn, reducing UI noise
- `produced` can now be negative (when maintenance > production), so use sign-aware formatting
- The empty state should account for the army section: if there are no resource changes but hadRecruitedUnits is true, show the army section (not the "Aucun changement" message)
- Keep file under 150 lines

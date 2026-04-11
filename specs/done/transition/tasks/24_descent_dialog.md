# Task 24: Create Descent Dialog

## Summary
Create a full-screen dialog for selecting units to send through a captured transition base during descent. Similar to `ArmySelectionScreen` but for descent (no monster preview, one-way warning).

## Implementation Steps

1. **Create DescentDialog** in `lib/presentation/screens/game/descent_dialog.dart`:
   ```dart
   class DescentDialog extends StatefulWidget {
     final Map<UnitType, Unit> availableUnits;  // units on current level
     final int targetLevel;
     final String transitionBaseName;
     final void Function(Map<UnitType, int> selectedUnits) onConfirm;
   }
   ```

2. **Layout**:
   - Header: "Descente vers Niveau {targetLevel}" + transition base name
   - Warning banner: "Attention: la descente est definitive. Les unites ne pourront pas remonter." (red/amber)
   - Unit selection list: reuse `UnitQuantityRow` widget for each unit type with count > 0
   - Confirm button: "Descendre ({totalSelected} unites)" — disabled if 0 selected

3. **Unit selection**: slider + buttons per unit type (same pattern as `ArmySelectionScreen`)

4. **No capacity limit** per spec — player can send all their units

## Dependencies
- **Internal**: Task 02 (Player.unitsPerLevel), Task 07 (TransitionBase)
- **External**: UnitQuantityRow (existing widget), AbyssTheme

## Test Plan
- **File**: `test/presentation/screens/game/descent_dialog_test.dart`
  - Verify all available unit types displayed
  - Verify confirm button disabled when 0 units selected
  - Verify warning banner displayed
  - Verify `onConfirm` called with selected units
- Run `flutter analyze`

## Notes
- Reuse `UnitQuantityRow` from `lib/presentation/widgets/fight/unit_quantity_row.dart`.
- Keep under 150 lines — the dialog is simpler than ArmySelectionScreen (no monster preview).

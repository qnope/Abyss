# Task 25: Create Reinforcement Dialog

## Summary
Create a dialog for selecting units to send as reinforcements through a captured transition base. Similar to DescentDialog but with transit time info instead of one-way warning.

## Implementation Steps

1. **Create ReinforcementDialog** in `lib/presentation/screens/game/reinforcement_dialog.dart`:
   ```dart
   class ReinforcementDialog extends StatefulWidget {
     final Map<UnitType, Unit> availableUnits;  // units on source level
     final int targetLevel;
     final String transitionBaseName;
     final void Function(Map<UnitType, int> selectedUnits) onConfirm;
   }
   ```

2. **Layout**:
   - Header: "Renforts vers Niveau {targetLevel}" + transition base name
   - Info banner: "Les renforts arriveront au prochain tour." (blue/info)
   - Unit selection list: reuse `UnitQuantityRow` per unit type
   - Confirm button: "Envoyer ({totalSelected} unites)" — disabled if 0 selected

3. **Unit selection**: same pattern as DescentDialog / ArmySelectionScreen

## Dependencies
- **Internal**: Task 02 (Player.unitsPerLevel), Task 07 (TransitionBase)
- **External**: UnitQuantityRow (existing), AbyssTheme

## Test Plan
- **File**: `test/presentation/screens/game/reinforcement_dialog_test.dart`
  - Verify info banner shows transit time
  - Verify confirm button disabled when 0 selected
  - Verify `onConfirm` called with selected units
- Run `flutter analyze`

## Notes
- Very similar to DescentDialog. Consider extracting a shared `UnitSelectionDialog` base if both exceed 100 lines.
- Keep under 150 lines.

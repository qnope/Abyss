# Task 12: Exploration Confirmation Bottom Sheet

## Summary

Create a bottom sheet widget that shows exploration details and allows the player to confirm sending a scout. Follows the existing bottom sheet pattern used by `BuildingDetailSheet` and `UnitDetailSheet`.

## Implementation Steps

### 1. Create `lib/presentation/widgets/map/exploration_sheet.dart`

Public factory function + private widget:

```dart
void showExplorationSheet(
  BuildContext context, {
  required int targetX,
  required int targetY,
  required int scoutCount,
  required int explorerLevel,
  required bool isEligible,
  required VoidCallback onConfirm,
})
```

**Bottom sheet content:**

1. **Header icon** (64px): Use `Icons.explore` or an appropriate icon
2. **Title:** "Explorer (x, y)"
3. **Info section:**
   - "Coût : 1 éclaireur" with current scout count display
   - "Zone révélée : N×N cellules" (using `RevealAreaCalculator.squareSideForLevel`)
4. **Divider**
5. **Action section:**
   - If `scoutCount > 0 && isEligible`: Enabled "Envoyer" button → calls `onConfirm`
   - If `scoutCount <= 0`: Disabled button + "Aucun éclaireur disponible" message in warning color
   - If `!isEligible`: Disabled button + "Cellule non éligible" message

**Layout:** Follow existing pattern — `showModalBottomSheet(isScrollControlled: true)` with `DraggableScrollableSheet` or simple `Padding` + `Column`.

### 2. Style with theme

- Use `AbyssColors.biolumCyan` for the icon/title (primary color)
- Use `AbyssColors.warning` for unavailability messages
- Use the existing button theme for the confirm button
- Show scout count with `AbyssColors.success` if > 0, `AbyssColors.error` if 0

## Dependencies

- Task 03 (RevealAreaCalculator — for `squareSideForLevel` display)
- Existing theme system

## Test Plan

No dedicated widget test file — verified via manual testing and integration flow.

## Notes

- French labels to match existing UI convention
- The `onConfirm` callback will be wired in Task 13 to execute the `ExploreAction`
- Keep file under 150 lines
- The bottom sheet closes automatically after confirm (caller handles `Navigator.pop`)

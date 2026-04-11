# Task 7 — Handle passage cell tap in game_screen_map_actions

## Summary

When the player taps a revealed passage cell, show an informational bottom sheet with the passage name (e.g., "Passage vers la Faille Alpha"). No other interaction is possible.

## Implementation steps

### 1. Add `passage` case to the switch in `_showCellAction()`

**File:** `lib/presentation/screens/game/game_screen_map_actions.dart`

In the `switch (cell.content)` block, add before the `empty` case:

```dart
case CellContentType.passage:
  final name = cell.passageName ?? 'passage inconnu';
  showCellInfoSheet(context,
    title: 'Passage vers $name',
    message: 'Ce lieu marque un passage vers le niveau inferieur.',
    icon: Icons.blur_circular,
    iconColor: AbyssColors.biolumPurple,
  );
```

### 2. Add import

Add import for `AbyssColors`:

```dart
import '../../theme/abyss_colors.dart';
```

(Check if already imported — it may not be since the map_actions file currently delegates all UI to sheets.)

## Dependencies

- Task 1 (CellContentType.passage and MapCell.passageName)

## Test plan

Manual/visual test:

- Descend to level 2, explore cells near faille positions from level 1.
- Tap a revealed passage cell → verify the info sheet shows "Passage vers la Faille Alpha" (or correct name).
- Verify no collect/fight/attack button appears.

No automated widget test needed here — the `showCellInfoSheet` is already tested, and this is pure dispatch logic.

## Notes

- `Icons.blur_circular` is a Material icon that visually suggests a portal/passage. It's a simple circle with blur, matching the passage overlay aesthetic.
- The message is kept simple: "Ce lieu marque un passage vers le niveau inferieur."
- The `isCollected` check earlier in `_showCellAction` won't trigger for passage cells because they have no `collectedBy` set.

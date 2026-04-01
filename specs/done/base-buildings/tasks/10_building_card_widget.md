# Task 10 — BuildingCard Widget

## Summary

Create the `BuildingCard` widget that displays a building in the list: icon, name, level, with greyed-out styling for unbuilt buildings (level 0).

## Implementation Steps

1. Create `lib/presentation/widgets/building_card.dart`
2. Define the widget:

```dart
class BuildingCard extends StatelessWidget {
  final Building building;
  final VoidCallback onTap;

  const BuildingCard({
    super.key,
    required this.building,
    required this.onTap,
  });
}
```

3. Build method — use a `Card` with `InkWell`:
   - Left: `BuildingIcon` (size: 40, greyscale if level == 0)
   - Center column:
     - Building name (`type.displayName` from extension)
     - Level text: `'Niveau ${building.level}'` or `'Non construit'` if level == 0
   - When level == 0:
     - Card opacity reduced (wrap in `Opacity(opacity: 0.5)`)
     - Level text uses `AbyssColors.disabled`
   - When level > 0:
     - Name text uses building's `type.color`
     - Level text uses `AbyssColors.onSurfaceDim`
   - `onTap` callback triggers on card tap

4. Use `Theme.of(context).textTheme` for typography
5. Use `AbyssColors` for all colors

## Files

| Action | Path |
|--------|------|
| Create | `lib/presentation/widgets/building_card.dart` |

## Dependencies

- Task 02 (Building model)
- Task 08 (BuildingTypeInfo + BuildingTypeColor extensions)
- Task 09 (BuildingIcon widget)

## Test Plan

- Tested in task 15 (`building_card_test.dart`)

## Notes

- Card styling follows existing theme (`abyss_card_theme.dart`: surfaceLight background, cyan border at 0.15 alpha)
- Padding: `EdgeInsets.symmetric(horizontal: 16, vertical: 12)` inside the card
- The `onTap` callback will open the `BuildingDetailSheet` (wired in task 14)
- For the QG, there's no production stat to show (SPEC says "le résumé indique le niveau uniquement")

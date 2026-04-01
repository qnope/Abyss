# Task 12 — BuildingDetailSheet Widget

## Summary

Create the `BuildingDetailSheet` bottom sheet that shows building details (icon, name, level, description) and contains the upgrade section. Follows the pattern of `ResourceDetailSheet`.

## Implementation Steps

1. Create `lib/presentation/widgets/building_detail_sheet.dart`
2. Define a top-level function:

```dart
void showBuildingDetailSheet(
  BuildContext context, {
  required Building building,
  required Map<ResourceType, Resource> resources,
  required List<Building> allBuildings,
  required VoidCallback onUpgrade,
}) {
  showModalBottomSheet<void>(
    context: context,
    builder: (_) => _BuildingDetailSheet(...),
  );
}
```

3. Define `_BuildingDetailSheet` as a private `StatelessWidget`:
   - Top: `BuildingIcon` (size: 64, greyscale if level == 0)
   - Name: `type.displayName` in `headlineSmall` style, colored with `type.color`
   - Level: `'Niveau ${building.level}'` or `'Non construit'` in `bodyMedium`
   - Description: `type.description` in `bodyMedium`, color `onSurfaceDim`, centered
   - Divider
   - Bottom: `UpgradeSection` widget (from task 13)

4. Padding: `EdgeInsets.fromLTRB(24, 0, 24, 32)` (same as ResourceDetailSheet)
5. Use `Column` with `mainAxisSize: MainAxisSize.min`

## Files

| Action | Path |
|--------|------|
| Create | `lib/presentation/widgets/building_detail_sheet.dart` |

## Dependencies

- Task 02 (Building model)
- Task 08 (BuildingTypeInfo + BuildingTypeColor extensions)
- Task 09 (BuildingIcon widget)
- Task 13 (UpgradeSection widget)

## Test Plan

- Tested in task 15 (`building_detail_sheet_test.dart`)

## Notes

- Follows `ResourceDetailSheet` pattern exactly (top-level `show*` function + private widget class)
- The `onUpgrade` callback is passed down to `UpgradeSection` — when called, the parent (GameScreen) will mutate the game state and call `setState`, which rebuilds the sheet via Navigator pop + reopen
- BottomSheet uses the theme's bottom sheet config (deepNavy background, drag handle visible)

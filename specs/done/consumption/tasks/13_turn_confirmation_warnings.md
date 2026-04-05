# Task 13: Update TurnConfirmationDialog with Warnings

## Summary

Add deficit warnings to the turn confirmation dialog, showing which buildings will be deactivated and which units will die if the player proceeds.

## Implementation Steps

### 1. Update `lib/presentation/widgets/turn_confirmation_dialog.dart`

Add new parameters to `showTurnConfirmationDialog` and `_TurnConfirmationDialog`:
```dart
Future<bool> showTurnConfirmationDialog(
  BuildContext context, {
  required Map<ResourceType, int> production,
  Map<ResourceType, int> consumption = const {},        // NEW
  List<BuildingType> buildingsToDeactivate = const [],  // NEW
  Map<UnitType, int> unitsToLose = const {},            // NEW
})
```

Update the dialog build:
- Keep existing production display
- After production list, if `consumption` has entries for energy or algae, show a "Consommation" section:
  - For each resource with consumption: show `-Y` in red
- If `buildingsToDeactivate` is not empty, show a warning section:
  - Title: "Batiments desactives" with `AbyssColors.warning` icon
  - List each building with its `displayName` (use `BuildingTypeInfo` extension)
- If `unitsToLose` is not empty, show a warning section:
  - Title: "Unites perdues" with `AbyssColors.error` icon
  - List each unit type with count lost (e.g., "Eclaireur: -5")

### 2. Imports to add
- `building_type.dart`, `unit_type.dart`
- `building_type_extensions.dart`, `unit_type_extensions.dart`

## Dependencies

- No domain logic dependencies (purely presentational)
- Uses extensions from `presentation/extensions/`

## Test Plan

- File: `test/presentation/widgets/turn_confirmation_dialog_test.dart` (update)
- See Task 15

## Notes

- New parameters have defaults, so existing callers don't break
- Keep under 150 lines — if too long, extract the warning section into a helper widget
- Use `AbyssColors.warning` for deactivation warnings and `AbyssColors.error` for unit losses

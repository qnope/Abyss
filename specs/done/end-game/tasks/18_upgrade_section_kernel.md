# Task 18: Update `UpgradeSection` for kernel capture requirement

## Summary

Pass the volcanic kernel capture state through the building UI chain so the upgrade section can display the "kernel not captured" requirement.

## Implementation Steps

### 1. Edit `lib/presentation/widgets/building/building_detail_sheet.dart`

Add parameter to `showBuildingDetailSheet` and `_BuildingDetailSheet`:
```dart
bool isVolcanicKernelCaptured = false,
```

Pass it through to `UpgradeSection`.

### 2. Edit `lib/presentation/widgets/building/upgrade_section.dart`

Add field:
```dart
final bool isVolcanicKernelCaptured;
```

Add constructor parameter (with default `false`).

Update `build()` — pass to `calculator.checkUpgrade()`:
```dart
final check = calculator.checkUpgrade(
  type: building.type,
  currentLevel: building.level,
  resources: resources,
  allBuildings: allBuildings,
  capturedBaseTypes: capturedBaseTypes,
  isVolcanicKernelCaptured: isVolcanicKernelCaptured,
);
```

After the `_capturedBaseRow`, add:
```dart
if (check.missingCapturedKernel)
  _capturedKernelRow(textTheme),
```

Add new method:
```dart
Widget _capturedKernelRow(TextTheme textTheme) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        const Icon(Icons.lock, size: 16, color: AbyssColors.error),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Noyau Volcanique capture requis',
            style: const TextStyle(color: AbyssColors.error),
          ),
        ),
      ],
    ),
  );
}
```

### 3. Edit `lib/presentation/screens/game/game_screen_actions.dart`

In `showBuildingDetailAction`, pass `isVolcanicKernelCaptured`:

```dart
showBuildingDetailSheet(
  context,
  building: building,
  resources: human.resources,
  allBuildings: human.buildings,
  capturedBaseTypes: game.capturedBaseTypesOf(human.id),
  isVolcanicKernelCaptured: game.isVolcanicKernelCapturedBy(human.id),
  onUpgrade: () { ... },
);
```

## Dependencies

- Task 8: `UpgradeCheck.missingCapturedKernel` field
- Task 9: `Game.isVolcanicKernelCapturedBy()` method

## Test Plan

- **File**: `test/presentation/widgets/building/upgrade_section_test.dart` (add tests)
- Test: when `missingCapturedKernel` is true, shows "Noyau Volcanique capture requis" text
- Test: when `missingCapturedKernel` is false, does NOT show the kernel requirement row
- Test: upgrade button is disabled when kernel is not captured for volcanic kernel building
- **File**: `test/presentation/widgets/building/building_detail_sheet_test.dart` (add tests)
- Test: passes `isVolcanicKernelCaptured` through to upgrade section

## Notes

- The `isVolcanicKernelCaptured` parameter defaults to `false`, so existing callers are unaffected
- For non-volcanic-kernel buildings, `missingCapturedKernel` will always be `false` (the calculator only checks it for `BuildingType.volcanicKernel`)

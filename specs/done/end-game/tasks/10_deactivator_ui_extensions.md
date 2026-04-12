# Task 10: Update building deactivator and UI extensions

## Summary

Add the volcanic kernel building to the deactivation priority list and provide UI display metadata (name, description, icon, color).

## Implementation Steps

### 1. Edit `lib/domain/building/building_deactivator.dart`

Add `BuildingType.volcanicKernel` to the `_priority` list. It should be disabled before HQ but after the coral citadel (high priority to keep active):

```dart
static const List<BuildingType> _priority = [
  BuildingType.headquarters,     // 0 - never disabled
  BuildingType.volcanicKernel,   // 1 - second to last disabled
  BuildingType.coralCitadel,     // 2
  // ... rest unchanged
];
```

### 2. Edit `lib/presentation/extensions/building_type_extensions.dart`

In `BuildingTypeColor`, add:
```dart
BuildingType.volcanicKernel => AbyssColors.warning,
```

In `BuildingTypeInfo.displayName`, add:
```dart
BuildingType.volcanicKernel => 'Noyau Volcanique',
```

In `BuildingTypeInfo.description`, add:
```dart
BuildingType.volcanicKernel =>
  'Le coeur brulant des abysses. '
  'Construisez-le au niveau 10 pour remporter la victoire.',
```

In `BuildingTypeInfo.iconPath`, add:
```dart
BuildingType.volcanicKernel => 'assets/icons/terrain/volcanic_kernel.svg',
```

Uses the same SVG as the map cell (per SPEC US-3).

## Dependencies

- Task 3: `BuildingType.volcanicKernel` must exist
- Task 4: `build_runner` must have been run

## Test Plan

- **File**: `test/domain/building/building_deactivator_test.dart` (add test)
- Test: `volcanicKernel` is in the priority list
- Test: with insufficient energy, `volcanicKernel` is NOT among the first buildings disabled (it's high priority)
- **File**: `test/presentation/extensions/building_type_extensions_test.dart` (add tests)
- Test: `BuildingType.volcanicKernel.color` returns `AbyssColors.warning`
- Test: `BuildingType.volcanicKernel.displayName` returns `'Noyau Volcanique'`
- Test: `BuildingType.volcanicKernel.iconPath` is not empty

## Notes

- The `warning` color (orange/red) fits the volcanic theme
- Using the terrain SVG for the building icon avoids duplicating assets

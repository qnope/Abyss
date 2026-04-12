# Task 1: Add `volcanicKernel` cell content type

## Summary

Add a new `volcanicKernel` value to the `CellContentType` enum and update the presentation extensions to support it.

## Implementation Steps

### 1. Edit `lib/domain/map/cell_content_type.dart`

Add a new enum value:

```dart
@HiveField(6) volcanicKernel,
```

### 2. Edit `lib/presentation/extensions/cell_content_type_extensions.dart`

In `CellContentTypeExtensions.label`, add:

```dart
CellContentType.volcanicKernel => 'Noyau Volcanique',
```

In `CellContentTypeExtensions.svgPath`, add:

```dart
CellContentType.volcanicKernel => 'assets/icons/terrain/volcanic_kernel.svg',
```

### 3. Fix any exhaustive switch statements

Search for `switch` on `CellContentType` across the codebase. Key files:
- `lib/presentation/screens/game/game_screen_map_actions.dart` — `_showCellAction` (add a placeholder case, will be completed in task 14)
- `lib/presentation/widgets/map/game_map_view.dart` or similar map rendering widgets

For now, add `case CellContentType.volcanicKernel:` that delegates to the same handling as an empty cell or shows a placeholder info sheet.

## Dependencies

- None (first task)

## Test Plan

- **File**: `test/domain/map/cell_content_type_test.dart`
- Verify `CellContentType.volcanicKernel` exists
- Verify `CellContentType.values` contains 7 values
- Verify extensions return correct label and svgPath

## Notes

- The SVG asset already exists at `assets/icons/terrain/volcanic_kernel.svg`
- `build_runner` will be run in task 4 after all Hive model changes are done

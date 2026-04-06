# Task 01 — Update max visible cells constant

## Summary

Change the `_maxVisibleCells` constant from `4.0` to `1.0` in `GameMapView` so the player can zoom in until a single cell fills the screen.

## Implementation Steps

1. Open `lib/presentation/widgets/map/game_map_view.dart`
2. On line 28, change:
   ```dart
   static const _maxVisibleCells = 4.0;
   ```
   to:
   ```dart
   static const _maxVisibleCells = 1.0;
   ```

That's the only code change needed. The `maxScale` formula (`screenWidth / (_maxVisibleCells * cellSize)`) will automatically compute a 4× larger max scale, allowing zoom to a single cell.

## Files Modified

| File | Change |
|------|--------|
| `lib/presentation/widgets/map/game_map_view.dart` | `_maxVisibleCells`: `4.0` → `1.0` |

## Dependencies

- None (standalone constant change).

## Test Plan

- Covered by Task 02 (new unit/widget tests for zoom bounds).

## Notes

- `_defaultVisibleCells` (8.0) stays unchanged — the opening zoom is unaffected.
- `minScale` (full map visible) is unchanged.

# Task 01 — Add `isCollected` flag to MapCell

## Summary

Add a boolean `isCollected` field to `MapCell` to track whether a treasure (resourceBonus or ruins) has already been collected by the player.

## Implementation Steps

1. **Edit `lib/domain/map/map_cell.dart`**
   - Add `@HiveField(6) final bool isCollected;` field
   - Add `this.isCollected = false` to the constructor with a default value
   - Add `bool? isCollected` parameter to `copyWith` method
   - Pass `isCollected: isCollected ?? this.isCollected` in the returned MapCell

2. **Regenerate Hive adapter**
   - Run `dart run build_runner build --delete-conflicting-outputs`
   - Verify `lib/domain/map/map_cell.g.dart` includes the new field at index 6

## Dependencies

- None (this is a foundation task)

## Test Plan

- **File:** `test/domain/map/map_cell_test.dart`
- Default `isCollected` is `false`
- `copyWith(isCollected: true)` returns a cell with `isCollected == true`
- `copyWith()` without `isCollected` preserves the original value

## Notes

- HiveField index 6 is the next available (0–5 are taken)
- Default `false` ensures backward compatibility with existing saves

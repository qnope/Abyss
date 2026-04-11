# Task 3 — Update TransitionBasePlacer to skip reserved positions

## Summary

Add a `reservedIndices` parameter to `TransitionBasePlacer.place()` so that passage positions are excluded from transition base candidate locations.

## Implementation steps

### 1. Add parameter to `place()`

**File:** `lib/domain/map/transition_base_placer.dart`

```dart
static void place({
  required List<MapCell> cells,
  required int width,
  required int height,
  required int baseX,
  required int baseY,
  required int level,
  required Random random,
  Set<int> reservedIndices = const {},  // NEW
})
```

### 2. Pass to `_placeAll()`

Add `reservedIndices` parameter to `_placeAll()` and forward it.

### 3. Filter in `_pickCell()`

In `_pickCell()`, add `reservedIndices` parameter and add filter:

```dart
final valid = candidates.where((idx) {
  if (reservedIndices.contains(idx)) return false;  // NEW
  final x = idx % width, y = idx ~/ width;
  if (x == baseX && y == baseY) return false;
  ...
}).toList();
```

## Dependencies

- Task 1 (passage content type exists, though not strictly required for this change)

## Test plan

**File:** `test/domain/map/transition_base_placer_test.dart`

Add test:

```
test('reserved indices are never chosen for transition base placement')
```

- Place transition bases on level 1 with a known seed.
- Determine the positions where failles land (without reservation).
- Re-run with those positions in `reservedIndices`.
- Verify no transition base is placed at any reserved position.
- Verify the total count of placed bases may be less than 4 (if all candidates in a quadrant are reserved).

Existing tests must still pass (default empty `reservedIndices`).

## Notes

- This prevents a transition base (e.g., cheminee on level 2) from being placed at a position reserved for a passage from level 1.

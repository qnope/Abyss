# Task 2 — Update ContentPlacer to skip reserved positions

## Summary

Add a `reservedIndices` parameter to `ContentPlacer.place()` so that passage positions from the level above are excluded from content generation.

## Implementation steps

### 1. Add parameter to `place()`

**File:** `lib/domain/map/content_placer.dart`

Add optional parameter to `ContentPlacer.place()`:

```dart
static void place({
  required List<MapCell> cells,
  required int width,
  required int height,
  required int baseX,
  required int baseY,
  required Random random,
  Set<int> reservedIndices = const {},  // NEW
})
```

### 2. Exclude reserved indices from eligible list

In `_buildEligibleIndices()`, add `reservedIndices` parameter and filter:

```dart
static List<int> _buildEligibleIndices(
  List<MapCell> cells,
  int width, int height,
  int baseX, int baseY,
  Set<int> reservedIndices,  // NEW
) {
  final result = <int>[];
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final dist = max((x - baseX).abs(), (y - baseY).abs());
      if (dist <= 2) continue;
      final idx = y * width + x;
      if (reservedIndices.contains(idx)) continue;  // NEW
      result.add(idx);
    }
  }
  return result;
}
```

Pass `reservedIndices` from `place()` to `_buildEligibleIndices()`.

## Dependencies

- Task 1 (passage content type exists, though not strictly required for this change)

## Test plan

**File:** `test/domain/map/content_placer_test.dart`

Add test:

```
test('reserved indices have no content placed')
```

- Create cells, call `ContentPlacer.place()` with `reservedIndices: {50, 100, 200}`.
- Verify all three reserved cells remain `CellContentType.empty` after placement.
- Run across multiple seeds to confirm.

Existing tests must still pass (they don't pass `reservedIndices`, so the default empty set applies).

## Notes

- The `_adjustMonsterCount` method uses `eligible` list. Since reserved indices are excluded from `eligible`, forced monster placement will also respect reservations.

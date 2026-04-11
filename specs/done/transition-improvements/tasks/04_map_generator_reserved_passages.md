# Task 4 — Update MapGenerator to accept and process reserved passages

## Summary

Extend `MapGenerator.generate()` to accept a map of reserved passage positions, forward the exclusion indices to `ContentPlacer` and `TransitionBasePlacer`, and mark reserved cells as `passage` content type after generation.

## Implementation steps

### 1. Add parameter to `generate()`

**File:** `lib/domain/map/map_generator.dart`

Add import for `GridPosition`. Add optional parameter:

```dart
static MapGenerationResult generate({
  int? seed,
  int level = 1,
  Map<GridPosition, String> reservedPassages = const {},  // NEW
})
```

### 2. Compute reserved index set

Inside `generate()`, after computing `baseX`/`baseY`:

```dart
final reservedIndices = {
  for (final pos in reservedPassages.keys)
    pos.y * _size + pos.x,
};
```

### 3. Forward to ContentPlacer and TransitionBasePlacer

Pass `reservedIndices: reservedIndices` to both `ContentPlacer.place()` and `TransitionBasePlacer.place()`.

### 4. Mark passage cells

Add new static method `_markPassages()` called after `_clearBaseContent()`:

```dart
static void _markPassages(
  List cells, int baseX, int baseY,
  Map<GridPosition, String> reservedPassages,
) {
  for (final entry in reservedPassages.entries) {
    final x = entry.key.x, y = entry.key.y;
    if (x == baseX && y == baseY) continue; // base takes priority
    final i = y * _size + x;
    cells[i] = cells[i].copyWith(
      content: CellContentType.passage,
      passageName: entry.value,
    );
  }
}
```

Call order in `generate()`:
1. TerrainGenerator
2. ContentPlacer (with reservedIndices)
3. TransitionBasePlacer (with reservedIndices)
4. `_clearBaseContent`
5. `_markPassages` (NEW)

## Dependencies

- Task 1 (CellContentType.passage and MapCell.passageName)
- Task 2 (ContentPlacer accepts reservedIndices)
- Task 3 (TransitionBasePlacer accepts reservedIndices)

## Test plan

**File:** `test/domain/map/map_generator_test.dart`

Add tests:

```
test('reserved passages become passage cells with correct name')
```

- Call `MapGenerator.generate(seed: 42, level: 2, reservedPassages: {GridPosition(x: 5, y: 5): 'Faille Alpha'})`.
- Verify `cellAt(5, 5).content == CellContentType.passage`.
- Verify `cellAt(5, 5).passageName == 'Faille Alpha'`.

```
test('reserved passage at base position is skipped')
```

- Generate with a known seed, note the baseX/baseY.
- Re-generate with a reserved passage at that exact position.
- Verify the base cell remains `CellContentType.empty`.

```
test('no content or transition base placed at reserved positions')
```

- Generate with several reserved positions.
- Verify none of them have `monsterLair`, `resourceBonus`, `ruins`, or `transitionBase` content.

Existing tests must still pass (default empty `reservedPassages`).

## Notes

- The base cell clearing happens before passage marking. If a passage coincides with the base, the base wins (passage is skipped).

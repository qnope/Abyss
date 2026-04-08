# Task 1 — Update `RevealAreaCalculator` to odd-only, centered reveals

## Summary
Switch the reveal area logic to use **only odd-sized squares** centered on the
target. This kills the asymmetric "bottom-left anchored" branch used today for
even sides and updates the level→side table to the new progression
(3, 3, 5, 5, 7, 9).

This task covers both the production code and the calculator unit tests so
that the layer is shipped consistent.

## Implementation steps

### 1.1 — Update the level→side table
File: `lib/domain/map/reveal_area_calculator.dart`

Replace the body of `RevealAreaCalculator.squareSideForLevel(int explorerLevel)`
with the new mapping:

```dart
return switch (explorerLevel) {
  0 => 3,
  1 => 3,
  2 => 5,
  3 => 5,
  4 => 7,
  5 => 9,
  _ => 3,
};
```

The fallback for an out-of-range level becomes `3` (smallest valid odd size).

### 1.2 — Simplify `cellsToReveal` (centered only)
File: `lib/domain/map/reveal_area_calculator.dart`

Drop the `if (side.isEven) { … }` branch entirely. Since every side is now
odd, the target is always exactly at the center. The new body should be:

```dart
final side = squareSideForLevel(explorerLevel);
final half = side ~/ 2;
final startX = targetX - half;
final startY = targetY - half;

final positions = <GridPosition>[];
for (var dy = 0; dy < side; dy++) {
  for (var dx = 0; dx < side; dx++) {
    final x = startX + dx;
    final y = startY + dy;
    if (x >= 0 && x < mapWidth && y >= 0 && y < mapHeight) {
      positions.add(GridPosition(x: x, y: y));
    }
  }
}
return positions;
```

Keep the file under 150 LoC (it will shrink, not grow).

### 1.3 — Rewrite `reveal_area_calculator_side_test.dart`
File: `test/domain/map/reveal_area_calculator_side_test.dart`

Update each level test to the new expected sides:

| Level | Expected side |
|-------|---------------|
| 0     | 3             |
| 1     | 3             |
| 2     | 5             |
| 3     | 5             |
| 4     | 7             |
| 5     | 9             |

Add one test for an out-of-range level (e.g. `-1` or `99`) that asserts the
fallback is `3`.

### 1.4 — Rewrite `reveal_area_calculator_cells_test.dart`
File: `test/domain/map/reveal_area_calculator_cells_test.dart`

Restructure the file:

- **Delete** the group `cellsToReveal - even squares (target at bottom-left)`.
- Replace the `cellsToReveal - odd squares (target at center)` group with:
  - `level 0 (3x3) at (5,5) reveals 9 cells, range (4,4)..(6,6)`
  - `level 2 (5x5) at (10,10) reveals 25 cells, range (8,8)..(12,12)`
  - `level 4 (7x7) at (10,10) reveals 49 cells, range (7,7)..(13,13)`
  - `level 5 (9x9) at (10,10) reveals 81 cells, range (6,6)..(14,14)`
- Add a **strict centering** group: for each odd side, assert that the number
  of cells strictly to the left of `targetX` equals the number strictly to the
  right (and same for above/below). A small helper `_assertCentered(positions,
  target)` keeps the test concise.
- Update the **boundary handling** group to the new sizes:
  - `corner (0,0) level 0 reveals 4 cells` (the bottom-left quarter of the
    3x3 area: `(0,0)`, `(1,0)`, `(0,1)`, `(1,1)`).
  - `right edge (19,10) level 1 reveals 6 cells` — same expectation as today
    (still a 3x3 square clipped on the right).
  - `far corner (19,19) level 0 reveals 4 cells` (cells `(18,18)`, `(19,18)`,
    `(18,19)`, `(19,19)`).
- Update the `total cell count on open map` table:
  ```dart
  final expected = {0: 9, 1: 9, 2: 25, 3: 25, 4: 49, 5: 81};
  ```

Keep the file under 150 LoC by sharing the `_reveal` and `_pos` helpers that
already exist.

## Dependencies
- **Internal:** none — this is the foundation task.
- **External:** none.

## Test plan
Run after the changes:

```
flutter analyze
flutter test test/domain/map/reveal_area_calculator_side_test.dart
flutter test test/domain/map/reveal_area_calculator_cells_test.dart
```

Both files must pass with zero failures and `flutter analyze` must report no
errors or warnings. Note that running the **full** test suite will fail at
this stage because `Player.withBase` and the exploration resolver tests still
expect the old sizes — that is the responsibility of Task 2.

## Notes / design considerations
- The `_ => 3` fallback is intentional: any unexpected level should still
  produce a valid, centered square (smallest one) rather than crash.
- Keep `RevealAreaCalculator` a static utility — do not introduce instances or
  an `initialize()` method (project rule).
- Per the user decision, the initial base reveal is implemented in Task 2 by
  passing `explorerLevel: 2` (5x5) — no new API surface is added to the
  calculator in this task.

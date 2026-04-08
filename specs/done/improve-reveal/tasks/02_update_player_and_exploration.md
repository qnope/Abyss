# Task 2 — Update `Player.withBase` and exploration tests

## Summary
Adapt the consumers of `RevealAreaCalculator` to the new odd-sided progression
delivered in Task 1:

- `Player.withBase` must reveal a **5x5** area centered on the base instead
  of the current 2x2. Per the design decision, this is implemented by passing
  `explorerLevel: 2` to `RevealAreaCalculator.cellsToReveal` (no new API).
- All exploration / player tests that hard-coded the old cell counts must be
  refreshed with the new expectations.

## Implementation steps

### 2.1 — Switch base initialization to a 5x5 reveal
File: `lib/domain/game/player.dart`

In `_initialRevealedCells`, change `explorerLevel: 0` to `explorerLevel: 2`:

```dart
return RevealAreaCalculator.cellsToReveal(
  targetX: baseX,
  targetY: baseY,
  explorerLevel: 2, // 5x5 initial vision around the base
  mapWidth: mapWidth,
  mapHeight: mapHeight,
);
```

Add a brief inline comment explaining that level 2 yields a 5x5 square so the
intent is not lost on future readers. No other change to `Player` is needed —
the existing `revealedCellsList` storage already supports any number of
cells.

### 2.2 — Refresh `player_test.dart`
File: `test/domain/game/player_test.dart`

In the `Player.withBase reveal seeding` group:

- Change the `expected` calculation to use `explorerLevel: 2`.
- Add an explicit assertion that `p.revealedCells.length == 25` so the test
  fails if `_initialRevealedCells` is ever pointed back at level 0.
- Add a strict-centering assertion (or reuse the helper introduced in Task
  1's calculator tests if it is exposed) that verifies the base is exactly at
  the center of the revealed square: 2 cells in each cardinal direction.
- Add one new test that exercises the natural truncation: build a player with
  `baseX: 1`, `baseY: 1`, `mapWidth/Height: 20`, and assert that the revealed
  set contains exactly the in-bounds cells of the 5x5 window
  (`x in 0..3`, `y in 0..3` → 16 cells), with no shifting.

### 2.3 — Update `exploration_resolver_level_test.dart`
File: `test/domain/map/exploration_resolver_level_test.dart`

The two existing tests must be updated:

- `level 0 reveals 2x2 area (4 cells)` → rename and update to
  `level 0 reveals 3x3 area (9 cells)`, expect `newCellsRevealed == 9`.
- `level 1 reveals 3x3 area (9 cells)` → keep the cell count (still 9) but
  update the test name/comment for consistency, since level 1 still resolves
  to a 3x3 square in the new table.

Add coverage for at least one larger level to lock in the new progression,
e.g. `level 4 reveals 7x7 area (49 cells)`.

### 2.4 — Update `exploration_resolver_test.dart`
File: `test/domain/map/exploration_resolver_test.dart`

- The first test (`reveals expected cells on the player`) still computes its
  expectation from `RevealAreaCalculator.cellsToReveal(... explorerLevel: 0
  ...)`. Because the calculator now returns 9 cells for level 0, the
  expectation is automatically updated, but verify the assertion still
  matches `expected.length` (should now be 9).
- `already revealed cells are not recounted`: the comment says "Level 0
  reveals a 2x2 area, one of which is pre-seeded". With level 0 = 3x3 = 9
  cells and 1 pre-seeded cell, the new expected count is **8**. Update the
  assertion and the comment.
- `boundary exploration near edge counts only in-bounds cells`: target
  `(9,0)` with level 0 = 3x3 reveals cells `(8,0)`, `(9,0)`, `(8,1)`, `(9,1)`
  (the `(10,*)` and `(*,−1)` cells are out of bounds). Update the
  assertion to `newCellsRevealed == 4` and add a containment check on the
  expected set.

### 2.5 — Update `exploration_resolver_multi_test.dart`
File: `test/domain/map/exploration_resolver_multi_test.dart`

- `two orders resolved independently`: both orders are level 0 explorations
  on disjoint targets `(2,2)` and `(7,7)`. Update both expected counts from
  `4` to `9`.
- `re-revealing already revealed cells yields zero new`: the pre-seeded set
  must now cover the **whole 3x3 square** around `(3,3)`. Replace the
  hard-coded 4-cell set with the full 9-cell set:
  `{(2,2),(3,2),(4,2),(2,3),(3,3),(4,3),(2,4),(3,4),(4,4)}`. Keep the
  expectation at `0`.
- `finds notable content in reveal area`: target `(5,5)` level 0 = 3x3 still
  contains `(5,4)`, so the existing expectation holds. No change required —
  but double-check the assertion still passes after Task 1 by running the
  test.

## Dependencies
- **Internal:** depends on **Task 1** — the calculator must already return
  odd sides, otherwise these tests will fail in confusing ways.
- **External:** none.

## Test plan
Run after the changes:

```
flutter analyze
flutter test test/domain/game/player_test.dart
flutter test test/domain/map/exploration_resolver_test.dart
flutter test test/domain/map/exploration_resolver_level_test.dart
flutter test test/domain/map/exploration_resolver_multi_test.dart
flutter test
```

The full `flutter test` must now pass at 100 %, and `flutter analyze` must
report no warnings.

Manual smoke test: launch the app, create a new game and visually confirm:
1. The base sits exactly in the center of the revealed square at start.
2. Sending an explorer reveals a square centered on the target cell.

## Notes / design considerations
- Do **not** introduce a separate "initial base side" constant. The agreed
  approach is to pass `explorerLevel: 2` directly. If, later on, the design
  requires decoupling the two, that will be its own change.
- Keep test files under 150 LoC. If a file gets close to the limit after
  adding the new assertions, extract small helpers (e.g. `_expectCentered`)
  inside the file rather than across files.
- Per the project rules, no `initialize()` methods anywhere — `Player` is
  already constructor-only and must remain so.

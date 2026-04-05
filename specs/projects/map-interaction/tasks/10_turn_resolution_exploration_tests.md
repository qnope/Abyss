# Task 10: Tests for Exploration in Turn Resolution

## Summary

Write unit tests for `ExplorationResolver` and verify `TurnResolver` integrates exploration correctly.

## Implementation Steps

### 1. Create `test/domain/map/exploration_resolver_test.dart`

### Test Setup

Build a `Game` with:
- A 10×10 `GameMap` with base at (5,5), initial reveal radius 2 (5×5 revealed area)
- Explorer tech branch at configurable research level
- Pending exploration orders pre-populated

### Test Cases

#### Group: `single exploration`

- **Reveals cells correctly:** 1 pending order at (7,5), explorer level 0 (2×2) → 4 new cells revealed (or fewer if some already revealed). Check that `map.cellAt(x,y).isRevealed == true` for positions in reveal area.
- **Returns correct result:** Result has `newCellsRevealed == 4`, `target == (7,5)`.
- **Clears pending list:** After resolve, `game.pendingExplorations` is empty.

#### Group: `explorer level impact`

- **Level 0 reveals 2×2:** Pending at (8,8), level 0 → 4 cells revealed
- **Level 1 reveals 3×3:** Same target, level 1 → 9 cells revealed
- **Level 3 reveals 5×5:** Same target, level 3 → 25 cells revealed

#### Group: `multiple explorations`

- **Two orders resolved independently:** Orders at (7,5) and (3,5), level 0 → 2 results, each with their own cell count.
- **Overlapping reveal areas:** Two orders close together → overlapping cells not double-counted (total new < sum of individuals).

#### Group: `idempotency`

- **Re-revealing cells:** Exploration targeting already-revealed area → `newCellsRevealed == 0`, no errors.
- **Mixed revealed/unrevealed:** Some cells already revealed → only new cells counted.

#### Group: `notable content`

- **Finds monster lairs:** Place a monsterLair in reveal area → `notableContent` contains `CellContentType.monsterLair`.
- **Finds ruins:** Place ruins → `notableContent` contains `CellContentType.ruins`.
- **Empty cells not listed:** Empty cells not in `notableContent`.

#### Group: `boundary handling`

- **Exploration near map edge:** Order at (0,0), level 1 (3×3) → only in-bounds cells revealed, no crash.

#### Group: `integration with TurnResolver`

- **Full turn with exploration:** Add pending exploration, call `TurnResolver().resolve(game)` → `result.explorations` is not empty, cells revealed, pending cleared.

## Dependencies

- Task 09 (ExplorationResolver, ExplorationResult, TurnResult update)

## Notes

- Build test maps manually with explicit cell states for deterministic tests
- For `TurnResolver` integration test, also verify that other turn steps (production, consumption) still work correctly alongside exploration

# Task 06: Tests for CellEligibilityChecker

## Summary

Write unit tests for `CellEligibilityChecker` covering all eligibility rules.

## Implementation Steps

### 1. Create `test/domain/map/cell_eligibility_checker_test.dart`

### Test Setup

Create a small test map (e.g., 5×5) with controlled reveal state:
- Base at (2,2)
- Reveal a known set of cells (e.g., Chebyshev distance ≤ 1 from base → 3×3 area around base)
- Use `MapCell(terrain: TerrainType.plain, isRevealed: true/false)` to build cells

### Test Cases

#### Group: `revealed cells`

- **Revealed cell is eligible:** A revealed cell at (1,1) → `isEligible` returns `true`
- **Revealed cell at map edge:** A revealed cell at (0,0) → `isEligible` returns `true`

#### Group: `base cell`

- **Base cell is not eligible:** `isEligible(map, 2, 2)` → returns `false` (even though it's revealed)

#### Group: `unrevealed cells adjacent to revealed`

- **Unrevealed cell adjacent to revealed:** Cell at (0,1) unrevealed but neighbor (1,1) is revealed → `isEligible` returns `true`
- **Unrevealed cell diagonally adjacent:** Cell at (0,0) unrevealed but diagonal neighbor (1,1) is revealed → `isEligible` returns `true`

#### Group: `unrevealed cells not adjacent to revealed`

- **Unrevealed cell far from revealed:** Cell at (4,4) with no revealed neighbors → `isEligible` returns `false`
- **Unrevealed cell surrounded by unrevealed:** All neighbors unrevealed → returns `false`

#### Group: `boundary conditions`

- **Corner cell (0,0):** Only has 3 neighbors — doesn't crash, checks valid neighbors only
- **Edge cell (0,2):** Has 5 neighbors — checks them correctly

## Dependencies

- Task 05 (CellEligibilityChecker)
- Existing: `GameMap`, `MapCell`, `TerrainType`, `CellContentType`

## Notes

- Build test maps using `GameMap(width: 5, height: 5, cells: [...], playerBaseX: 2, playerBaseY: 2, seed: 0)`
- Use `MapCell(terrain: TerrainType.plain, content: CellContentType.empty, isRevealed: ...)` for each cell

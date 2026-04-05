# Task 04: Tests for RevealAreaCalculator

## Summary

Write unit tests for `RevealAreaCalculator` covering all explorer levels, even/odd square alignment, and boundary handling.

## Implementation Steps

### 1. Create `test/domain/map/reveal_area_calculator_test.dart`

### Test Cases

#### Group: `squareSideForLevel`

| Test | Input | Expected |
|------|-------|----------|
| level 0 returns 2 | `squareSideForLevel(0)` | 2 |
| level 1 returns 3 | `squareSideForLevel(1)` | 3 |
| level 2 returns 4 | `squareSideForLevel(2)` | 4 |
| level 3 returns 5 | `squareSideForLevel(3)` | 5 |
| level 4 returns 7 | `squareSideForLevel(4)` | 7 |
| level 5 returns 9 | `squareSideForLevel(5)` | 9 |

#### Group: `cellsToReveal` — even squares (target at bottom-left)

- **Level 0 (2×2):** target=(5,5) on 20×20 → reveals (5,4), (6,4), (5,5), (6,5) → 4 cells. Target (5,5) is at bottom-left.
- **Level 2 (4×4):** target=(10,10) on 20×20 → reveals 16 cells. startX=10, startY=7 → x∈[10,13], y∈[7,10]. Target at bottom-left.

#### Group: `cellsToReveal` — odd squares (target at center)

- **Level 1 (3×3):** target=(5,5) → reveals 9 cells centered on (5,5). x∈[4,6], y∈[4,6].
- **Level 3 (5×5):** target=(10,10) → reveals 25 cells. x∈[8,12], y∈[8,12].

#### Group: `cellsToReveal` — boundary handling

- **Corner exploration:** target=(0,0), level 0 (2×2) → startX=0, startY=-1. Only cells at y≥0 are included → (0,0), (1,0) → 2 cells.
- **Edge exploration:** target=(19,10), level 1 (3×3) → x goes up to 20, clamped. Reveals cells at x∈[18,19] only → 6 cells instead of 9.
- **Far corner:** target=(19,19), level 0 (2×2) → startX=19, startY=18 → (19,18), (19,19) → only cells within bounds.

#### Group: `cellsToReveal` — total cell count on open map

- Verify cell count = side² when target is far from edges (e.g., center of 20×20):
  - Level 0: 4, Level 1: 9, Level 2: 16, Level 3: 25, Level 4: 49, Level 5: 81

## Dependencies

- Task 03 (RevealAreaCalculator)

## Notes

- Use `expect(positions.length, ...)` and `expect(positions, containsAll([...]))` for position verification.
- Verify target cell itself is always included in the result.

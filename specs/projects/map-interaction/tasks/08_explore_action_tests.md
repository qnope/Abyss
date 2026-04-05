# Task 08: Tests for ExploreAction

## Summary

Write unit tests for `ExploreAction` covering validation and execution.

## Implementation Steps

### 1. Create `test/domain/action/explore_action_test.dart`

### Test Setup

Create a helper that builds a `Game` with:
- A small `GameMap` (e.g., 5×5) with known revealed cells
- Base at (2,2), cells at Chebyshev distance ≤ 2 revealed
- Scouts available: configurable count (default 3)

### Test Cases

#### Group: `validate`

- **Succeeds with scouts and eligible cell:** 3 scouts, target revealed cell (1,1) → `ActionResult.success()`
- **Succeeds with unrevealed but adjacent cell:** target unrevealed cell adjacent to revealed → success
- **Fails with no map:** `game.gameMap = null` → failure with "Carte non générée"
- **Fails with 0 scouts:** 0 scouts → failure with "Aucun éclaireur disponible"
- **Fails with ineligible cell:** target far unrevealed cell (4,4) with no revealed neighbors → failure with "Cellule non éligible"
- **Fails on base cell:** target=(2,2) (base) → failure

#### Group: `execute`

- **Consumes 1 scout:** Start with 3 scouts → execute → 2 scouts remaining
- **Adds exploration order:** `game.pendingExplorations` gains 1 entry with correct target position
- **Multiple executions:** Execute twice with different targets → 1 scout left, 2 pending explorations

#### Group: `via ActionExecutor`

- **Full flow:** `ActionExecutor().execute(ExploreAction(...), game)` → validates then executes → success, scout consumed, order added
- **Validation failure prevents execution:** 0 scouts → failure, no order added, count unchanged

## Dependencies

- Task 07 (ExploreAction)
- Task 01, 02 (model + game field)
- Task 05 (CellEligibilityChecker)

## Notes

- Build test `GameMap` manually (not via `MapGenerator.generate()`) for deterministic tests
- Verify `pendingExplorations.length` and `pendingExplorations.last.target` after execution

# Task 05: CellEligibilityChecker

## Summary

Create a checker that determines if a cell is eligible for exploration. A cell is eligible if it is revealed, or if it is unrevealed but adjacent (Chebyshev distance ≤ 1) to at least one revealed cell. The player's base cell is never eligible.

## Implementation Steps

### 1. Create `lib/domain/map/cell_eligibility_checker.dart`

```dart
import 'game_map.dart';

class CellEligibilityChecker {
  static bool isEligible(GameMap map, int x, int y) {
    // Base cell is never eligible
    if (x == map.playerBaseX && y == map.playerBaseY) return false;

    final cell = map.cellAt(x, y);

    // Revealed cells are eligible
    if (cell.isRevealed) return true;

    // Unrevealed cells adjacent to a revealed cell are eligible
    return _hasRevealedNeighbor(map, x, y);
  }

  static bool _hasRevealedNeighbor(GameMap map, int x, int y) {
    for (var dy = -1; dy <= 1; dy++) {
      for (var dx = -1; dx <= 1; dx++) {
        if (dx == 0 && dy == 0) continue;
        final nx = x + dx;
        final ny = y + dy;
        if (nx < 0 || nx >= map.width || ny < 0 || ny >= map.height) continue;
        if (map.cellAt(nx, ny).isRevealed) return true;
      }
    }
    return false;
  }
}
```

### Key Rules

1. **Base cell excluded:** `(playerBaseX, playerBaseY)` always returns `false`
2. **Revealed → eligible:** Any revealed cell (except base) is a valid exploration target
3. **Adjacent to revealed → eligible:** Unrevealed cells within Chebyshev distance 1 of any revealed cell are eligible (the "fog border" cells)
4. **No terrain restriction:** All terrain types are eligible (spec says "Fault cells are eligible")
5. **Boundary-safe:** Neighbor checks skip out-of-bounds positions

## Dependencies

- `GameMap` (existing)
- `MapCell` (existing, uses `isRevealed` field)

## Test Plan

- File: `test/domain/map/cell_eligibility_checker_test.dart` (Task 06)

## Notes

- Chebyshev distance 1 = the 8 cells surrounding a cell (including diagonals)
- This is called from the UI (to enable/disable tap) and from `ExploreAction.validate()`

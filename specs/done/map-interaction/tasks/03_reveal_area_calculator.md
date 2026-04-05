# Task 03: RevealAreaCalculator

## Summary

Create a pure-logic calculator that determines the reveal area for a given exploration based on the Explorer tech branch research level. Handles square sizing, even-square alignment (target at bottom-left), and map boundary clamping.

## Implementation Steps

### 1. Create `lib/domain/map/reveal_area_calculator.dart`

```dart
class RevealAreaCalculator {
  static int squareSideForLevel(int explorerLevel) {
    return switch (explorerLevel) {
      0 => 2,
      1 => 3,
      2 => 4,
      3 => 5,
      4 => 7,
      5 => 9,
      _ => 2,
    };
  }

  static List<GridPosition> cellsToReveal({
    required int targetX,
    required int targetY,
    required int explorerLevel,
    required int mapWidth,
    required int mapHeight,
  }) {
    final side = squareSideForLevel(explorerLevel);
    // For even sides: target is bottom-left corner
    // For odd sides: target is center
    final int startX;
    final int startY;
    if (side.isEven) {
      startX = targetX;
      startY = targetY - (side - 1); // target at bottom-left
    } else {
      final half = side ~/ 2;
      startX = targetX - half;
      startY = targetY - half;
    }

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
  }
}
```

Import `GridPosition` from `grid_position.dart`.

### Key Logic

- **Even squares (2, 4):** Target cell is at the **bottom-left** corner of the reveal area. This means `startY = targetY - (side - 1)` and `startX = targetX`.
- **Odd squares (3, 5, 7, 9):** Target cell is at the **center** of the reveal area.
- **Boundary clamping:** Cells outside `[0, mapWidth)` × `[0, mapHeight)` are simply skipped (no wrapping).

## Dependencies

- `GridPosition` (existing)

## Test Plan

- File: `test/domain/map/reveal_area_calculator_test.dart` (Task 04)

## Notes

- Pure static methods, no dependencies beyond `GridPosition`
- The `explorerLevel` parameter comes from `game.techBranches[TechBranch.explorer]?.researchLevel ?? 0`
- Default/fallback case (`_ => 2`) handles any unexpected level gracefully

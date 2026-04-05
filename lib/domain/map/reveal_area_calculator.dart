import 'grid_position.dart';

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

import 'grid_position.dart';

class RevealAreaCalculator {
  static int squareSideForLevel(int explorerLevel) {
    return switch (explorerLevel) {
      0 => 3,
      1 => 3,
      2 => 5,
      3 => 5,
      4 => 7,
      5 => 9,
      _ => 3,
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
  }
}

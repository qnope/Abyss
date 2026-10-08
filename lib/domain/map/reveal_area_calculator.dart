import 'grid_position.dart';

class RevealAreaCalculator {
  static List<GridPosition> cellsToReveal({
    required int targetX,
    required int targetY,
    required int side,
    required int mapWidth,
    required int mapHeight,
  }) {
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

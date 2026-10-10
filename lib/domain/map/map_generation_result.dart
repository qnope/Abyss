import 'game_map.dart';
import 'grid_position.dart';

class MapGenerationResult {
  final GameMap map;
  final int baseX;
  final int baseY;

  /// Starting base of every player, the first one at ([baseX], [baseY]).
  final List<GridPosition> bases;

  MapGenerationResult({
    required this.map,
    required this.baseX,
    required this.baseY,
    List<GridPosition>? bases,
  }) : bases = bases ?? [GridPosition(x: baseX, y: baseY)];
}

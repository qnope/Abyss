import 'game_map.dart';

class MapGenerationResult {
  final GameMap map;
  final int baseX;
  final int baseY;

  const MapGenerationResult({
    required this.map,
    required this.baseX,
    required this.baseY,
  });
}

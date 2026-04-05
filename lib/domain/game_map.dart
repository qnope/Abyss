import 'package:hive/hive.dart';
import 'map_tile.dart';

part 'game_map.g.dart';

@HiveType(typeId: 13)
class GameMap extends HiveObject {
  @HiveField(0)
  final List<MapTile> tiles;

  @HiveField(1)
  final int width;

  @HiveField(2)
  final int height;

  GameMap({
    required this.tiles,
    this.width = 20,
    this.height = 20,
  });

  MapTile tileAt(int x, int y) => tiles[y * width + x];

  void revealRadius(int centerX, int centerY, int radius) {
    for (final tile in tiles) {
      final dx = (tile.x - centerX).abs();
      final dy = (tile.y - centerY).abs();
      if (dx + dy <= radius) {
        tile.revealed = true;
      }
    }
  }
}

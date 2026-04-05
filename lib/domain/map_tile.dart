import 'package:hive/hive.dart';
import 'terrain_type.dart';
import 'tile_content.dart';

part 'map_tile.g.dart';

@HiveType(typeId: 12)
class MapTile extends HiveObject {
  @HiveField(0)
  final int x;

  @HiveField(1)
  final int y;

  @HiveField(2)
  final TerrainType terrain;

  @HiveField(3)
  final TileContent content;

  @HiveField(4)
  bool revealed;

  MapTile({
    required this.x,
    required this.y,
    required this.terrain,
    this.content = TileContent.empty,
    this.revealed = false,
  });
}

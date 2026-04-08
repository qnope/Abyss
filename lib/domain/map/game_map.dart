import 'package:hive/hive.dart';
import 'map_cell.dart';

part 'game_map.g.dart';

@HiveType(typeId: 14)
class GameMap {
  @HiveField(0)
  final int width;

  @HiveField(1)
  final int height;

  @HiveField(2)
  final List<MapCell> cells;

  @HiveField(5)
  final int seed;

  GameMap({
    required this.width,
    required this.height,
    required this.cells,
    required this.seed,
  });

  MapCell cellAt(int x, int y) => cells[y * width + x];

  void setCell(int x, int y, MapCell cell) {
    cells[y * width + x] = cell;
  }
}

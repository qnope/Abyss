import 'dart:math';
import 'game_map.dart';
import 'map_tile.dart';
import 'terrain_type.dart';
import 'tile_content.dart';

class MapGenerator {
  static const int mapSize = 20;
  static const int baseX = 10;
  static const int baseY = 10;
  static const int safeRadius = 2;
  static const int initialVisionRadius = 3;

  final Random _random;

  MapGenerator({Random? random}) : _random = random ?? Random();

  GameMap generate() {
    final tiles = _createTiles();
    _placeBase(tiles);
    _placeMonsters(tiles);
    _placeEnemies(tiles);
    final map = GameMap(tiles: tiles);
    map.revealRadius(baseX, baseY, initialVisionRadius);
    return map;
  }

  List<MapTile> _createTiles() {
    return [
      for (int y = 0; y < mapSize; y++)
        for (int x = 0; x < mapSize; x++)
          MapTile(x: x, y: y, terrain: _randomTerrain()),
    ];
  }

  TerrainType _randomTerrain() {
    final roll = _random.nextInt(100);
    if (roll < 50) return TerrainType.plain;
    if (roll < 70) return TerrainType.reef;
    if (roll < 90) return TerrainType.rock;
    return TerrainType.fault;
  }

  void _placeBase(List<MapTile> tiles) {
    final index = baseY * mapSize + baseX;
    tiles[index] = MapTile(
      x: baseX,
      y: baseY,
      terrain: TerrainType.plain,
      content: TileContent.playerBase,
    );
  }

  void _placeMonsters(List<MapTile> tiles) {
    _placeContent(tiles, TileContent.monsterLevel1, 30);
    _placeContent(tiles, TileContent.monsterLevel2, 15);
    _placeContent(tiles, TileContent.monsterLevel3, 5);
  }

  void _placeEnemies(List<MapTile> tiles) {
    _placeContent(tiles, TileContent.enemy, 8, minSpacing: 4);
  }

  void _placeContent(
    List<MapTile> tiles,
    TileContent content,
    int count, {
    int minSpacing = 0,
  }) {
    final placed = <int>[];
    var attempts = 0;
    while (placed.length < count && attempts < count * 20) {
      attempts++;
      final x = _random.nextInt(mapSize);
      final y = _random.nextInt(mapSize);
      if (!_canPlace(tiles, x, y, placed, minSpacing)) continue;
      final index = y * mapSize + x;
      tiles[index] = MapTile(
        x: x,
        y: y,
        terrain: tiles[index].terrain,
        content: content,
      );
      placed.add(index);
    }
  }

  bool _canPlace(
    List<MapTile> tiles,
    int x,
    int y,
    List<int> placed,
    int minSpacing,
  ) {
    final dx = (x - baseX).abs();
    final dy = (y - baseY).abs();
    if (dx + dy <= safeRadius) return false;
    final index = y * mapSize + x;
    if (tiles[index].content != TileContent.empty) return false;
    if (minSpacing > 0) {
      for (final other in placed) {
        final ox = other % mapSize;
        final oy = other ~/ mapSize;
        if ((x - ox).abs() + (y - oy).abs() < minSpacing) return false;
      }
    }
    return true;
  }
}

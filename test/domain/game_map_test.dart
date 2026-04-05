import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/game_map.dart';
import 'package:abyss/domain/map_tile.dart';
import 'package:abyss/domain/terrain_type.dart';

void main() {
  group('GameMap', () {
    late GameMap map;

    setUp(() {
      final tiles = [
        for (int y = 0; y < 20; y++)
          for (int x = 0; x < 20; x++)
            MapTile(x: x, y: y, terrain: TerrainType.plain),
      ];
      map = GameMap(tiles: tiles);
    });

    test('has correct dimensions', () {
      expect(map.width, 20);
      expect(map.height, 20);
      expect(map.tiles.length, 400);
    });

    test('tileAt returns correct tile', () {
      final tile = map.tileAt(5, 3);
      expect(tile.x, 5);
      expect(tile.y, 3);
    });

    test('tileAt returns corner tiles correctly', () {
      expect(map.tileAt(0, 0).x, 0);
      expect(map.tileAt(0, 0).y, 0);
      expect(map.tileAt(19, 19).x, 19);
      expect(map.tileAt(19, 19).y, 19);
    });

    test('revealRadius reveals tiles within manhattan distance', () {
      map.revealRadius(10, 10, 2);
      expect(map.tileAt(10, 10).revealed, true);
      expect(map.tileAt(11, 10).revealed, true);
      expect(map.tileAt(10, 11).revealed, true);
      expect(map.tileAt(12, 10).revealed, true);
      expect(map.tileAt(11, 11).revealed, true);
    });

    test('revealRadius does not reveal tiles outside radius', () {
      map.revealRadius(10, 10, 2);
      expect(map.tileAt(13, 10).revealed, false);
      expect(map.tileAt(0, 0).revealed, false);
    });

    test('revealRadius handles edge of map', () {
      map.revealRadius(0, 0, 1);
      expect(map.tileAt(0, 0).revealed, true);
      expect(map.tileAt(1, 0).revealed, true);
      expect(map.tileAt(0, 1).revealed, true);
      expect(map.tileAt(1, 1).revealed, false);
    });
  });
}

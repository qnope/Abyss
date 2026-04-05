import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map_generator.dart';
import 'package:abyss/domain/tile_content.dart';
import 'package:abyss/domain/terrain_type.dart';

void main() {
  group('MapGenerator', () {
    late MapGenerator generator;

    setUp(() {
      generator = MapGenerator(random: Random(42));
    });

    test('generates a 20x20 map with 400 tiles', () {
      final map = generator.generate();
      expect(map.tiles.length, 400);
      expect(map.width, 20);
      expect(map.height, 20);
    });

    test('places player base at center (10, 10)', () {
      final map = generator.generate();
      final base = map.tileAt(10, 10);
      expect(base.content, TileContent.playerBase);
      expect(base.terrain, TerrainType.plain);
    });

    test('safe zone around base has no hostile content', () {
      final map = generator.generate();
      for (int dy = -2; dy <= 2; dy++) {
        for (int dx = -2; dx <= 2; dx++) {
          if ((dx.abs() + dy.abs()) > 2) continue;
          final tile = map.tileAt(10 + dx, 10 + dy);
          expect(
            tile.content == TileContent.empty ||
            tile.content == TileContent.playerBase,
            isTrue,
            reason: 'Tile at (${10 + dx}, ${10 + dy}) has ${tile.content}',
          );
        }
      }
    });

    test('generates monsters of all levels', () {
      final map = generator.generate();
      final contents = map.tiles.map((t) => t.content).toList();
      expect(contents, contains(TileContent.monsterLevel1));
      expect(contents, contains(TileContent.monsterLevel2));
      expect(contents, contains(TileContent.monsterLevel3));
    });

    test('generates enemies', () {
      final map = generator.generate();
      final enemies = map.tiles
          .where((t) => t.content == TileContent.enemy)
          .length;
      expect(enemies, greaterThan(0));
      expect(enemies, lessThanOrEqualTo(8));
    });

    test('reveals tiles around base within initial vision radius', () {
      final map = generator.generate();
      expect(map.tileAt(10, 10).revealed, true);
      expect(map.tileAt(11, 10).revealed, true);
      expect(map.tileAt(10, 13).revealed, true);
    });

    test('does not reveal tiles far from base', () {
      final map = generator.generate();
      expect(map.tileAt(0, 0).revealed, false);
      expect(map.tileAt(19, 19).revealed, false);
    });

    test('all terrain types are used', () {
      final map = generator.generate();
      final terrains = map.tiles.map((t) => t.terrain).toSet();
      expect(terrains, contains(TerrainType.plain));
      expect(terrains, contains(TerrainType.reef));
      expect(terrains, contains(TerrainType.rock));
      expect(terrains, contains(TerrainType.fault));
    });
  });
}

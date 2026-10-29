import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/presentation/extensions/terrain_type_extensions.dart';
import 'package:abyss/presentation/widgets/map/map_scatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const side = 20;
  final cells = [
    for (var y = 0; y < side; y++)
      for (var x = 0; x < side; x++) (x, y),
  ];

  group('mapScatter', () {
    test('gives a cell the same value every time', () {
      for (final (x, y) in cells) {
        expect(mapScatter(x, y), mapScatter(x, y));
      }
    });

    test('tells neighbours and salts apart', () {
      final values = {for (final (x, y) in cells) mapScatter(x, y)};
      expect(values.length, greaterThan(cells.length * 0.99));
      expect(mapScatter(3, 4, salt: 1), isNot(mapScatter(3, 4)));
    });

    test('stays a small positive number, the same on the web', () {
      for (final (x, y) in cells) {
        expect(mapScatter(x, y), inInclusiveRange(0, 0x3fffffff));
      }
    });
  });

  group('floorTileOf', () {
    final tiles = TerrainType.plain.tileSvgPaths;
    String tileAt((int, int) cell) => floorTileOf(TerrainType.plain, cell);

    test('lays one of the tiles of the terrain', () {
      for (final cell in cells) {
        expect(tiles, contains(tileAt(cell)));
      }
    });

    test('uses every tile about as often', () {
      for (final tile in tiles) {
        final count = cells.where((c) => tileAt(c) == tile).length;
        expect(count, inInclusiveRange(100, 170), reason: tile);
      }
    });

    test('never reads as a pattern along a row or a diagonal', () {
      for (var i = 0; i < side; i++) {
        final row = {for (var x = 0; x < side; x++) tileAt((x, i))};
        expect(row, hasLength(tiles.length), reason: 'row $i');
        final diagonal = {for (var x = 0; x <= i; x++) tileAt((x, i - x))};
        if (i >= 8) expect(diagonal.length, greaterThan(1), reason: 'x+y=$i');
      }
    });
  });
}

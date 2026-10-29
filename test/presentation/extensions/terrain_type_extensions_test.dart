import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/presentation/extensions/terrain_type_extensions.dart';

import '../../helpers/l10n_fixtures.dart';

void main() {
  group('TerrainTypeExtensions', () {
    test('plain is named in each language', () {
      expect(TerrainType.plain.label(fr), 'Plaine');
      expect(TerrainType.plain.label(en), 'Plain');
      expect(TerrainType.plain.label(es), 'Llanura');
    });

    test('plain has a valid svgPath', () {
      expect(TerrainType.plain.svgPath, startsWith('assets/icons/terrain/'));
      expect(TerrainType.plain.svgPath, endsWith('.svg'));
    });

    test('plain is laid with three diamond tiles of the sea floor', () {
      final tiles = TerrainType.plain.tileSvgPaths;
      expect(tiles, hasLength(3));
      expect(tiles.toSet(), hasLength(3));
      final path = RegExp(r'^assets/icons/terrain/plain_iso_\d\.svg$');
      for (final tile in tiles) {
        expect(tile, matches(path));
      }
    });

    test('plain is not opaque', () {
      expect(TerrainType.plain.isOpaque, false);
    });

    test('plain has a color', () {
      expect(TerrainType.plain.color, isNotNull);
    });
  });
}

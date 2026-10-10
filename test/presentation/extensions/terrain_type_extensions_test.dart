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

    test('plain is not opaque', () {
      expect(TerrainType.plain.isOpaque, false);
    });

    test('plain has a color', () {
      expect(TerrainType.plain.color, isNotNull);
    });
  });
}

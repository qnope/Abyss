import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/presentation/extensions/terrain_type_extensions.dart';

void main() {
  group('TerrainTypeExtensions', () {
    test('plain has a non-empty label', () {
      expect(TerrainType.plain.label, isNotEmpty);
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

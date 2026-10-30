import 'dart:ui';

import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/extensions/unit_type_extensions.dart';
import 'package:abyss/presentation/widgets/army/army_fit.dart';
import 'package:abyss/presentation/widgets/army/army_sprites.dart';
import 'package:abyss/presentation/widgets/army/army_squad_geometry.dart';
import 'package:abyss/presentation/widgets/common/svg_raster_cache.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_svg_helper.dart';

void main() {
  const figure = Size(120, 150);

  test('a standing unit is rasterized at its own aspect, not squashed', () {
    for (final type in UnitType.values) {
      final (width, height) = SvgRasterCache.pixelSizeOf(
        type.standingPath,
        figure,
      );
      expect(height, SvgRasterCache.pixels, reason: '$type');
      expect(width, (SvgRasterCache.pixels * 120 / 150).round());
    }
  });

  test('a standing unit is sharp on the parade ground of a large 3× phone', () {
    final fit = ArmyFit.of(const Size(430, 720));
    final (_, height) = SvgRasterCache.pixelSizeOf(
      UnitType.scout.standingPath,
      figure,
    );
    expect(
      height,
      greaterThanOrEqualTo(ArmySquadGeometry.figureSize.height * fit.zoom * 3),
    );
  });

  test('icons keep their square bitmap', () {
    expect(SvgRasterCache.pixelSizeOf(UnitType.scout.iconPath, figure), (
      SvgRasterCache.pixels,
      SvgRasterCache.pixels,
    ));
  });

  testWidgets('loads the figure and the portrait of every unit', (
    tester,
  ) async {
    mockSvgAssets();
    addTearDown(clearSvgMocks);
    final sprites = (await tester.runAsync(ArmySprites.load))!;
    for (final type in UnitType.values) {
      expect(sprites.standingOf(type), isNotNull);
      expect(sprites.portraitOf(type), isNotNull);
    }
    expect(ArmySprites.ready, same(sprites));
  });
}

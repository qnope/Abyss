import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/presentation/extensions/building_type_extensions.dart';
import 'package:abyss/presentation/widgets/base/base_buildings_painter.dart';
import 'package:abyss/presentation/widgets/base/base_fit.dart';
import 'package:abyss/presentation/widgets/base/base_layout.dart';
import 'package:abyss/presentation/widgets/base/base_pad_tier.dart';
import 'package:abyss/presentation/widgets/base/base_slot_projection.dart';
import 'package:abyss/presentation/widgets/base/base_snapshot.dart';
import 'package:abyss/presentation/widgets/base/base_sprites.dart';
import 'package:abyss/presentation/widgets/common/svg_raster_cache.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_svg_helper.dart';

void main() {
  const layout = BaseLayout.island;
  const hq = BuildingType.headquarters;

  test('every building is rasterized sharp for the base of a large 3× phone',
      () {
    // A 430-wide phone at 3×, the base taking most of its height.
    final fit = BaseFit.of(const Size(430, 720), layout);
    for (final type in BuildingType.values) {
      final pixels = layout.slotOf(type).standingBox.width * fit.zoom * 3;
      expect(SvgRasterCache.pixelsOf(type.standingPath),
          greaterThanOrEqualTo(pixels), reason: type.name);
    }
  });

  test('icons keep their smaller bitmap', () {
    expect(SvgRasterCache.pixelsOf(hq.iconPath), SvgRasterCache.pixels);
  });

  testWidgets('draws the whole bitmap of every building in its box',
      (tester) async {
    mockSvgAssets();
    addTearDown(clearSvgMocks);
    final sprites = (await tester.runAsync(BaseSprites.load))!;
    final image = sprites.standingOf(hq)!;
    expect(image.width, SvgRasterCache.pixelsOf(hq.standingPath));
    final painter = BaseBuildingsPainter(
      layout: layout,
      snapshot: const BaseSnapshot(
          levels: {hq: 2}, tiers: {hq: BasePadTier.gravel}, degraded: {}),
      fit: BaseFit.of(const Size(390, 635), layout),
      sprites: sprites,
    );
    final sources = <Rect>[];
    expect(
      (Canvas canvas) => painter.paint(canvas, const Size(390, 635)),
      paints
        ..everything((method, arguments) {
          if (method == #drawImageRect && arguments[0] == image) {
            sources.add(arguments[1] as Rect);
          }
          return true;
        }),
    );
    expect(sources, [
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
    ]);
  });
}

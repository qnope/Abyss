import 'dart:ui';

import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/presentation/widgets/base/base_buildings_painter.dart';
import 'package:abyss/presentation/widgets/base/base_fit.dart';
import 'package:abyss/presentation/widgets/base/base_island_painter.dart';
import 'package:abyss/presentation/widgets/base/base_layout.dart';
import 'package:abyss/presentation/widgets/base/base_sprites.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_svg_helper.dart';

void main() {
  const layout = BaseLayout.island;
  const view = Size(390, 635);
  final fit = BaseFit.of(view, layout);
  const hq = BuildingType.headquarters, farm = BuildingType.algaeFarm;

  BaseIslandPainter island(Set<BuildingType> built, {BaseFit? at}) =>
      BaseIslandPainter(layout: layout, built: built, fit: at ?? fit);

  BaseBuildingsPainter buildings(Map<BuildingType, int> levels) =>
      BaseBuildingsPainter(layout: layout, levels: levels, fit: fit);

  /// Paints [painter] on a canvas of the [view], as a frame would.
  void paint(void Function(Canvas, Size) painter) {
    final recorder = PictureRecorder();
    painter(Canvas(recorder), view);
    recorder.endRecording().dispose();
  }

  group('the still island', () {
    test('a rebuilt base with the same buildings is not repainted', () {
      expect(island({hq, farm}).shouldRepaint(island({farm, hq})), isFalse);
    });

    test('a new building lays a new walkway, so the island repaints', () {
      expect(island({hq, farm}).shouldRepaint(island({hq})), isTrue);
    });

    test('a new view size repaints the island', () {
      final other = BaseFit.of(const Size(400, 700), layout);
      expect(island({hq}, at: other).shouldRepaint(island({hq})), isTrue);
    });

    test('paints with or without its sprites', () {
      paint(island({hq, farm}).paint);
      paint(island(BuildingType.values.toSet()).paint);
    });

    test('paints an island of any size', () {
      const parade = BaseLayout(size: 9, slots: {});
      paint(BaseIslandPainter(
        layout: parade,
        built: const {},
        fit: BaseFit.of(view, parade),
      ).paint);
    });

    testWidgets('paints its floor tiles once loaded', (tester) async {
      mockSvgAssets();
      addTearDown(clearSvgMocks);
      final sprites = await tester.runAsync(BaseSprites.load);
      final loaded = BaseIslandPainter(
          layout: layout, built: {hq}, fit: fit, sprites: sprites!.map);
      expect(loaded.shouldRepaint(island({hq})), isTrue);
      paint(loaded.paint);
    });
  });

  group('the buildings', () {
    test('the same levels do not repaint them', () {
      expect(buildings({hq: 1}).shouldRepaint(buildings({hq: 1})), isFalse);
    });

    test('a building raised repaints them', () {
      expect(buildings({hq: 2}).shouldRepaint(buildings({hq: 1})), isTrue);
    });

    testWidgets('paints every building, built or ghost', (tester) async {
      mockSvgAssets();
      addTearDown(clearSvgMocks);
      final sprites = await tester.runAsync(BaseSprites.load);
      for (final type in BuildingType.values) {
        expect(sprites!.standingOf(type), isNotNull, reason: '$type');
      }
      final painter = BaseBuildingsPainter(
          layout: layout, levels: {hq: 1, farm: 0}, fit: fit, sprites: sprites);
      paint(painter.paint);
      expect(painter.hitTest(Offset.zero), isFalse);
    });
  });
}

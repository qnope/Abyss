import 'dart:ui' as ui;

import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/presentation/widgets/base/base_buildings_painter.dart';
import 'package:abyss/presentation/widgets/base/base_island_painter.dart';
import 'package:abyss/presentation/widgets/base/base_view.dart';
import 'package:abyss/presentation/widgets/common/kept_rasters.dart';
import 'package:abyss/presentation/widgets/common/raster_paint.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/background_rasters.dart';
import '../../../helpers/test_svg_helper.dart';
import '../guide/guide_widget_helpers.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);
  tearDown(KeptRasters.clear);

  const hq = BuildingType.headquarters, farm = BuildingType.algaeFarm;
  late Player nemo;
  setUp(() => nemo = Player(name: 'Nemo')
    ..buildings[hq]!.level = 2
    ..buildings[farm]!.level = 1);

  Future<void> show(WidgetTester tester) async {
    await tester.pumpWidget(guidedApp(
      BaseView(
        buildings: nemo.buildings,
        worksite: nemo.worksite,
        onBuildingTap: (_) {},
      ),
      null,
    ));
    await tester.pump();
  }

  final island = find.byWidgetPredicate((widget) =>
      widget is RasterPaint && widget.painter is BaseIslandPainter);

  ui.Image? imageOf(WidgetTester tester) =>
      tester.renderObject<RenderRasterPaint>(island).image;

  /// The island's bitmap, once rasterized in the background.
  Future<ui.Image> bitmapOf(WidgetTester tester) async {
    await settleRasters(tester, () => imageOf(tester) != null);
    return imageOf(tester)!;
  }

  int buildingPaints(WidgetTester tester) {
    final boundary = tester.renderObject<RenderRepaintBoundary>(find
        .ancestor(
            of: find.byWidgetPredicate((widget) =>
                widget is CustomPaint &&
                widget.painter is BaseBuildingsPainter),
            matching: find.byType(RepaintBoundary))
        .first);
    return boundary.debugSymmetricPaintCount +
        boundary.debugAsymmetricPaintCount;
  }

  testWidgets('the island is rasterized once while the buildings live',
      (tester) async {
    await show(tester);
    final bitmap = await bitmapOf(tester);
    final buildings = buildingPaints(tester);
    for (var k = 0; k < 120; k++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(buildingPaints(tester), greaterThan(buildings + 30));
    expect(imageOf(tester), same(bitmap));
    expect(bitmap.debugDisposed, isFalse);
  });

  testWidgets("a building rising within its tier keeps the island's bitmap",
      (tester) async {
    await show(tester);
    final bitmap = await bitmapOf(tester);
    nemo.buildings[farm]!.level = 2;
    await show(tester);
    expect(imageOf(tester), same(bitmap));
  });

  testWidgets('a new pad rasterizes the island again, the old bitmap disposed',
      (tester) async {
    await show(tester);
    final old = await bitmapOf(tester);
    nemo.buildings[BuildingType.barracks]!.level = 1;
    await show(tester);
    expect(await bitmapOf(tester), isNot(same(old)));
    expect(old.debugDisposed, isTrue);
  });

  testWidgets("coming back to the base shows the island's bitmap kept",
      (tester) async {
    await show(tester);
    final before = await bitmapOf(tester);
    await tester.pumpWidget(const SizedBox());
    await show(tester);
    expect(imageOf(tester), same(before));
  });
}

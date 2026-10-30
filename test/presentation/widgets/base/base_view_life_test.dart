import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/presentation/widgets/base/base_buildings_painter.dart';
import 'package:abyss/presentation/widgets/base/base_island_painter.dart';
import 'package:abyss/presentation/widgets/base/base_rampart_painter.dart';
import 'package:abyss/presentation/widgets/base/base_view.dart';
import 'package:abyss/presentation/widgets/common/raster_paint.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/reduced_motion.dart';
import '../../../helpers/test_svg_helper.dart';
import '../guide/guide_widget_helpers.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  const hq = BuildingType.headquarters, farm = BuildingType.algaeFarm;
  const citadel = BuildingType.coralCitadel;

  Player player({int hqLevel = 2, int farmLevel = 1}) => Player(name: 'Nemo')
    ..buildings[hq]!.level = hqLevel
    ..buildings[farm]!.level = farmLevel;

  Future<void> show(WidgetTester tester, Player nemo) async {
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

  Finder painted<T extends CustomPainter>() => find.byWidgetPredicate(
      (widget) => widget is CustomPaint && widget.painter is T);

  T painterOf<T extends CustomPainter>(WidgetTester tester) =>
      tester.widget<CustomPaint>(painted<T>()).painter! as T;

  final island = find.byWidgetPredicate((widget) =>
      widget is RasterPaint && widget.painter is BaseIslandPainter);

  BaseIslandPainter islandOf(WidgetTester tester) =>
      tester.widget<RasterPaint>(island).painter as BaseIslandPainter;

  /// How many times the layer holding [painter] was painted, with or
  /// without what lies around it.
  int paintsOf(WidgetTester tester, Finder painter) {
    final boundary = tester.renderObject<RenderRepaintBoundary>(find
        .ancestor(of: painter, matching: find.byType(RepaintBoundary))
        .first);
    return boundary.debugSymmetricPaintCount +
        boundary.debugAsymmetricPaintCount;
  }

  Future<void> tick(WidgetTester tester) async {
    for (var k = 0; k < 6; k++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('the buildings breathe on the clock', (tester) async {
    await show(tester, player());
    final buildings = paintsOf(tester, painted<BaseBuildingsPainter>());
    await tick(tester);
    expect(paintsOf(tester, painted<BaseBuildingsPainter>()),
        greaterThan(buildings));
  });

  testWidgets('a base where nothing lives does not repaint on the clock',
      (tester) async {
    await show(tester, player(hqLevel: 0, farmLevel: 0));
    final buildings = paintsOf(tester, painted<BaseBuildingsPainter>());
    await tick(tester);
    expect(paintsOf(tester, painted<BaseBuildingsPainter>()), buildings);
  });

  testWidgets('a building whose level goes up pops', (tester) async {
    final nemo = player();
    await show(tester, nemo);
    expect(painterOf<BaseBuildingsPainter>(tester).rising, isEmpty);
    nemo.buildings[farm]!.level = 2;
    await show(tester, nemo);
    await tester.pump(const Duration(milliseconds: 100));
    final painter = painterOf<BaseBuildingsPainter>(tester);
    expect(painter.rising, {farm});
    expect(painter.rise!.value, inExclusiveRange(0, 1));
    await tester.pump(const Duration(seconds: 1));
    expect(painter.rise!.value, 1);
  });

  testWidgets('no pop when motion is reduced', (tester) async {
    reduceMotion(tester);
    final nemo = player();
    await show(tester, nemo);
    nemo.buildings[farm]!.level = 2;
    await show(tester, nemo);
    final painter = painterOf<BaseBuildingsPainter>(tester);
    expect(painter.rise?.value ?? 1, 1);
  });

  testWidgets('the rampart rises with the citadel, in front of the buildings',
      (tester) async {
    final nemo = player();
    await show(tester, nemo);
    expect(painted<BaseRampartPainter>(), findsNothing);
    expect(islandOf(tester).rampart.back, isEmpty);
    nemo.buildings[citadel]!.level = 2;
    await show(tester, nemo);
    expect(islandOf(tester).rampart.back, isNotEmpty);
    final front = find.byWidgetPredicate((widget) =>
        widget is CustomPaint && widget.painter is BaseRampartPainter);
    expect(front, findsOneWidget);
    final buildings = tester.getRect(painted<BaseBuildingsPainter>());
    expect(tester.getRect(front), buildings);
    final order = tester.allWidgets.whereType<CustomPaint>().toList();
    expect(
        order.indexWhere((w) => w.painter is BaseRampartPainter),
        greaterThan(
            order.indexWhere((w) => w.painter is BaseBuildingsPainter)));
  });
}

import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/theme/abyss_motion.dart';
import 'package:abyss/presentation/widgets/army/army_marks_painter.dart';
import 'package:abyss/presentation/widgets/army/army_squads_painter.dart';
import 'package:abyss/presentation/widgets/army/army_view.dart';
import 'package:abyss/presentation/widgets/army/squad_arrival.dart';
import 'package:abyss/presentation/widgets/common/raster_paint.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/army_view_harness.dart';
import '../../../helpers/reduced_motion.dart';
import '../../../helpers/test_svg_helper.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  const scout = UnitType.scout;
  late ArmyViewHarness army;
  setUp(() => army = ArmyViewHarness());

  Finder painted<T>() => find.byWidgetPredicate(
      (widget) => widget is CustomPaint && widget.painter is T);
  final island = find.descendant(
      of: find.byType(ArmyView), matching: find.byType(RasterPaint));

  /// How many times the layer holding [finder] was painted.
  int paintsOf(WidgetTester tester, Finder finder) {
    final boundary = tester.renderObject<RenderRepaintBoundary>(find
        .ancestor(of: finder, matching: find.byType(RepaintBoundary))
        .first);
    return boundary.debugSymmetricPaintCount +
        boundary.debugAsymmetricPaintCount;
  }

  Future<void> tick(WidgetTester tester) async {
    for (var k = 0; k < 6; k++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('only the squads repaint as they breathe', (tester) async {
    await army.show(tester, counts: {scout: 4});
    final squads = paintsOf(tester, painted<ArmySquadsPainter>());
    final marks = paintsOf(tester, painted<ArmyMarksPainter>());
    final still = paintsOf(tester, island);
    await tick(tester);
    expect(paintsOf(tester, painted<ArmySquadsPainter>()),
        greaterThan(squads + 3));
    expect(paintsOf(tester, painted<ArmyMarksPainter>()), marks);
    expect(paintsOf(tester, island), still);
  });

  testWidgets('the squads stand still when motion is reduced',
      (tester) async {
    reduceMotion(tester);
    await army.show(tester, counts: {scout: 4});
    expect(painterOf<ArmySquadsPainter>(tester).clock, isNull);
    final squads = paintsOf(tester, painted<ArmySquadsPainter>());
    await tick(tester);
    expect(paintsOf(tester, painted<ArmySquadsPainter>()), squads);
  });

  testWidgets('a recruit arrives when its squad grows, in under a second',
      (tester) async {
    await army.show(tester, counts: {scout: 3});
    expect(painterOf<ArmySquadsPainter>(tester).arriving, isEmpty);
    await army.show(tester, counts: {scout: 8});
    await tester.pump(const Duration(milliseconds: 150));
    const recruit = SquadArrival(figure: 2, stays: true, gained: 5);
    final squads = painterOf<ArmySquadsPainter>(tester);
    expect(squads.arriving, {scout: recruit});
    expect(squads.arrival!.value, inExclusiveRange(0, 1));
    expect(painterOf<ArmyMarksPainter>(tester).arriving, {scout: recruit});
    await tester.pump(AbyssMotion.recruitArrival);
    expect(painterOf<ArmySquadsPainter>(tester).arriving, isEmpty);
  });

  testWidgets('nothing arrives when a squad shrinks', (tester) async {
    await army.show(tester, counts: {scout: 8});
    await army.show(tester, counts: {scout: 3});
    await tester.pump(const Duration(milliseconds: 150));
    expect(painterOf<ArmySquadsPainter>(tester).arriving, isEmpty);
  });

  testWidgets('nothing arrives when another place is shown', (tester) async {
    await army.show(tester, counts: {scout: 3}, place: 2);
    await army.show(tester, counts: {scout: 8}, place: 1);
    await tester.pump(const Duration(milliseconds: 150));
    expect(painterOf<ArmySquadsPainter>(tester).arriving, isEmpty);
  });

  testWidgets('nothing arrives when motion is reduced', (tester) async {
    reduceMotion(tester);
    await army.show(tester, counts: {scout: 3});
    await army.show(tester, counts: {scout: 8});
    await tester.pump(const Duration(milliseconds: 150));
    expect(painterOf<ArmySquadsPainter>(tester).arriving, isEmpty);
  });
}

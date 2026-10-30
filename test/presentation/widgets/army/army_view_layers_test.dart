import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/widgets/army/army_marks_painter.dart';
import 'package:abyss/presentation/widgets/army/army_squads_painter.dart';
import 'package:abyss/presentation/widgets/army/army_view.dart';
import 'package:abyss/presentation/widgets/common/raster_paint.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/army_view_harness.dart';
import '../../../helpers/reduced_motion.dart';
import '../../../helpers/test_svg_helper.dart';

void main() {
  reduceMotionInEveryTest();
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  late ArmyViewHarness army;
  setUp(() => army = ArmyViewHarness());

  final island = find.descendant(
      of: find.byType(ArmyView), matching: find.byType(RasterPaint));
  Finder painted<T>() => find.byWidgetPredicate(
      (widget) => widget is CustomPaint && widget.painter is T);

  testWidgets('the squads and the plaques live apart from the island',
      (tester) async {
    await army.show(tester, counts: {UnitType.scout: 4});
    RenderObject boundaryOf(Finder finder) => tester.renderObject(find
        .ancestor(of: finder, matching: find.byType(RepaintBoundary))
        .first);
    expect({
      boundaryOf(island),
      boundaryOf(painted<ArmySquadsPainter>()),
      boundaryOf(painted<ArmyMarksPainter>()),
    }, hasLength(3));
  });

  testWidgets('the squads and the plaques count the army', (tester) async {
    await army.show(tester,
        barracks: 0,
        counts: {UnitType.scout: 4},
        recruitable: {UnitType.scout});
    final squads = painterOf<ArmySquadsPainter>(tester).roster;
    expect(squads.countOf(UnitType.scout), 4);
    final marks = painterOf<ArmyMarksPainter>(tester).roster;
    expect(marks, squads);
    expect(marks.barracksLevel, 0);
    expect(marks.recruitable, {UnitType.scout});
  });

  testWidgets('a squad grown repaints the squads, never the island',
      (tester) async {
    await army.show(tester, counts: {UnitType.scout: 4});
    await army.show(tester,
        counts: {UnitType.scout: 40}, phase: EnginePhase.layout);
    expect(tester.renderObject(island).debugNeedsPaint, isFalse);
    expect(tester.renderObject(painted<ArmySquadsPainter>()).debugNeedsPaint,
        isTrue);
    expect(tester.renderObject(painted<ArmyMarksPainter>()).debugNeedsPaint,
        isTrue);
    await tester.pump();
  });
}

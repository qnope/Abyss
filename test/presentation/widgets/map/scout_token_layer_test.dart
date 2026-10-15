import 'package:abyss/presentation/widgets/map/map_content_drawer.dart';
import 'package:abyss/presentation/widgets/map/scout_token_layer.dart';
import 'package:abyss/presentation/widgets/map/token/map_token_trip.dart';
import 'package:abyss/presentation/widgets/map/token/map_tokens_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/reduced_motion.dart';
import '../../../helpers/test_svg_helper.dart';

void main() {
  setUp(() => mockSvgAssets());
  tearDown(() => clearSvgMocks());

  const origin = (0, 0);

  Future<void> pumpLayer(WidgetTester tester, Set<(int, int)> targets) =>
      tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: ScoutTokenLayer(
          targets: targets,
          originOf: (_) => origin,
          size: const Size(10 * cellSize, 10 * cellSize),
        ),
      ));

  MapTokensPainter painterOf(WidgetTester tester) => tester
      .widget<CustomPaint>(find.byWidgetPredicate(
          (w) => w is CustomPaint && w.painter is MapTokensPainter))
      .painter! as MapTokensPainter;

  List<Rect> rectsOf(WidgetTester tester) =>
      [for (final trip in painterOf(tester).trips) trip.rect];

  testWidgets('scouts already sent wait at rest, without swimming', (
    tester,
  ) async {
    await pumpLayer(tester, {(4, 4), (6, 2)});
    expect(rectsOf(tester), unorderedEquals([
      MapTokenTrip.restingRect((4, 4)),
      MapTokenTrip.restingRect((6, 2)),
    ]));
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('a scout just sent swims from its origin to its target', (
    tester,
  ) async {
    await pumpLayer(tester, {(4, 4)});
    await pumpLayer(tester, {(4, 4), (8, 0)});
    final start = painterOf(tester).trips.last.rect;
    expect(start.center, MapContentDrawer.cellRect(0, 10).center);
    await tester.pump(MapTokenTrip.durationOf(origin, (8, 0)) ~/ 2);
    final middle = painterOf(tester).trips.last.rect.center;
    expect(middle.dx, inExclusiveRange(cellSize, 8 * cellSize));
    expect(rectsOf(tester).first, MapTokenTrip.restingRect((4, 4)));
    await tester.pumpAndSettle();
    expect(rectsOf(tester), unorderedEquals([
      MapTokenTrip.restingRect((4, 4)),
      MapTokenTrip.restingRect((8, 0)),
    ]));
  });

  testWidgets('a scout back from its exploration leaves the map', (
    tester,
  ) async {
    await pumpLayer(tester, {(4, 4), (6, 2)});
    await pumpLayer(tester, {(6, 2)});
    expect(rectsOf(tester), [MapTokenTrip.restingRect((6, 2))]);
    await pumpLayer(tester, {});
    expect(rectsOf(tester), isEmpty);
  });

  testWidgets('with reduced motion, a scout sent shows at rest at once', (
    tester,
  ) async {
    reduceMotion(tester);
    await pumpLayer(tester, {});
    await pumpLayer(tester, {(8, 0)});
    expect(rectsOf(tester), [MapTokenTrip.restingRect((8, 0))]);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('the tokens never catch a tap', (tester) async {
    await pumpLayer(tester, {(0, 0)});
    expect(painterOf(tester).hitTest(const Offset(40, 40)), isFalse);
  });
}

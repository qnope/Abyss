import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/ambience/ambience_clock_scope.dart';
import 'package:abyss/presentation/widgets/ambience/ambient_motion.dart';
import 'package:abyss/presentation/widgets/ambience/ambient_pose.dart';
import 'package:abyss/presentation/widgets/ambience/bubbles_painter.dart';
import 'package:abyss/presentation/widgets/building/building_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../helpers/test_svg_helper.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  Widget app(Building building, {int? missingHeadquarters}) => MaterialApp(
    theme: AbyssTheme.create(),
    home: Scaffold(
      body: AmbienceClockScope(
        builder:
            (_, _) => BuildingCard(
              building: building,
              onTap: () {},
              missingHeadquarters: missingHeadquarters,
            ),
      ),
    ),
  );

  AmbientMotion? motionOf(WidgetTester tester) {
    final poses = tester.widgetList<AmbientPose>(find.byType(AmbientPose));
    return poses.isEmpty ? null : poses.single.motion;
  }

  final bubbles = find.byWidgetPredicate(
    (w) => w is CustomPaint && w.painter is BubblesPainter,
  );

  testWidgets('a built building breathes', (tester) async {
    await tester.pumpWidget(
      app(Building(type: BuildingType.laboratory, level: 2)),
    );
    expect(motionOf(tester), AmbientMotion.breathe);
    expect(bubbles, findsNothing);
  });

  testWidgets('an unbuilt building stands still', (tester) async {
    await tester.pumpWidget(app(Building(type: BuildingType.algaeFarm)));
    expect(motionOf(tester), isNull);
    expect(bubbles, findsNothing);
  });

  testWidgets('a degraded building stands still', (tester) async {
    await tester.pumpWidget(
      app(
        Building(type: BuildingType.coralMine, level: 3),
        missingHeadquarters: 4,
      ),
    );
    expect(motionOf(tester), isNull);
    expect(bubbles, findsNothing);
  });

  for (final type in [
    BuildingType.algaeFarm,
    BuildingType.coralMine,
    BuildingType.oreExtractor,
  ]) {
    testWidgets('bubbles rise over an active ${type.name}', (tester) async {
      await tester.pumpWidget(app(Building(type: type, level: 1)));
      expect(bubbles, findsOneWidget);
      expect(
        find.ancestor(of: bubbles, matching: find.byType(IgnorePointer)),
        findsWidgets,
      );
    });
  }

  testWidgets('the icon rises once when the level goes up', (tester) async {
    final building = Building(type: BuildingType.barracks, level: 1);
    await tester.pumpWidget(app(building));
    await tester.pump(const Duration(milliseconds: 1));
    final icon = find.byType(RawImage);
    final resting = tester.getRect(icon).width;
    building.level = 2;
    await tester.pumpWidget(app(building));
    await tester.pump(const Duration(milliseconds: 1));
    expect(tester.getRect(icon).width, lessThan(resting * 0.95));
    await tester.pump(const Duration(seconds: 1));
    final settled = tester.getRect(icon).width;
    expect(settled, greaterThan(resting * 0.95));
    await tester.pumpWidget(app(building));
    await tester.pump(const Duration(milliseconds: 1));
    expect(tester.getRect(icon).width, greaterThan(resting * 0.95));
  });
}

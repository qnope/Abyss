import 'package:abyss/domain/game/player.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/ambience/ambience_clock_scope.dart';
import 'package:abyss/presentation/widgets/ambience/ambient_pose.dart';
import 'package:abyss/presentation/widgets/building/building_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../helpers/reduced_motion.dart';
import '../../../helpers/test_svg_helper.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  Widget app(Player player) => MaterialApp(
    theme: AbyssTheme.create(),
    home: Scaffold(
      body: BuildingListView(
        buildings: player.buildings,
        resources: player.resources,
        worksite: player.worksite,
        onBuildingTap: (_) {},
      ),
    ),
  );

  Player builtPlayer() {
    final player = Player(name: 'Tester');
    for (final b in player.buildings.values.take(4)) {
      b.level = 1;
    }
    return player;
  }

  testWidgets('one clock drives the whole list', (tester) async {
    await tester.pumpWidget(app(builtPlayer()));
    expect(find.byType(AmbienceClockScope), findsOneWidget);
    expect(find.byType(AmbientPose).evaluate().length, greaterThan(1));
  });

  testWidgets('each building breathes with its own phase', (tester) async {
    await tester.pumpWidget(app(builtPlayer()));
    final phases =
        tester
            .widgetList<AmbientPose>(find.byType(AmbientPose))
            .map((p) => p.phase)
            .toSet();
    expect(phases.length, greaterThan(1));
  });

  testWidgets('the cards are not rebuilt as the sea moves', (tester) async {
    await tester.pumpWidget(app(builtPlayer()));
    final title = find.text('Quartier Général');
    final before = tester.widget(title);
    final pose = tester.widget(find.byType(AmbientPose).first);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    expect(identical(tester.widget(title), before), isTrue);
    expect(
      identical(tester.widget(find.byType(AmbientPose).first), pose),
      isTrue,
    );
  });

  testWidgets('stands still when animations are reduced', (tester) async {
    reduceMotion(tester);
    await tester.pumpWidget(app(builtPlayer()));
    await tester.pumpAndSettle();
    final icon = find.byType(RawImage).first;
    final rect = tester.getRect(icon);
    await tester.pump(const Duration(seconds: 1));
    expect(tester.getRect(icon), rect);
    expect(tester.hasRunningAnimations, isFalse);
  });
}

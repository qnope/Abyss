import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/objective/guide/guide_target.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/common/game_bottom_bar.dart';
import 'package:abyss/presentation/widgets/guide/guide_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'guide_widget_helpers.dart';

void main() {
  Future<void> pumpBar(
    WidgetTester tester,
    GuideTarget? target, {
    int currentTab = 0,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AbyssTheme.create(),
        home: GuideScope(
          target: target,
          child: Scaffold(
            bottomNavigationBar: GameBottomBar(
              currentTab: currentTab,
              turnNumber: 1,
              onTabChanged: (_) {},
              onNextTurn: () {},
              onSettings: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('the halo surrounds the tab to open', (tester) async {
    await pumpBar(tester, const GuideTarget.unit(UnitType.scout));

    expect(activeHalos, findsOneWidget);
    expect(haloAround(find.byIcon(Icons.shield)), findsOneWidget);
  });

  testWidgets('no halo on the tab already open', (tester) async {
    await pumpBar(
      tester,
      const GuideTarget.unit(UnitType.scout),
      currentTab: 2,
    );

    expect(activeHalos, findsNothing);
  });

  testWidgets('each area has its tab', (tester) async {
    final tabs = {
      const GuideTarget.building(BuildingType.barracks): Icons.home,
      const GuideTarget.map(): Icons.map,
      const GuideTarget.research({}): Icons.science,
    };
    for (final MapEntry(key: target, value: icon) in tabs.entries) {
      await pumpBar(tester, target, currentTab: 2);
      expect(haloAround(find.byIcon(icon)), findsOneWidget);
    }
  });

  testWidgets('the halo surrounds « Tour suivant » to end the turn', (
    tester,
  ) async {
    await pumpBar(tester, const GuideTarget.endTurn());

    expect(activeHalos, findsOneWidget);
    expect(haloAround(find.text('Tour suivant')), findsOneWidget);
  });

  testWidgets('no halo without a guide', (tester) async {
    await pumpBar(tester, null);

    expect(activeHalos, findsNothing);
  });
}

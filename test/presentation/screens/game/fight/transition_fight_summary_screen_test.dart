import 'package:flutter/material.dart';
import 'package:abyss/domain/action/attack_transition_base_result.dart';
import 'package:abyss/domain/map/transition_base.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/presentation/screens/game/fight/transition_fight_summary_screen.dart';
import 'package:abyss/presentation/widgets/fight/fight_turn_list.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_svg_helper.dart';
import '../../../../helpers/transition_fight_fixtures.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  final base = TransitionBase(
    type: TransitionBaseType.faille,
    name: 'Faille Alpha',
  );

  Future<void> pumpSummary(
    WidgetTester tester,
    AttackTransitionBaseResult result,
  ) async {
    useTallView(tester);
    await tester.pumpWidget(buildLauncherHost('open', (ctx) {
      Navigator.of(ctx).push(MaterialPageRoute<void>(
        builder: (_) => TransitionFightSummaryScreen(
          result: result,
          transitionBase: base,
          targetX: 3,
          targetY: 4,
        ),
      ));
    }));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  group('TransitionFightSummaryScreen', () {
    testWidgets('shows coordinates in the app bar', (tester) async {
      await pumpSummary(
          tester, buildTransitionResult(victory: true, captured: true));
      expect(find.text('Assaut (3, 4)'), findsOneWidget);
    });

    testWidgets('shows BASE CAPTURÉE when captured', (tester) async {
      await pumpSummary(
          tester, buildTransitionResult(victory: true, captured: true));
      expect(find.text('BASE CAPTURÉE'), findsOneWidget);
      expect(find.text('VICTOIRE'), findsNothing);
    });

    testWidgets('shows VICTOIRE when won without capture', (tester) async {
      await pumpSummary(
          tester, buildTransitionResult(victory: true, captured: false));
      expect(find.text('VICTOIRE'), findsOneWidget);
    });

    testWidgets('shows DÉFAITE and remaining guardians on defeat',
        (tester) async {
      await pumpSummary(
          tester, buildTransitionResult(victory: false, captured: false));
      expect(find.text('DÉFAITE'), findsOneWidget);
      expect(find.text('Gardiens éliminés: 1/4'), findsOneWidget);
    });

    testWidgets('shows fight details when a fight happened', (tester) async {
      await pumpSummary(
          tester, buildTransitionResult(victory: true, captured: true));
      expect(find.text('Combat en 2 tours'), findsOneWidget);
      expect(find.text('Gardiens éliminés: 4/4'), findsOneWidget);
      expect(find.byType(FightTurnList), findsOneWidget);
    });

    testWidgets('lists per-unit accounting', (tester) async {
      await pumpSummary(
          tester, buildTransitionResult(victory: true, captured: true));
      expect(find.text('Vos unités'), findsOneWidget);
      expect(
        find.text('Envoyés: 1 / Intactes: 1 / Blessés: 0 / Morts: 0'),
        findsOneWidget,
      );
      expect(
        find.text('Envoyés: 5 / Intactes: 2 / Blessés: 1 / Morts: 2'),
        findsOneWidget,
      );
    });

    testWidgets('hides fight sections when there is no fight',
        (tester) async {
      await pumpSummary(
        tester,
        buildTransitionResult(victory: true, captured: true, withFight: false),
      );
      expect(find.textContaining('Combat en'), findsNothing);
      expect(find.textContaining('Gardiens éliminés'), findsNothing);
      expect(find.byType(FightTurnList), findsNothing);
    });

    testWidgets('back button returns to the previous screen',
        (tester) async {
      await pumpSummary(
          tester, buildTransitionResult(victory: true, captured: true));
      await tester.tap(find.text('Retour à la carte'));
      await tester.pumpAndSettle();
      expect(find.byType(TransitionFightSummaryScreen), findsNothing);
      expect(find.text('open'), findsOneWidget);
    });
  });
}

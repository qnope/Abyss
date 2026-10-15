import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/screens/game/fight/transition_army_selection_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../integration/transition_test_helper.dart';
import 'transition_army_selection_helper.dart';

void main() {
  mockSvgs();

  late ArmySelectionHarness screen;

  setUp(() => screen = ArmySelectionHarness());

  group('TransitionArmySelectionScreen launch', () {
    testWidgets('cancel pops back', (tester) async {
      await screen.pump(tester, buildTransitionScenario().game);
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();
      expect(find.byType(TransitionArmySelectionScreen), findsNothing);
      expect(find.text('open'), findsOneWidget);
    });

    testWidgets('launch saves, notifies and returns the assault',
        (tester) async {
      final game = buildTransitionScenario().game;
      await screen.pump(tester, game);
      await select(tester, UnitType.abyssAdmiral, 1);
      await select(tester, UnitType.domeBreaker, 30);
      await tester.tap(find.text('Lancer l\'assaut'));
      await tester.pumpAndSettle();

      expect(screen.repo.saveCallCount, 1);
      expect(screen.changedCount, 1);
      expect(find.byType(TransitionArmySelectionScreen), findsNothing);
      expect(find.text('open'), findsOneWidget);
      expect(screen.result?.isSuccess, isTrue);
      expect(screen.result?.captured, faille(game).isCaptured);
      expect(screen.result?.sent,
          {UnitType.abyssAdmiral: 1, UnitType.domeBreaker: 30});
    });

    testWidgets('failed assault shows the reason and stays',
        (tester) async {
      final game = buildTransitionScenario().game;
      faille(game).capturedBy = 'someone-else';
      await screen.pump(tester, game);
      await select(tester, UnitType.abyssAdmiral, 1);
      await tester.tap(find.text('Lancer l\'assaut'));
      await tester.pumpAndSettle();

      expect(find.text('Base déjà capturée'), findsOneWidget);
      expect(screen.repo.saveCallCount, 0);
      expect(screen.changedCount, 0);
      expect(find.byType(TransitionArmySelectionScreen), findsOneWidget);
    });
  });
}

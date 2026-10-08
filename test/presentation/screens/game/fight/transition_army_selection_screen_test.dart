import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/map/transition_base.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/screens/game/fight/transition_army_selection_screen.dart';
import 'package:abyss/presentation/screens/game/fight/transition_fight_summary_screen.dart';
import 'package:abyss/presentation/widgets/fight/unit_quantity_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_game_repository.dart';
import '../../../../helpers/test_svg_helper.dart';
import '../../../../helpers/transition_fight_fixtures.dart';
import '../../../../integration/transition_test_helper.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  late FakeGameRepository repo;
  late int changedCount;

  setUp(() {
    repo = FakeGameRepository();
    changedCount = 0;
  });

  TransitionBase faille(Game game) =>
      game.levels[1]!.cellAt(kFailleX, kFailleY).transitionBase!;

  Future<void> pumpScreen(WidgetTester tester, Game game) async {
    useTallView(tester);
    await tester.pumpWidget(buildLauncherHost('open', (ctx) {
      Navigator.of(ctx).push(MaterialPageRoute<void>(
        builder: (_) => TransitionArmySelectionScreen(
          game: game,
          repository: repo,
          targetX: kFailleX,
          targetY: kFailleY,
          level: 1,
          transitionBase: faille(game),
          onChanged: () => changedCount++,
        ),
      ));
    }));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Future<void> select(WidgetTester tester, UnitType type, int count) async {
    final row = find.byWidgetPredicate(
      (w) => w is UnitQuantityRow && w.type == type,
    );
    tester.widget<UnitQuantityRow>(row).onChanged(count);
    await tester.pumpAndSettle();
  }

  ElevatedButton launchButton(WidgetTester tester) => tester.widget(
        find.widgetWithText(ElevatedButton, 'Lancer l\'assaut'),
      );

  const admiralWarning =
      'Un Amiral des Abysses est requis pour lancer l\'assaut';

  group('TransitionArmySelectionScreen', () {
    testWidgets('shows base name and a row per unit in stock',
        (tester) async {
      await pumpScreen(tester, buildTransitionScenario().game);
      expect(find.text('Assaut: Faille Alpha'), findsOneWidget);
      expect(find.byType(UnitQuantityRow), findsNWidgets(3));
    });

    testWidgets('launch disabled and warning shown without admiral',
        (tester) async {
      await pumpScreen(tester, buildTransitionScenario().game);
      expect(find.text(admiralWarning), findsOneWidget);
      expect(launchButton(tester).onPressed, isNull);

      await select(tester, UnitType.domeBreaker, 5);
      expect(launchButton(tester).onPressed, isNull);
    });

    testWidgets('selecting the admiral enables launch', (tester) async {
      await pumpScreen(tester, buildTransitionScenario().game);
      await tester.tap(find.descendant(
        of: find.byWidgetPredicate(
          (w) => w is UnitQuantityRow && w.type == UnitType.abyssAdmiral,
        ),
        matching: find.byIcon(Icons.add),
      ));
      await tester.pumpAndSettle();
      expect(find.text(admiralWarning), findsNothing);
      expect(launchButton(tester).onPressed, isNotNull);
    });

    testWidgets('cancel pops back', (tester) async {
      await pumpScreen(tester, buildTransitionScenario().game);
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();
      expect(find.byType(TransitionArmySelectionScreen), findsNothing);
      expect(find.text('open'), findsOneWidget);
    });

    testWidgets('launch saves, notifies and opens the summary',
        (tester) async {
      final game = buildTransitionScenario().game;
      await pumpScreen(tester, game);
      await select(tester, UnitType.abyssAdmiral, 1);
      await select(tester, UnitType.domeBreaker, 30);
      await tester.tap(find.text('Lancer l\'assaut'));
      await tester.pumpAndSettle();

      expect(repo.saveCallCount, 1);
      expect(changedCount, 1);
      expect(find.byType(TransitionArmySelectionScreen), findsNothing);
      expect(find.byType(TransitionFightSummaryScreen), findsOneWidget);
      expect(
        find.text('BASE CAPTUREE'),
        faille(game).isCaptured ? findsOneWidget : findsNothing,
      );
    });

    testWidgets('failed assault shows the reason and stays',
        (tester) async {
      final game = buildTransitionScenario().game;
      faille(game).capturedBy = 'someone-else';
      await pumpScreen(tester, game);
      await select(tester, UnitType.abyssAdmiral, 1);
      await tester.tap(find.text('Lancer l\'assaut'));
      await tester.pumpAndSettle();

      expect(find.text('Base déjà capturée'), findsOneWidget);
      expect(repo.saveCallCount, 0);
      expect(changedCount, 0);
      expect(find.byType(TransitionArmySelectionScreen), findsOneWidget);
    });
  });
}

import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/map/transition_base.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/screens/game/fight/transition_army_selection_screen.dart';
import 'package:abyss/presentation/screens/game/game_screen_transition_actions.dart';
import 'package:abyss/presentation/widgets/fight/unit_quantity_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_game_repository.dart';
import '../../../helpers/test_svg_helper.dart';
import '../../../helpers/transition_fight_fixtures.dart';
import '../../../integration/transition_test_helper.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  late FakeGameRepository repo;
  late int changed;
  late List<int> levels;

  setUp(() {
    repo = FakeGameRepository();
    changed = 0;
    levels = [];
  });

  Game scenario({bool captured = false, bool level2 = false}) {
    final game = buildTransitionScenario().game;
    game.levels = {
      1: buildMapWithFaille(capturedBy: captured ? 'player-1' : null),
      if (level2) 2: buildMapWithFaille(),
    };
    return game;
  }

  TransitionBase faille(Game g) =>
      g.levels[1]!.cellAt(kFailleX, kFailleY).transitionBase!;

  Future<void> open(WidgetTester tester, void Function(BuildContext) run) async {
    useTallView(tester);
    await tester.pumpWidget(buildLauncherHost('go', run));
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
  }

  Future<void> pickOneScout(WidgetTester tester) async {
    await tester.tap(find.descendant(
      of: find.byWidgetPredicate(
        (w) => w is UnitQuantityRow && w.type == UnitType.scout,
      ),
      matching: find.byIcon(Icons.add),
    ));
    await tester.pumpAndSettle();
  }

  void descend(BuildContext ctx, Game g) => handleDescend(
        ctx, g, repo, faille(g), kFailleX, kFailleY, 1,
        onChanged: () => changed++,
        onLevelSelected: levels.add,
      );

  void reinforce(BuildContext ctx, Game g) => handleSendReinforcements(
      ctx, g, repo, faille(g), kFailleX, kFailleY, 1, () => changed++);

  testWidgets('attack pushes the army selection screen', (tester) async {
    final g = scenario();
    await open(tester, (ctx) => handleAttackTransitionBase(
        ctx, g, repo, faille(g), kFailleX, kFailleY, 1, () => changed++));
    expect(find.byType(TransitionArmySelectionScreen), findsOneWidget);
    expect(find.text('Assaut : Faille Alpha'), findsOneWidget);
  });

  group('handleDescend', () {
    testWidgets('confirming moves units and selects level 2',
        (tester) async {
      final g = scenario(captured: true);
      await open(tester, (ctx) => descend(ctx, g));
      expect(find.text('Descente vers le Niveau 2'), findsOneWidget);
      await pickOneScout(tester);
      await tester.tap(find.text('Descendre (1 unité)'));
      await tester.pumpAndSettle();

      expect(levels, [2]);
      expect(changed, 1);
      expect(repo.saveCallCount, 1);
      expect(g.humanPlayer.unitsOnLevel(2)[UnitType.scout]!.count, 1);
      expect(find.text('Descente au Niveau 2 effectuée'), findsOneWidget);
    });

    testWidgets('does nothing when the base is not captured',
        (tester) async {
      final g = scenario();
      await open(tester, (ctx) => descend(ctx, g));
      await pickOneScout(tester);
      await tester.tap(find.text('Descendre (1 unité)'));
      await tester.pumpAndSettle();

      expect(levels, isEmpty);
      expect(changed, 0);
      expect(repo.saveCallCount, 0);
      expect(find.byType(SnackBar), findsNothing);
    });
  });

  group('handleSendReinforcements', () {
    testWidgets('confirming queues reinforcements', (tester) async {
      final g = scenario(captured: true, level2: true);
      await open(tester, (ctx) => reinforce(ctx, g));
      expect(find.text('Renforts vers le Niveau 2'), findsOneWidget);
      await pickOneScout(tester);
      await tester.tap(find.text('Envoyer (1 unité)'));
      await tester.pumpAndSettle();

      expect(changed, 1);
      expect(repo.saveCallCount, 1);
      expect(g.humanPlayer.pendingReinforcements, hasLength(1));
      expect(find.text('1 unité en transit vers le Niveau 2'), findsOneWidget);
    });

    testWidgets('does nothing when the target level is unexplored',
        (tester) async {
      final g = scenario(captured: true);
      await open(tester, (ctx) => reinforce(ctx, g));
      await pickOneScout(tester);
      await tester.tap(find.text('Envoyer (1 unité)'));
      await tester.pumpAndSettle();

      expect(changed, 0);
      expect(repo.saveCallCount, 0);
      expect(g.humanPlayer.pendingReinforcements, isEmpty);
      expect(find.byType(SnackBar), findsNothing);
    });
  });
}

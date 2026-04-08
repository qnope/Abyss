import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/action/fight_monster_result.dart';
import 'package:abyss/domain/fight/combat_side.dart';
import 'package:abyss/domain/fight/fight_result.dart';
import 'package:abyss/domain/fight/fight_turn_summary.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/screens/game/fight/fight_summary_screen.dart';

import '../../../../helpers/test_svg_helper.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  const lair = MonsterLair(
    difficulty: MonsterDifficulty.easy,
    unitCount: 3,
  );

  FightResult buildFight({required bool playerWins}) {
    return FightResult(
      playerWins ? CombatSide.player : CombatSide.monster,
      2,
      const [
        FightTurnSummary(1, 2, 0, 10, 5, 3, 2, 12, 8),
        FightTurnSummary(2, 2, 0, 7, 3, 3, 0, 9, 0),
      ],
      const [],
      const [],
      3,
      playerWins ? 0 : 3,
    );
  }

  FightMonsterResult buildResult({required bool victory}) {
    return FightMonsterResult.success(
      victory: victory,
      fight: buildFight(playerWins: victory),
      loot: victory
          ? const {ResourceType.algae: 10, ResourceType.ore: 0}
          : const {},
      sent: const {UnitType.scout: 3, UnitType.harpoonist: 2},
      survivorsIntact: const {UnitType.scout: 2, UnitType.harpoonist: 1},
      wounded: const {UnitType.scout: 1, UnitType.harpoonist: 0},
      dead: const {UnitType.scout: 0, UnitType.harpoonist: 1},
    );
  }

  Widget wrap(Widget child) => MaterialApp(home: child);

  group('FightSummaryScreen', () {
    testWidgets('renders VICTOIRE and loot when victory', (tester) async {
      await tester.pumpWidget(wrap(FightSummaryScreen(
        result: buildResult(victory: true),
        lair: lair,
        targetX: 4,
        targetY: 5,
      )));
      await tester.pumpAndSettle();

      expect(find.text('VICTOIRE'), findsOneWidget);
      expect(find.text('Combat en 2 tours'), findsOneWidget);
      expect(find.text('Butin'), findsOneWidget);
      expect(find.text('Algues +10'), findsOneWidget);
      expect(find.text('Combat (4, 5)'), findsOneWidget);
    });

    testWidgets('renders DÉFAITE without loot section when defeat',
        (tester) async {
      await tester.pumpWidget(wrap(FightSummaryScreen(
        result: buildResult(victory: false),
        lair: lair,
        targetX: 1,
        targetY: 2,
      )));
      await tester.pumpAndSettle();

      expect(find.text('DÉFAITE'), findsOneWidget);
      expect(find.text('Butin'), findsNothing);
    });

    testWidgets('renders player accounting rows', (tester) async {
      await tester.pumpWidget(wrap(FightSummaryScreen(
        result: buildResult(victory: true),
        lair: lair,
        targetX: 0,
        targetY: 0,
      )));
      await tester.pumpAndSettle();

      expect(
        find.text('Envoyés: 3 / Intactes: 2 / Blessés: 1 / Morts: 0'),
        findsOneWidget,
      );
      expect(
        find.text('Envoyés: 2 / Intactes: 1 / Blessés: 0 / Morts: 1'),
        findsOneWidget,
      );
      expect(find.text('Ennemis tués: 3/3'), findsOneWidget);
    });

    testWidgets('Retour à la carte pops the route', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (ctx) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).push(
                  MaterialPageRoute<void>(
                    builder: (_) => FightSummaryScreen(
                      result: buildResult(victory: true),
                      lair: lair,
                      targetX: 0,
                      targetY: 0,
                    ),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('VICTOIRE'), findsOneWidget);

      final button = find.text('Retour à la carte');
      await tester.scrollUntilVisible(
        button,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(find.text('VICTOIRE'), findsNothing);
      expect(find.text('open'), findsOneWidget);
    });
  });
}

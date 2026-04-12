import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/action/attack_volcanic_kernel_result.dart';
import 'package:abyss/domain/fight/combat_side.dart';
import 'package:abyss/domain/fight/fight_result.dart';
import 'package:abyss/domain/fight/fight_turn_summary.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/screens/game/fight/kernel_fight_summary_screen.dart';

import '../../../../helpers/test_svg_helper.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  FightResult buildFight({required bool playerWins}) {
    return FightResult(
      winner: playerWins ? CombatSide.player : CombatSide.monster,
      turnCount: 2,
      turnSummaries: const [
        FightTurnSummary(
          turnNumber: 1,
          attacksPlayed: 2,
          critCount: 0,
          damageDealtByPlayer: 10,
          damageDealtByMonster: 5,
          playerAliveAtEnd: 3,
          monsterAliveAtEnd: 2,
          playerHpAtEnd: 12,
          monsterHpAtEnd: 8,
        ),
        FightTurnSummary(
          turnNumber: 2,
          attacksPlayed: 2,
          critCount: 0,
          damageDealtByPlayer: 7,
          damageDealtByMonster: 3,
          playerAliveAtEnd: 3,
          monsterAliveAtEnd: 0,
          playerHpAtEnd: 9,
          monsterHpAtEnd: 0,
        ),
      ],
      initialPlayerCombatants: const [],
      finalPlayerCombatants: const [],
      initialMonsterCount: 3,
      finalMonsterCount: playerWins ? 0 : 3,
    );
  }

  AttackVolcanicKernelResult buildResult({
    required bool victory,
    required bool captured,
  }) {
    return AttackVolcanicKernelResult.success(
      victory: victory,
      captured: captured,
      fight: buildFight(playerWins: victory),
      sent: const {UnitType.abyssAdmiral: 1, UnitType.scout: 2},
      survivorsIntact: const {UnitType.abyssAdmiral: 1, UnitType.scout: 1},
      wounded: const {UnitType.abyssAdmiral: 0, UnitType.scout: 1},
      dead: const {UnitType.abyssAdmiral: 0, UnitType.scout: 0},
    );
  }

  Widget wrap(Widget child) => MaterialApp(home: child);

  group('KernelFightSummaryScreen', () {
    testWidgets('shows NOYAU CAPTURE when captured', (tester) async {
      await tester.pumpWidget(wrap(KernelFightSummaryScreen(
        result: buildResult(victory: true, captured: true),
        targetX: 1,
        targetY: 1,
      )));
      await tester.pumpAndSettle();

      expect(find.text('NOYAU CAPTURE'), findsOneWidget);
    });

    testWidgets('shows VICTOIRE when victory but not captured',
        (tester) async {
      await tester.pumpWidget(wrap(KernelFightSummaryScreen(
        result: buildResult(victory: true, captured: false),
        targetX: 1,
        targetY: 1,
      )));
      await tester.pumpAndSettle();

      expect(find.text('VICTOIRE'), findsOneWidget);
    });

    testWidgets('shows DEFAITE when defeated', (tester) async {
      await tester.pumpWidget(wrap(KernelFightSummaryScreen(
        result: buildResult(victory: false, captured: false),
        targetX: 1,
        targetY: 1,
      )));
      await tester.pumpAndSettle();

      expect(find.text('DEFAITE'), findsOneWidget);
    });

    testWidgets('displays unit accounting rows', (tester) async {
      await tester.pumpWidget(wrap(KernelFightSummaryScreen(
        result: buildResult(victory: true, captured: true),
        targetX: 1,
        targetY: 1,
      )));
      await tester.pumpAndSettle();

      expect(
        find.text('Envoyes: 1 / Intactes: 1 / Blesses: 0 / Morts: 0'),
        findsOneWidget,
      );
      expect(
        find.text('Envoyes: 2 / Intactes: 1 / Blesses: 1 / Morts: 0'),
        findsOneWidget,
      );
    });

    testWidgets('Retour a la carte pops navigation', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (ctx) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).push(
                  MaterialPageRoute<void>(
                    builder: (_) => KernelFightSummaryScreen(
                      result: buildResult(victory: true, captured: true),
                      targetX: 1,
                      targetY: 1,
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
      expect(find.text('NOYAU CAPTURE'), findsOneWidget);

      final button = find.text('Retour a la carte');
      await tester.scrollUntilVisible(
        button,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(find.text('NOYAU CAPTURE'), findsNothing);
      expect(find.text('open'), findsOneWidget);
    });
  });
}

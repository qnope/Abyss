import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/fight/fight_turn_summary.dart';
import 'package:abyss/presentation/widgets/fight/fight_turn_list.dart';

FightTurnSummary _summary({
  required int turnNumber,
  int attacksPlayed = 2,
  int critCount = 0,
  int damageDealtByPlayer = 10,
  int damageDealtByMonster = 5,
  int playerAliveAtEnd = 3,
  int monsterAliveAtEnd = 2,
  int playerHpAtEnd = 12,
  int monsterHpAtEnd = 8,
}) {
  return FightTurnSummary(
    turnNumber: turnNumber,
    attacksPlayed: attacksPlayed,
    critCount: critCount,
    damageDealtByPlayer: damageDealtByPlayer,
    damageDealtByMonster: damageDealtByMonster,
    playerAliveAtEnd: playerAliveAtEnd,
    monsterAliveAtEnd: monsterAliveAtEnd,
    playerHpAtEnd: playerHpAtEnd,
    monsterHpAtEnd: monsterHpAtEnd,
  );
}

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child)));
  }

  group('FightTurnList', () {
    testWidgets('renders one Card per summary', (tester) async {
      final summaries = <FightTurnSummary>[
        _summary(turnNumber: 1),
        _summary(
          turnNumber: 2,
          attacksPlayed: 3,
          damageDealtByPlayer: 7,
          damageDealtByMonster: 4,
          playerAliveAtEnd: 2,
          monsterAliveAtEnd: 1,
          playerHpAtEnd: 9,
          monsterHpAtEnd: 4,
        ),
        _summary(
          turnNumber: 3,
          attacksPlayed: 4,
          damageDealtByPlayer: 5,
          damageDealtByMonster: 2,
          playerAliveAtEnd: 2,
          monsterAliveAtEnd: 0,
          playerHpAtEnd: 7,
          monsterHpAtEnd: 0,
        ),
      ];

      await tester.pumpWidget(wrap(FightTurnList(summaries: summaries)));
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsNWidgets(3));
      expect(find.text('Tour 1'), findsOneWidget);
      expect(find.text('Tour 2'), findsOneWidget);
      expect(find.text('Tour 3'), findsOneWidget);
    });

    testWidgets('tile content shows alive counts and damage totals',
        (tester) async {
      final summary = _summary(turnNumber: 1);

      await tester.pumpWidget(
        wrap(FightTurnList(summaries: [summary])),
      );
      await tester.pumpAndSettle();

      expect(find.text('Alliés vivants: 3'), findsOneWidget);
      expect(find.text('PV alliés: 12'), findsOneWidget);
      expect(find.text('Dégâts infligés: 10'), findsOneWidget);
      expect(find.text('Ennemis vivants: 2'), findsOneWidget);
      expect(find.text('PV ennemis: 8'), findsOneWidget);
      expect(find.text('Dégâts subis: 5'), findsOneWidget);
    });

    testWidgets('shows crit badge when critCount > 0', (tester) async {
      final summary = _summary(turnNumber: 1, critCount: 2);

      await tester.pumpWidget(
        wrap(FightTurnList(summaries: [summary])),
      );
      await tester.pumpAndSettle();

      expect(find.text('Coups critiques: 2'), findsOneWidget);
    });

    testWidgets('hides crit badge when critCount is 0', (tester) async {
      final summary = _summary(turnNumber: 1);

      await tester.pumpWidget(
        wrap(FightTurnList(summaries: [summary])),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Coups critiques'), findsNothing);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/fight/fight_turn_summary.dart';
import 'package:abyss/presentation/widgets/fight/fight_turn_list.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child)));
  }

  group('FightTurnList', () {
    testWidgets('renders one Card per summary', (tester) async {
      final summaries = <FightTurnSummary>[
        const FightTurnSummary(1, 2, 0, 10, 5, 3, 2, 12, 8),
        const FightTurnSummary(2, 3, 0, 7, 4, 2, 1, 9, 4),
        const FightTurnSummary(3, 4, 0, 5, 2, 2, 0, 7, 0),
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
      const summary = FightTurnSummary(1, 2, 0, 10, 5, 3, 2, 12, 8);

      await tester.pumpWidget(
        wrap(const FightTurnList(summaries: [summary])),
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
      const summary = FightTurnSummary(1, 2, 2, 10, 5, 3, 2, 12, 8);

      await tester.pumpWidget(
        wrap(const FightTurnList(summaries: [summary])),
      );
      await tester.pumpAndSettle();

      expect(find.text('Coups critiques: 2'), findsOneWidget);
    });

    testWidgets('hides crit badge when critCount is 0', (tester) async {
      const summary = FightTurnSummary(1, 2, 0, 10, 5, 3, 2, 12, 8);

      await tester.pumpWidget(
        wrap(const FightTurnList(summaries: [summary])),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Coups critiques'), findsNothing);
    });
  });
}

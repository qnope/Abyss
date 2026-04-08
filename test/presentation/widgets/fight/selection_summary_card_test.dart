import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/fight/selection_summary_card.dart';

import '../../../helpers/test_svg_helper.dart';

void main() {
  group('SelectionSummaryCard', () {
    setUp(mockSvgAssets);
    tearDown(clearSvgMocks);

    Widget wrap(Widget child) => MaterialApp(
          theme: AbyssTheme.create(),
          home: Scaffold(body: child),
        );

    testWidgets('displays totals', (tester) async {
      await tester.pumpWidget(
        wrap(
          const SelectionSummaryCard(
            totalAtk: 12,
            totalDef: 7,
            militaryLevel: 0,
          ),
        ),
      );
      expect(find.text('12'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('shows "aucun" when level is 0', (tester) async {
      await tester.pumpWidget(
        wrap(
          const SelectionSummaryCard(
            totalAtk: 0,
            totalDef: 0,
            militaryLevel: 0,
          ),
        ),
      );
      expect(find.text('Bonus militaire : aucun'), findsOneWidget);
    });

    testWidgets('shows percent and level when > 0', (tester) async {
      await tester.pumpWidget(
        wrap(
          const SelectionSummaryCard(
            totalAtk: 0,
            totalDef: 0,
            militaryLevel: 3,
          ),
        ),
      );
      expect(
        find.text('Bonus militaire : +60% ATK (niveau 3)'),
        findsOneWidget,
      );
    });

    testWidgets('updates when totals change', (tester) async {
      await tester.pumpWidget(
        wrap(
          const SelectionSummaryCard(
            totalAtk: 4,
            totalDef: 2,
            militaryLevel: 0,
          ),
        ),
      );
      expect(find.text('4'), findsOneWidget);
      await tester.pumpWidget(
        wrap(
          const SelectionSummaryCard(
            totalAtk: 9,
            totalDef: 5,
            militaryLevel: 0,
          ),
        ),
      );
      expect(find.text('9'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });
  });
}

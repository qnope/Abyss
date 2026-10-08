import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/fight/unit_boost.dart';
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
            boost: UnitBoost.none,
          ),
        ),
      );
      expect(find.text('12'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('shows "aucun" without any boost', (tester) async {
      await tester.pumpWidget(
        wrap(
          const SelectionSummaryCard(
            totalAtk: 0,
            totalDef: 0,
            boost: UnitBoost.none,
          ),
        ),
      );
      expect(find.text('Bonus militaire : aucun'), findsOneWidget);
    });

    testWidgets('lists every non-zero boost', (tester) async {
      await tester.pumpWidget(
        wrap(
          const SelectionSummaryCard(
            totalAtk: 0,
            totalDef: 0,
            boost: UnitBoost(atkPercent: 30, defPercent: 10, hpPercent: 20),
          ),
        ),
      );
      expect(
        find.text('Bonus militaire : +30% ATK, +10% DEF, +20% PV'),
        findsOneWidget,
      );
    });

    testWidgets('omits zero boosts', (tester) async {
      await tester.pumpWidget(
        wrap(
          const SelectionSummaryCard(
            totalAtk: 0,
            totalDef: 0,
            boost: UnitBoost(defPercent: 30),
          ),
        ),
      );
      expect(find.text('Bonus militaire : +30% DEF'), findsOneWidget);
    });

    testWidgets('updates when totals change', (tester) async {
      await tester.pumpWidget(
        wrap(
          const SelectionSummaryCard(
            totalAtk: 4,
            totalDef: 2,
            boost: UnitBoost.none,
          ),
        ),
      );
      expect(find.text('4'), findsOneWidget);
      await tester.pumpWidget(
        wrap(
          const SelectionSummaryCard(
            totalAtk: 9,
            totalDef: 5,
            boost: UnitBoost.none,
          ),
        ),
      );
      expect(find.text('9'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });
  });
}

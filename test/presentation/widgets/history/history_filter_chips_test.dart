import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/history/history_filter.dart';
import 'package:abyss/presentation/widgets/history/history_filter_chips.dart';

void main() {
  group('HistoryFilterChips', () {
    Widget buildApp({
      required HistoryFilter current,
      required ValueChanged<HistoryFilter> onChanged,
    }) {
      return MaterialApp(
        theme: AbyssTheme.create(),
        home: Scaffold(
          body: HistoryFilterChips(current: current, onChanged: onChanged),
        ),
      );
    }

    testWidgets('renders one chip per filter with French labels',
        (tester) async {
      await tester.pumpWidget(
        buildApp(current: HistoryFilter.all, onChanged: (_) {}),
      );

      expect(find.widgetWithText(ChoiceChip, 'Tous'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Combats'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Construction'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Recherche'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Autres'), findsOneWidget);
    });

    testWidgets('marks the current filter as selected', (tester) async {
      await tester.pumpWidget(
        buildApp(current: HistoryFilter.combat, onChanged: (_) {}),
      );

      final selectedChip = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'Combats'),
      );
      expect(selectedChip.selected, isTrue);

      final otherChip = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'Tous'),
      );
      expect(otherChip.selected, isFalse);
    });

    testWidgets('tapping a chip fires onChanged with the matching filter',
        (tester) async {
      final taps = <HistoryFilter>[];

      await tester.pumpWidget(
        buildApp(
          current: HistoryFilter.all,
          onChanged: taps.add,
        ),
      );

      Future<void> tapLabel(String label) async {
        await tester.tap(find.widgetWithText(ChoiceChip, label));
        await tester.pump();
      }

      await tapLabel('Combats');
      await tapLabel('Construction');
      await tapLabel('Recherche');
      await tapLabel('Autres');

      expect(taps, <HistoryFilter>[
        HistoryFilter.combat,
        HistoryFilter.building,
        HistoryFilter.research,
        HistoryFilter.other,
      ]);
    });

    testWidgets('tapping Tous fires HistoryFilter.all when not selected',
        (tester) async {
      final taps = <HistoryFilter>[];
      await tester.pumpWidget(
        buildApp(
          current: HistoryFilter.combat,
          onChanged: taps.add,
        ),
      );

      await tester.tap(find.widgetWithText(ChoiceChip, 'Tous'));
      await tester.pump();

      expect(taps, <HistoryFilter>[HistoryFilter.all]);
    });

    testWidgets('tapping the already-selected chip does not refire',
        (tester) async {
      final taps = <HistoryFilter>[];
      await tester.pumpWidget(
        buildApp(
          current: HistoryFilter.combat,
          onChanged: taps.add,
        ),
      );

      await tester.tap(find.widgetWithText(ChoiceChip, 'Combats'));
      await tester.pump();

      expect(taps, isEmpty);
    });
  });
}

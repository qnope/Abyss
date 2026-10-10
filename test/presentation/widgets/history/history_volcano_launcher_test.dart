import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/domain/volcano/volcano_wave_factory.dart';
import 'package:abyss/presentation/l10n/abyss_locale.dart';
import 'package:abyss/presentation/screens/game/volcano/volcano_summary_screen.dart';
import 'package:abyss/presentation/widgets/history/history_volcano_launcher.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/sheet_opener.dart';
import '../../../helpers/test_svg_helper.dart';
import '../../../helpers/transition_fight_fixtures.dart';

/// A kraken wave fought at the end of turn 23 on a level 4 kernel.
VolcanoEntry _entry({required bool victory}) => VolcanoEntry(
      turn: 23,
      victory: victory,
      wave: VolcanoWaveFactory.fromKernelLevel(4),
      fightResult: buildTestFight(playerWins: victory),
      kernelLevel: 4,
      defenders: const {UnitType.guardian: 5},
      survivorsIntact: const {UnitType.guardian: 2},
      wounded: const {UnitType.guardian: 1},
      dead: const {UnitType.guardian: 2},
    );

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  Future<void> launch(WidgetTester tester, VolcanoEntry entry,
      {void Function()? onClosed}) async {
    useTallView(tester);
    await openSheet(tester, AbyssLocale.fr, (context) {
      openVolcanoSummaryFromEntry(context, entry).then((_) => onClosed?.call());
    });
  }

  VolcanoSummaryScreen screen(WidgetTester tester) =>
      tester.widget<VolcanoSummaryScreen>(find.byType(VolcanoSummaryScreen));

  group('openVolcanoSummaryFromEntry', () {
    testWidgets('opens the wave report of the entry turn', (tester) async {
      await launch(tester, _entry(victory: true));
      expect(find.text('Vague sur le Noyau (tour 23)'), findsOneWidget);
      expect(find.text('Le Noyau tient au niveau 4'), findsOneWidget);
      expect(find.textContaining('Rempart de magma : '), findsOneWidget);
    });

    testWidgets('a lost wave tells the level the kernel fell to',
        (tester) async {
      await launch(tester, _entry(victory: false));
      expect(screen(tester).report.victory, isFalse);
      expect(find.text('Le Noyau retombe au niveau 3'), findsOneWidget);
      expect(find.text('Le Noyau tient au niveau 4'), findsNothing);
    });

    testWidgets('carries over every persisted field', (tester) async {
      final entry = _entry(victory: true);
      await launch(tester, entry);
      final report = screen(tester).report;
      expect(report.turn, 23);
      expect(report.wave, same(entry.wave));
      expect(report.fight, same(entry.fightResult));
      expect(report.kernelLevel, 4);
      expect(report.defenders, entry.defenders);
      expect(report.survivorsIntact, entry.survivorsIntact);
      expect(report.wounded, entry.wounded);
      expect(report.dead, entry.dead);
    });

    testWidgets('Back to base closes the report and completes the future',
        (tester) async {
      var closed = false;
      await launch(tester, _entry(victory: true), onClosed: () => closed = true);
      expect(closed, isFalse);

      await tester.tap(find.text('Retour à la base'));
      await tester.pumpAndSettle();
      expect(closed, isTrue);
      expect(find.byType(VolcanoSummaryScreen), findsNothing);
      expect(find.text('open'), findsOneWidget);
    });
  });
}

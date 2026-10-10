import 'package:abyss/presentation/extensions/history_entry_extensions.dart';
import 'package:abyss/presentation/screens/game/fight/base_assault_summary_screen.dart';
import 'package:abyss/presentation/widgets/history/history_entry_card.dart';
import 'package:abyss/presentation/widgets/history/history_sheet_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/history_entry_samples.dart';
import '../../../helpers/localized_app.dart';
import '../../../helpers/test_svg_helper.dart';
import '../../../helpers/transition_fight_fixtures.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  test('an assault on a base can be opened from the history', () {
    expect(baseAssaultEntry(victory: true, defending: false).isTappable, isTrue);
    expect(baseAssaultEntry(victory: false, defending: true).isTappable, isTrue);
  });

  for (final defending in [false, true]) {
    testWidgets(
      'tapping the entry of the ${defending ? 'defender' : 'attacker'} '
      'opens the report',
      (tester) async {
        useTallView(tester);
        final entry = baseAssaultEntry(victory: true, defending: defending);
        await tester.pumpWidget(
          localizedApp(Scaffold(body: HistorySheetBody(entries: [entry]))),
        );
        await tester.tap(find.byType(HistoryEntryCard));
        await tester.pumpAndSettle();

        expect(find.byType(BaseAssaultSummaryScreen), findsOneWidget);
        expect(
          find.text(defending ? 'Nacre vous a attaqué' : 'Vous avez attaqué Nacre'),
          findsOneWidget,
        );
      },
    );
  }
}

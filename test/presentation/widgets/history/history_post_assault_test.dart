import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/presentation/extensions/history_entry_texts.dart';
import 'package:abyss/presentation/screens/game/fight/base_assault_summary_screen.dart';
import 'package:abyss/presentation/widgets/history/history_entry_card.dart';
import 'package:abyss/presentation/widgets/history/history_sheet_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/history_entry_samples.dart';
import '../../../helpers/l10n_fixtures.dart';
import '../../../helpers/localized_app.dart';
import '../../../helpers/test_svg_helper.dart';
import '../../../helpers/transition_fight_fixtures.dart';

BaseAssaultEntry _post({required bool victory, required bool defending}) =>
    baseAssaultEntry(victory: victory, defending: defending, post: 'faille:1');

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  test('each side reads the fate of the post in its own words', () {
    expect(
      _post(victory: true, defending: false).displayTitle(fr),
      'Faille Bêta prise à Nacre',
    );
    expect(
      _post(victory: false, defending: false).displayTitle(fr),
      'Assaut sur Faille Bêta repoussé par Nacre',
    );
    expect(
      _post(victory: true, defending: true).displayTitle(fr),
      'Faille Bêta prise par Nacre',
    );
    expect(
      _post(victory: false, defending: true).displayTitle(fr),
      'Assaut de Nacre sur Faille Bêta repoussé',
    );
    expect(
      _post(victory: true, defending: false).displayTitle(en),
      'Beta Rift taken from Nacre',
    );
    expect(
      _post(victory: true, defending: false).displayTitle(es).isNotEmpty,
      isTrue,
    );
  });

  for (final defending in [false, true]) {
    testWidgets(
      'the report of a won post attack says what happened to the post, '
      '${defending ? 'defender' : 'attacker'}',
      (tester) async {
        useTallView(tester);
        final entry = _post(victory: true, defending: defending);
        await tester.pumpWidget(
          localizedApp(Scaffold(body: HistorySheetBody(entries: [entry]))),
        );
        await tester.tap(find.byType(HistoryEntryCard));
        await tester.pumpAndSettle();

        expect(find.byType(BaseAssaultSummaryScreen), findsOneWidget);
        expect(
          find.textContaining(defending ? 'est perdue' : 'est à vous'),
          findsOneWidget,
        );
        expect(find.textContaining('Rempart'), findsNothing);
      },
    );
  }
}

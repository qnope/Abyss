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

BaseAssaultEntry _kernel({
  required bool victory,
  required bool defending,
  int after = 0,
}) => baseAssaultEntry(
  victory: victory,
  defending: defending,
  post: 'volcanicKernel',
  kernel: (before: 2, after: after),
);

Future<void> _open(WidgetTester tester, BaseAssaultEntry entry) async {
  useTallView(tester);
  await tester.pumpWidget(
    localizedApp(Scaffold(body: HistorySheetBody(entries: [entry]))),
  );
  await tester.tap(find.byType(HistoryEntryCard));
  await tester.pumpAndSettle();
}

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  test('the history reads a kernel assault like any assault', () {
    final entry = _kernel(victory: true, defending: false);

    expect(entry.displayTitle(fr), 'Assaut réussi contre Nacre');
    expect(entry.displayTitle(en), 'Assault on Nacre succeeded');
  });

  testWidgets('a kernel that only lost a level says which', (tester) async {
    await _open(tester, _kernel(victory: true, defending: false, after: 1));

    expect(find.byType(BaseAssaultSummaryScreen), findsOneWidget);
    expect(find.text('Noyau : niveau 2 → 1'), findsOneWidget);
    expect(find.textContaining('passage'), findsNothing);
  });

  testWidgets('the attacker who takes the kernel is told to build it', (
    tester,
  ) async {
    await _open(tester, _kernel(victory: true, defending: false));

    expect(find.textContaining('Le Noyau est à vous'), findsOneWidget);
  });

  testWidgets('the defender who loses the kernel loses its garrison', (
    tester,
  ) async {
    await _open(tester, _kernel(victory: true, defending: true));

    expect(find.textContaining('Le Noyau est perdu'), findsOneWidget);
  });
}

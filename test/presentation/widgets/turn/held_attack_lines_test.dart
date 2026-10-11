import 'package:abyss/domain/faction/faction_attack_report.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/turn/turn_result.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/screens/game/fight/base_assault_summary_screen.dart';
import 'package:abyss/presentation/widgets/turn/turn_summary_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/history_entry_samples.dart';
import '../../../helpers/localized_app.dart';
import '../../../helpers/test_svg_helper.dart';

/// The summary of a turn where Nacre made the attack of [entry].
Future<void> _open(WidgetTester t, BaseAssaultEntry entry) async {
  final result = TurnResult(
    changes: const [],
    previousTurn: 14,
    newTurn: 15,
    hadRecruitedUnits: false,
    attacks: [
      FactionAttackReport(
        attackerId: 'nacre',
        attackerName: 'Nacre',
        personality: null,
        entry: entry,
      ),
    ],
  );
  await t.pumpWidget(
    localizedApp(
      Scaffold(
        body: Builder(
          builder:
              (ctx) => ElevatedButton(
                onPressed: () => showTurnSummaryDialog(ctx, result: result),
                child: const Text('Open'),
              ),
        ),
      ),
    ),
  );
  await t.tap(find.text('Open'));
  await t.pumpAndSettle();
}

BaseAssaultEntry _post(
  bool taken, {
  String code = 'faille:0',
  Map<UnitType, int> lost = const {},
}) => baseAssaultEntry(
  victory: taken,
  defending: true,
  post: code,
  lostWithPost: lost,
);

BaseAssaultEntry _kernel(bool won, {int after = 2, int garrison = 0}) =>
    baseAssaultEntry(
      victory: won,
      defending: true,
      post: 'volcanicKernel',
      kernel: (before: 3, after: after),
      lostWithPost: {if (garrison > 0) UnitType.harpoonist: garrison},
    );

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  testWidgets('a Faille taken names the passage and the units lost', (t) async {
    await _open(t, _post(true, lost: const {UnitType.scout: 4}));

    expect(find.text('Nacre a pris ta Faille Alpha'), findsOneWidget);
    expect(find.text('Module de descente détruit'), findsOneWidget);
    expect(find.text('4 unités du niveau 2 perdues'), findsOneWidget);
  });

  testWidgets('a Cheminée taken with nobody below loses its capsule only', (
    t,
  ) async {
    await _open(t, _post(true, code: 'cheminee:0'));

    expect(find.text('Nacre a pris ta Cheminée Primaire'), findsOneWidget);
    expect(find.text('Capsule pressurisée détruite'), findsOneWidget);
    expect(find.textContaining('perdue'), findsNothing);
  });

  testWidgets('a post held is a repelled attack', (t) async {
    await _open(t, _post(false));

    expect(
      find.text('Nacre a attaqué ta Faille Alpha : attaque repoussée'),
      findsOneWidget,
    );
    expect(find.textContaining('détruit'), findsNothing);
  });

  testWidgets('a post of an unknown name is shown as is', (t) async {
    await _open(t, _post(true, code: 'Atlantide'));

    expect(find.text('Nacre a pris ta Atlantide'), findsOneWidget);
    expect(find.textContaining('détruit'), findsNothing);
  });

  testWidgets('a kernel down one level', (t) async {
    await _open(t, _kernel(true));

    expect(
      find.text('Nacre a attaqué le Noyau : un niveau perdu'),
      findsOneWidget,
    );
  });

  testWidgets('a kernel taken names the garrison lost', (t) async {
    await _open(t, _kernel(true, after: 0, garrison: 1));

    expect(find.text('Nacre a pris le Noyau'), findsOneWidget);
    expect(find.text('1 unité de la garnison perdue'), findsOneWidget);
  });

  testWidgets('a kernel taken without a garrison loses no unit', (t) async {
    await _open(t, _kernel(true, after: 0));

    expect(find.text('Nacre a pris le Noyau'), findsOneWidget);
    expect(find.textContaining('garnison'), findsNothing);
  });

  testWidgets('a kernel that holds repels the attack', (t) async {
    await _open(t, _kernel(false));

    expect(
      find.text('Nacre a attaqué le Noyau : attaque repoussée'),
      findsOneWidget,
    );
  });

  testWidgets('the button opens the report of the post fight', (t) async {
    await _open(t, _post(true));

    await t.tap(find.text('Voir le rapport'));
    await t.pumpAndSettle();

    expect(find.byType(BaseAssaultSummaryScreen), findsOneWidget);
    expect(find.text('Nacre vous a attaqué'), findsOneWidget);
  });
}

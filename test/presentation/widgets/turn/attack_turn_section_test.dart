import 'dart:math';

import 'package:abyss/domain/action/end_turn_action.dart';
import 'package:abyss/domain/action/end_turn_action_result.dart';
import 'package:abyss/domain/faction/faction_attack_report.dart';
import 'package:abyss/domain/turn/turn_result.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/screens/game/fight/base_assault_summary_screen.dart';
import 'package:abyss/presentation/widgets/turn/attack_turn_section.dart';
import 'package:abyss/presentation/widgets/turn/turn_summary_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/announce_attack_helper.dart';
import '../../../helpers/base_attack_helper.dart';
import '../../../helpers/history_entry_samples.dart';
import '../../../helpers/localized_app.dart';
import '../../../helpers/test_svg_helper.dart';

/// The result of the turn a faction attacks; the human holds [defenders]
/// on the base.
TurnResult _fought({Map<UnitType, int> defenders = const {}}) {
  final two = announceGame();
  station(two.human, defenders);
  announce().execute(two.game, two.rival);
  final result = EndTurnAction(
    random: Random(1),
    playFactions: false,
  ).execute(two.game, two.human);
  return (result as EndTurnActionResult).turnResult!;
}

Widget _app(TurnResult result) => localizedApp(
  Scaffold(
    body: Builder(
      builder:
          (ctx) => ElevatedButton(
            onPressed: () => showTurnSummaryDialog(ctx, result: result),
            child: const Text('Open'),
          ),
    ),
  ),
);

Future<void> _open(WidgetTester t) async {
  await t.tap(find.text('Open'));
  await t.pumpAndSettle();
}

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  testWidgets('a turn without an attack has no attack section', (t) async {
    const result = TurnResult(
      changes: [],
      previousTurn: 3,
      newTurn: 4,
      hadRecruitedUnits: false,
    );
    expect(AttackTurnSection.hasContent(result), isFalse);
    await t.pumpWidget(_app(result));
    await _open(t);
    expect(find.byType(AttackTurnSection), findsNothing);
    expect(find.text('Voir le rapport'), findsNothing);
  });

  testWidgets('a lost fight is a pillaged base', (t) async {
    await t.pumpWidget(_app(_fought()));
    await _open(t);
    expect(find.text('rival a attaqué : base pillée'), findsOneWidget);
  });

  testWidgets('a won defence is a repelled attack', (t) async {
    await t.pumpWidget(_app(_fought(defenders: wall)));
    await _open(t);
    expect(find.text('rival a attaqué : attaque repoussée'), findsOneWidget);
  });

  testWidgets('a won attack that pillages nothing damages the base', (t) async {
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
          entry: baseAssaultEntry(victory: true, defending: true),
        ),
      ],
    );
    await t.pumpWidget(_app(result));
    await _open(t);
    expect(find.text('Nacre a attaqué : base endommagée'), findsOneWidget);
  });

  testWidgets('the button opens the report of the fight', (t) async {
    await t.pumpWidget(_app(_fought()));
    await _open(t);

    await t.tap(find.text('Voir le rapport'));
    await t.pumpAndSettle();

    expect(find.byType(BaseAssaultSummaryScreen), findsOneWidget);
    expect(find.text('rival vous a attaqué'), findsOneWidget);
  });
}

import 'package:abyss/domain/faction/faction_attack_report.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/turn/turn_result.dart';
import 'package:abyss/presentation/widgets/turn/turn_summary_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/localized_app.dart';

/// The summary of a turn where Nacre made the attack of [entry].
Future<void> openAttackSummary(WidgetTester t, BaseAssaultEntry entry) async {
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

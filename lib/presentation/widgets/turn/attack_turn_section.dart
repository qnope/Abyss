import 'package:flutter/material.dart';

import '../../../domain/turn/turn_result.dart';
import '../../l10n/l10n_extension.dart';
import '../../screens/game/fight/base_assault_summary_screen.dart';
import 'attack_report_lines.dart';

/// Attacks of factions on the human this turn, on its base, its posts or
/// its kernel: the lines of each ([AttackReportLines]), and a button to
/// read the report of the fight.
class AttackTurnSection extends StatelessWidget {
  final TurnResult result;

  const AttackTurnSection({super.key, required this.result});

  static bool hasContent(TurnResult result) => result.attacks.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        for (final report in result.attacks) ...[
          AttackReportLines(report: report),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed:
                  () => BaseAssaultSummaryScreen.open(context, report.entry),
              child: Text(l10n.factionAttackReport),
            ),
          ),
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../domain/faction/faction_attack_report.dart';
import '../../../domain/turn/turn_result.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/l10n_extension.dart';
import '../../screens/game/fight/base_assault_summary_screen.dart';
import '../../theme/abyss_colors.dart';
import 'summary_line.dart';

/// Attacks of factions on the base fought at the end of the turn: one
/// line with the outcome, and a button to read the report of the fight.
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
          _line(l10n, report),
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

  Widget _line(AppLocalizations l10n, FactionAttackReport report) {
    final name = report.attackerName;
    final (icon, text, color) = switch (report.outcome) {
      AttackOutcome.repelled => (
        Icons.shield,
        l10n.factionAttackRepelled(name),
        AbyssColors.success,
      ),
      AttackOutcome.damaged => (
        Icons.broken_image,
        l10n.factionAttackDamaged(name),
        AbyssColors.warning,
      ),
      AttackOutcome.pillaged => (
        Icons.dangerous,
        l10n.factionAttackPillaged(name),
        AbyssColors.error,
      ),
    };
    return SummaryLine(icon, text, color);
  }
}

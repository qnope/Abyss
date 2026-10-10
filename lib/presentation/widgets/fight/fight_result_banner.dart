import 'package:flutter/material.dart';

import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import 'fight_report_card.dart';

/// Top of a fight report: victory or defeat, or a custom [label] such as
/// a capture, and how many turns the fight lasted when there was one.
class FightResultBanner extends StatelessWidget {
  final bool victory;
  final String? label;
  final int? turnCount;

  const FightResultBanner({
    super.key,
    required this.victory,
    this.label,
    this.turnCount,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final color = victory ? AbyssColors.biolumCyan : AbyssColors.warning;
    return FightReportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label ?? (victory ? l10n.fightVictory : l10n.fightDefeat),
            style: textTheme.headlineMedium
                ?.copyWith(color: color, fontWeight: FontWeight.bold),
          ),
          if (turnCount != null) ...[
            const SizedBox(height: 4),
            Text(
              l10n.fightTurnCount(turnCount!),
              style: textTheme.bodyMedium
                  ?.copyWith(color: AbyssColors.onSurfaceDim),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../domain/fight/assault/assault_chance.dart';
import '../../../domain/fight/assault/assault_plan.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';

/// The chance of an assault: its rating and the rehearsals won
/// (« Élevées · 19 sur 20 »), over a bar filled to the share won and
/// coloured by the rating.
class AssaultChanceGauge extends StatelessWidget {
  final AssaultChance chance;

  const AssaultChanceGauge({super.key, required this.chance});

  /// The colour telling [rating] at a glance.
  static Color colorOf(AssaultRating rating) => switch (rating) {
        AssaultRating.high => AbyssColors.success,
        AssaultRating.risky => AbyssColors.warning,
        AssaultRating.low => AbyssColors.error,
      };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final Color color = colorOf(chance.rating);
    // An army without admiral is not rehearsed: out of as many as the rest.
    final int rehearsals =
        chance.rehearsals == 0 ? AssaultPlan.rehearsals : chance.rehearsals;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              l10n.assaultPlanChances,
              style: textTheme.bodyMedium?.copyWith(
                color: AbyssColors.onSurfaceDim,
              ),
            ),
            const Spacer(),
            Text(
              l10n.assaultPlanRating(
                  chance.rating.name, chance.wins, rehearsals),
              style: textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: chance.rate,
            minHeight: 8,
            color: color,
            backgroundColor: AbyssColors.surfaceBright,
          ),
        ),
      ],
    );
  }
}

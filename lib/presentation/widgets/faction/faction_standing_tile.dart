import 'package:flutter/material.dart';

import '../../../domain/faction/faction_standing.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import '../../theme/faction_colors.dart';
import '../common/status_pill.dart';

/// One line of the ranking: the colour of the player, its name, what is
/// known of it, and a pill when it has fallen.
class FactionStandingTile extends StatelessWidget {
  final FactionStanding standing;

  const FactionStandingTile({super.key, required this.standing});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final personality = standing.personality;
    final color = personality == null
        ? AbyssColors.biolumCyan
        : FactionColors.of(personality);
    final depth = standing.holdsKernel
        ? l10n.factionRankingKernel
        : l10n.factionRankingDepth(standing.deepestLevel);
    return ListTile(
      leading: Icon(Icons.circle, color: color),
      title: Text(
        standing.isHuman
            ? '${standing.name} (${l10n.factionRankingYou})'
            : standing.name,
        style: standing.hasFallen
            ? const TextStyle(color: AbyssColors.disabled)
            : null,
      ),
      subtitle: Text(
        '${l10n.factionRankingHeadquarters(standing.headquartersLevel)}'
        ' - $depth',
      ),
      trailing: standing.hasFallen
          ? StatusPill(
              label: l10n.factionRankingFallen.toUpperCase(),
              color: AbyssColors.error,
            )
          : null,
    );
  }
}

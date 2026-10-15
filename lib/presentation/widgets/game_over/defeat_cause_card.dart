import 'package:flutter/material.dart';

import '../../../domain/game/defeat_analysis.dart';
import '../../../domain/raid/raid_defence_advisor.dart';
import '../../extensions/monster_lair_extensions.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';

/// "What happened": the raids that made the base fall, each against its
/// defenders, and one piece of advice for the next game.
class DefeatCauseCard extends StatelessWidget {
  final DefeatAnalysis analysis;

  const DefeatCauseCard({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.defeatCauseTitle,
              style: textTheme.titleMedium?.copyWith(
                color: AbyssColors.biolumCyan,
              ),
            ),
            const SizedBox(height: 8),
            for (final LostRaid raid in analysis.raids)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  l10n.defeatCauseRaid(
                    raid.turn,
                    raid.wave.waveLabel(l10n),
                    raid.defenders,
                  ),
                  style: textTheme.bodyMedium,
                ),
              ),
            const SizedBox(height: 12),
            Text(
              _advice(l10n),
              style: textTheme.bodyMedium?.copyWith(color: AbyssColors.warning),
            ),
          ],
        ),
      ),
    );
  }

  String _advice(AppLocalizations l10n) {
    final LostRaid last = analysis.raids.last;
    final int? needed = analysis.harpoonistsNeeded;
    return switch (analysis.advice) {
      DefeatAdvice.raiseAnArmy => l10n.defeatAdviceRaiseAnArmy,
      DefeatAdvice.moreDefenders when needed == null => l10n
          .defeatAdviceTooStrong(RaidDefenceAdvisor.maxAdded),
      DefeatAdvice.moreDefenders => l10n.defeatAdviceMoreDefenders(
        needed!,
        last.defenders,
      ),
      DefeatAdvice.counterTheFamilies => [
        l10n.defeatAdviceWrongUnits,
        if (last.wave.weaknessLabel(l10n) case final String weak) weak,
      ].join(' '),
    };
  }
}

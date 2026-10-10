import 'package:flutter/material.dart';

import '../../../domain/game/game_statistics.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';

/// End-of-game statistics, shared by the victory and defeat screens.
class GameStatisticsCard extends StatelessWidget {
  final GameStatistics statistics;

  const GameStatisticsCard({super.key, required this.statistics});

  @override
  Widget build(BuildContext context) {
    final s = statistics;
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _StatRow(Icons.timer, l10n.gameOverTurnsPlayed(s.turnsPlayed)),
            _StatRow(
              Icons.dangerous,
              l10n.gameOverMonstersDefeated(s.monstersDefeated),
            ),
            _StatRow(Icons.flag, l10n.gameOverBasesCaptured(s.basesCaptured)),
            _StatRow(
              Icons.inventory,
              l10n.gameOverResourcesCollected(s.totalResourcesCollected),
            ),
            _StatRow(Icons.shield, l10n.gameOverRaidsRepelled(s.raidsRepelled)),
            _StatRow(Icons.heart_broken, l10n.gameOverRaidsLost(s.raidsLost)),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatRow(this.icon, this.label);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AbyssColors.biolumCyan),
            const SizedBox(width: 12),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      );
}

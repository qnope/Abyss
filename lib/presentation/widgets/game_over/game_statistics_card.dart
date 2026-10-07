import 'package:flutter/material.dart';

import '../../../domain/game/game_statistics.dart';
import '../../theme/abyss_colors.dart';

/// End-of-game statistics, shared by the victory and defeat screens.
class GameStatisticsCard extends StatelessWidget {
  final GameStatistics statistics;

  const GameStatisticsCard({super.key, required this.statistics});

  @override
  Widget build(BuildContext context) {
    final s = statistics;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _StatRow(Icons.timer, 'Tours joués : ${s.turnsPlayed}'),
            _StatRow(Icons.dangerous, 'Monstres vaincus : ${s.monstersDefeated}'),
            _StatRow(Icons.flag, 'Bases capturées : ${s.basesCaptured}'),
            _StatRow(
              Icons.inventory,
              'Ressources collectées : ${s.totalResourcesCollected}',
            ),
            _StatRow(Icons.shield, 'Raids repoussés : ${s.raidsRepelled}'),
            _StatRow(Icons.heart_broken, 'Raids perdus : ${s.raidsLost}'),
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

import 'package:flutter/material.dart';
import '../../../domain/fight/fight_turn_summary.dart';
import '../../theme/abyss_colors.dart';

class FightTurnList extends StatelessWidget {
  final List<FightTurnSummary> summaries;

  const FightTurnList({super.key, required this.summaries});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: summaries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) => _FightTurnTile(summary: summaries[i]),
    );
  }
}

class _FightTurnTile extends StatelessWidget {
  final FightTurnSummary summary;

  const _FightTurnTile({required this.summary});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tour ${summary.turnNumber}',
              style: textTheme.titleLarge?.copyWith(
                color: AbyssColors.biolumCyan,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _StatsColumn(lines: [
                    'Alliés vivants: ${summary.playerAliveAtEnd}',
                    'PV alliés: ${summary.playerHpAtEnd}',
                    'Dégâts infligés: ${summary.damageDealtByPlayer}',
                  ]),
                ),
                Expanded(
                  child: _StatsColumn(lines: [
                    'Ennemis vivants: ${summary.monsterAliveAtEnd}',
                    'PV ennemis: ${summary.monsterHpAtEnd}',
                    'Dégâts subis: ${summary.damageDealtByMonster}',
                  ]),
                ),
              ],
            ),
            if (summary.critCount > 0) ...[
              const SizedBox(height: 8),
              _CritBadge(critCount: summary.critCount),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatsColumn extends StatelessWidget {
  final List<String> lines;

  const _StatsColumn({required this.lines});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final line in lines)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              line,
              style: textTheme.bodyMedium
                  ?.copyWith(color: AbyssColors.onSurface),
            ),
          ),
      ],
    );
  }
}

class _CritBadge extends StatelessWidget {
  final int critCount;

  const _CritBadge({required this.critCount});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AbyssColors.surfaceDim,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AbyssColors.warning.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        'Coups critiques: $critCount',
        style: textTheme.labelMedium?.copyWith(color: AbyssColors.warning),
      ),
    );
  }
}

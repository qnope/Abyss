import 'package:flutter/material.dart';
import '../../../../domain/action/attack_transition_base_result.dart';
import '../../../../domain/map/transition_base.dart';
import '../../../../domain/unit/unit_type.dart';
import '../../../theme/abyss_colors.dart';
import '../../../widgets/fight/fight_turn_list.dart';
import '../../../widgets/unit/unit_icon.dart';

class TransitionFightSummaryScreen extends StatelessWidget {
  final AttackTransitionBaseResult result;
  final TransitionBase transitionBase;
  final int targetX;
  final int targetY;

  const TransitionFightSummaryScreen({
    super.key,
    required this.result,
    required this.transitionBase,
    required this.targetX,
    required this.targetY,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Assaut ($targetX, $targetY)')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _buildResultBanner(context),
          const SizedBox(height: 12),
          _buildPlayerAccounting(context),
          const SizedBox(height: 12),
          _buildMonsterSection(context),
          if (result.fight != null) ...[
            const SizedBox(height: 12),
            FightTurnList(summaries: result.fight!.turnSummaries),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Retour a la carte'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultBanner(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final label = result.captured
        ? 'BASE CAPTUREE'
        : result.victory
            ? 'VICTOIRE'
            : 'DEFAITE';
    final color = result.victory
        ? AbyssColors.biolumCyan
        : AbyssColors.warning;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                )),
            if (result.fight != null) ...[
              const SizedBox(height: 4),
              Text(
                'Combat en ${result.fight!.turnCount} tours',
                style: textTheme.bodyMedium
                    ?.copyWith(color: AbyssColors.onSurfaceDim),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerAccounting(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vos unites',
                style: textTheme.titleMedium
                    ?.copyWith(color: AbyssColors.biolumCyan)),
            const SizedBox(height: 8),
            for (final t in result.sent.keys) _unitRow(context, t),
          ],
        ),
      ),
    );
  }

  Widget _unitRow(BuildContext context, UnitType type) {
    final textTheme = Theme.of(context).textTheme;
    final sent = result.sent[type] ?? 0;
    final intact = result.survivorsIntact[type] ?? 0;
    final wounded = result.wounded[type] ?? 0;
    final dead = result.dead[type] ?? 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        UnitIcon(type: type, size: 28),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Envoyes: $sent / Intactes: $intact '
            '/ Blesses: $wounded / Morts: $dead',
            style: textTheme.bodyMedium
                ?.copyWith(color: AbyssColors.onSurface),
          ),
        ),
      ]),
    );
  }

  Widget _buildMonsterSection(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    if (result.fight == null) return const SizedBox.shrink();
    final initial = result.fight!.initialMonsterCount;
    final killed = initial - result.fight!.finalMonsterCount;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Gardiens elimines: $killed/$initial',
          style: textTheme.bodyMedium
              ?.copyWith(color: AbyssColors.onSurface),
        ),
      ),
    );
  }
}

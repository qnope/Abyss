import 'package:flutter/material.dart';

import '../../../domain/game/defeat_checker.dart';
import '../../../domain/raid/noise_rules.dart';
import '../../../domain/raid/raid_state.dart';
import '../../extensions/monster_lair_extensions.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';

/// Thin strip under the resource bar: the noise gauge, or the alert of
/// the raid on its way.
class RaidStatusBar extends StatelessWidget {
  final RaidState state;
  final int currentTurn;

  const RaidStatusBar({
    super.key,
    required this.state,
    required this.currentTurn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AbyssColors.surfaceDim,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          state.isIncoming ? _alert(context) : _gauge(context),
          if (state.lostInARow > 0) _lostStreak(context),
        ],
      ),
    );
  }

  Widget _lostStreak(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          const Icon(Icons.heart_broken, size: 16, color: AbyssColors.error),
          const SizedBox(width: 8),
          Text(
            "Raids perdus d'affilée : ${state.lostInARow}/"
            '${DefeatChecker.lostRaidsLimit}',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AbyssColors.error),
          ),
        ],
      ),
    );
  }

  Widget _gauge(BuildContext context) {
    final ratio = (state.noise / NoiseRules.threshold).clamp(0.0, 1.0);
    return Row(
      children: [
        const Icon(Icons.graphic_eq, size: 16, color: AbyssColors.warning),
        const SizedBox(width: 8),
        Text('Bruit', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              color: AbyssColors.warning,
              backgroundColor: AbyssColors.trench,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${state.noise}/${NoiseRules.threshold}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _alert(BuildContext context) {
    final arrival = state.arrivalTurn!;
    final when = arrival <= currentTurn
        ? 'à la fin de ce tour'
        : 'à la fin du tour $arrival';
    final style = Theme.of(context).textTheme.bodyMedium;
    final l10n = context.l10n;
    final weakness = state.incoming!.weaknessLabel(l10n);
    return Row(
      children: [
        const Icon(Icons.warning_amber, size: 18, color: AbyssColors.error),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Raid $when : ${state.incoming!.waveLabel(l10n)}',
                style: style?.copyWith(color: AbyssColors.error),
              ),
              if (weakness != null)
                Text(
                  weakness,
                  style: style?.copyWith(color: AbyssColors.success),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

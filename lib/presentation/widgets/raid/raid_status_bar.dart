import 'package:flutter/material.dart';

import '../../../domain/raid/noise_rules.dart';
import '../../../domain/raid/raid_state.dart';
import '../../extensions/monster_lair_extensions.dart';
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
      child: state.isIncoming ? _alert(context) : _gauge(context),
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
    return Row(
      children: [
        const Icon(Icons.warning_amber, size: 18, color: AbyssColors.error),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Raid $when : ${state.incoming!.waveLabel}',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AbyssColors.error),
          ),
        ),
      ],
    );
  }
}

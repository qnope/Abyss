import 'package:flutter/material.dart';
import '../../../domain/game/player.dart';
import '../../../domain/volcano/kernel_garrison.dart';
import '../../extensions/monster_lair_extensions.dart';
import '../../extensions/rampart_texts.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';

/// Part of the kernel sheet once it is captured: its level, the magma
/// rampart, the garrison and the next kraken wave, with the buttons that
/// move units in and out of the garrison.
class KernelGarrisonPanel extends StatelessWidget {
  final Player player;
  final VoidCallback onGarrison;
  final VoidCallback onWithdraw;

  const KernelGarrisonPanel({
    super.key,
    required this.player,
    required this.onGarrison,
    required this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    final level = KernelGarrison.kernelLevelOf(player);
    final size = KernelGarrison.sizeOf(player);
    final wave = player.volcanoState.incoming;
    final state = player.volcanoState;
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.volcanoKernelLevel(level), style: style),
        if (level > 0)
          Text(l10n.volcanoMagmaRampart(RampartTexts.magma(l10n, level)),
              style: style?.copyWith(color: AbyssColors.coralPink)),
        Text(l10n.volcanoGarrison(size), style: style),
        if (wave != null) ...[
          const SizedBox(height: 8),
          Text(l10n.volcanoNextWave(wave.waveLabel(l10n)),
              style: style?.copyWith(color: AbyssColors.error)),
        ],
        if (state.levelsLost > 0)
          Text(l10n.volcanoLevelsLost(state.levelsLost),
              style: style?.copyWith(color: AbyssColors.onSurfaceDim)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: onGarrison,
                child: Text(l10n.volcanoGarrisonUnits),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: size > 0 ? onWithdraw : null,
                child: Text(l10n.volcanoWithdraw),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

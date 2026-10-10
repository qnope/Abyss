import 'package:flutter/material.dart';

import '../../../domain/game/player.dart';
import '../../../domain/volcano/kernel_garrison.dart';
import '../../extensions/monster_lair_extensions.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';

/// Thin strip under the raid bar once the kraken waves have started: the
/// wave due at the end of the turn against the kernel's garrison.
class VolcanoStatusBar extends StatelessWidget {
  final Player player;

  const VolcanoStatusBar({super.key, required this.player});

  /// Whether the bar has something to show for [player].
  static bool isShown(Player player) => player.volcanoState.isIncoming;

  @override
  Widget build(BuildContext context) {
    final wave = player.volcanoState.incoming;
    if (wave == null) return const SizedBox.shrink();
    final style = Theme.of(context).textTheme.bodySmall;
    final size = KernelGarrison.sizeOf(player);
    final level = KernelGarrison.kernelLevelOf(player);
    return Container(
      color: AbyssColors.surfaceDim,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      child: Row(
        children: [
          const Icon(Icons.volcano, size: 16, color: AbyssColors.coralPink),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Noyau niv. $level, fin du tour : ${wave.waveLabel(context.l10n)} '
              'contre une garnison de $size',
              style: style?.copyWith(
                color: size == 0 ? AbyssColors.error : AbyssColors.coralPink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

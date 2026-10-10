import 'package:flutter/material.dart';

import '../../../domain/game/game.dart';
import '../../../domain/game/player.dart';
import '../../../domain/map/monster_lair.dart';
import '../../../domain/volcano/kernel_garrison.dart';
import '../../extensions/monster_lair_extensions.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';

/// Warning shown before ending a turn when a kraken wave hits the kernel
/// at its end and no unit guards it.
class VolcanoDueWarning extends StatelessWidget {
  final MonsterLair wave;

  const VolcanoDueWarning({super.key, required this.wave});

  /// The warning for [player], or `null` when no wave hits an empty
  /// garrison this turn.
  static VolcanoDueWarning? of(Game game, Player player) {
    final state = player.volcanoState;
    if (!state.isIncoming || state.arrivalTurn! > game.turn) return null;
    if (KernelGarrison.sizeOf(player) > 0) return null;
    return VolcanoDueWarning(wave: state.incoming!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Row(children: [
          const Icon(Icons.volcano, color: AbyssColors.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.l10n.volcanoDueWarning(wave.waveLabel(context.l10n)),
              style: const TextStyle(color: AbyssColors.error),
            ),
          ),
        ]),
      ],
    );
  }
}

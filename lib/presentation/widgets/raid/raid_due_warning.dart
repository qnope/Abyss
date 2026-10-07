import 'package:flutter/material.dart';

import '../../../domain/map/monster_lair.dart';
import '../../extensions/monster_lair_extensions.dart';
import '../../theme/abyss_colors.dart';

/// Warning shown before ending a turn when a raid hits at its end: the
/// wave against the defenders standing on the base level.
class RaidDueWarning extends StatelessWidget {
  final MonsterLair wave;
  final int defenderCount;

  const RaidDueWarning({
    super.key,
    required this.wave,
    required this.defenderCount,
  });

  @override
  Widget build(BuildContext context) {
    final defenders = defenderCount == 0
        ? 'aucun défenseur'
        : '$defenderCount ${defenderCount > 1 ? 'défenseurs' : 'défenseur'}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Row(children: [
          const Icon(Icons.warning_amber, color: AbyssColors.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Raid ce tour : ${wave.waveLabel} contre $defenders',
              style: const TextStyle(color: AbyssColors.error),
            ),
          ),
        ]),
      ],
    );
  }
}

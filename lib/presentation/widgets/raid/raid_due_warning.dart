import 'package:flutter/material.dart';

import '../../../domain/game/player.dart';
import '../../../domain/map/monster_lair.dart';
import '../../../domain/raid/raid_battle.dart';
import '../../extensions/monster_lair_extensions.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';

/// Warning shown before ending a turn when a raid hits at its end: the
/// wave against the defenders standing on the base level.
class RaidDueWarning extends StatelessWidget {
  final MonsterLair wave;
  final int defenderCount;

  /// Whether a school of predators strikes, fought like a raid.
  final bool predators;

  /// Whether losing this raid ends the game.
  final bool lastChance;

  const RaidDueWarning({
    super.key,
    required this.wave,
    required this.defenderCount,
    this.predators = false,
    this.lastChance = false,
  });

  /// Units of [player] that defend the base level against a raid.
  static int defenderCountOf(Player player) => RaidBattle.defendersOf(player)
      .values
      .fold<int>(0, (sum, count) => sum + count);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final attacker =
        predators ? l10n.randomEventPredatorsLabel : l10n.raidName;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Row(children: [
          const Icon(Icons.warning_amber, color: AbyssColors.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.raidDueThisTurn(
                attacker,
                wave.waveLabel(l10n),
                l10n.raidDefenders(defenderCount),
              ),
              style: const TextStyle(color: AbyssColors.error),
            ),
          ),
        ]),
        if (lastChance)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              l10n.raidLastChance,
              style: const TextStyle(
                color: AbyssColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}

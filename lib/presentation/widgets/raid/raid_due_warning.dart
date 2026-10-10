import 'package:flutter/material.dart';

import '../../../domain/game/player.dart';
import '../../../domain/map/monster_lair.dart';
import '../../../domain/raid/raid_battle.dart';
import '../../extensions/monster_lair_extensions.dart';
import '../../theme/abyss_colors.dart';

/// Warning shown before ending a turn when a raid hits at its end: the
/// wave against the defenders standing on the base level.
class RaidDueWarning extends StatelessWidget {
  final MonsterLair wave;
  final int defenderCount;

  /// What strikes: a raid, or anything fought like one.
  final String attacker;

  /// Whether losing this raid ends the game.
  final bool lastChance;

  const RaidDueWarning({
    super.key,
    required this.wave,
    required this.defenderCount,
    this.attacker = 'Raid',
    this.lastChance = false,
  });

  /// Units of [player] that defend the base level against a raid.
  static int defenderCountOf(Player player) => RaidBattle.defendersOf(player)
      .values
      .fold<int>(0, (sum, count) => sum + count);

  /// e.g. « aucun défenseur », « 3 défenseurs ».
  static String defendersLabel(int count) => count == 0
      ? 'aucun défenseur'
      : '$count ${count > 1 ? 'défenseurs' : 'défenseur'}';

  @override
  Widget build(BuildContext context) {
    final defenders = defendersLabel(defenderCount);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Row(children: [
          const Icon(Icons.warning_amber, color: AbyssColors.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$attacker ce tour : ${wave.waveLabel} contre $defenders',
              style: const TextStyle(color: AbyssColors.error),
            ),
          ),
        ]),
        if (lastChance)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Si ce raid est perdu, la partie est terminée.',
              style: TextStyle(
                color: AbyssColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}

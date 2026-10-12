import 'package:flutter/material.dart';

import '../../../domain/game/game.dart';
import '../../../domain/game/player.dart';
import '../../../domain/leviathan/leviathan_defence_advisor.dart';
import '../../../domain/leviathan/leviathan_resolver.dart';
import '../../../domain/unit/unit.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';

/// Warning shown before ending the turn the guardians strike the Faille
/// when the level that defends it is empty, or too weak to hold as
/// [LeviathanDefenceAdvisor] rehearses it. It never blocks the turn.
class LeviathanDueWarning extends StatelessWidget {
  final int defenders;
  final int level;

  const LeviathanDueWarning({
    super.key,
    required this.defenders,
    required this.level,
  });

  /// The warning for [player], or `null` when no counter-attack strikes
  /// this turn or the defenders should hold.
  static LeviathanDueWarning? of(Game game, Player player) {
    final attack = LeviathanResolver.announcedNow(game);
    if (attack == null) return null;
    final int level = attack.defendingLevel;
    final int defenders = player
        .unitsOnLevel(level)
        .values
        .fold(0, (int sum, Unit u) => sum + u.count);
    if (defenders > 0) {
      final int? needed = LeviathanDefenceAdvisor.unitsFor(game, player, level);
      if (needed != null && defenders >= needed) return null;
    }
    return LeviathanDueWarning(defenders: defenders, level: level);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Row(
          children: [
            const Icon(Icons.warning_amber, color: AbyssColors.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                context.l10n.leviathanDueWarning(defenders, level),
                style: const TextStyle(color: AbyssColors.error),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

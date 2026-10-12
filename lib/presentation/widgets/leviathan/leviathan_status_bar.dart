import 'package:flutter/material.dart';

import '../../../domain/game/game.dart';
import '../../../domain/leviathan/leviathan_force.dart';
import '../../../domain/leviathan/leviathan_resolver.dart';
import '../../../domain/unit/unit.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import '../common/threat_banner.dart';

/// Red strip under the resource bar on the turn the guardians strike the
/// human's Faille: the force, and the units of the level that defends
/// it. Tapping it opens the Faille, when [onOpen] is given.
class LeviathanStatusBar extends StatelessWidget {
  final Game game;
  final ValueChanged<LeviathanAnnouncement>? onOpen;

  const LeviathanStatusBar({super.key, required this.game, this.onOpen});

  /// Whether the bar has something to show in [game].
  static bool isShown(Game game) =>
      LeviathanResolver.announcedNow(game) != null;

  @override
  Widget build(BuildContext context) {
    final attack = LeviathanResolver.announcedNow(game);
    if (attack == null) return const SizedBox.shrink();
    final level = attack.defendingLevel;
    final defenders = game.humanPlayer
        .unitsOnLevel(level)
        .values
        .fold(0, (int sum, Unit u) => sum + u.count);
    final open = onOpen;
    return ThreatBanner(
      icon: Icons.warning_amber,
      color: AbyssColors.error,
      title: context.l10n.leviathanBannerTitle,
      detail: context.l10n.leviathanBannerForce(
        LeviathanForce.sentinels,
        level,
        defenders,
      ),
      onTap: open == null ? null : () => open(attack),
    );
  }
}

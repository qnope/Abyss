import 'package:flutter/material.dart';

import '../../../domain/game/defeat_checker.dart';
import '../../../domain/game/game_statistics.dart';
import '../../theme/abyss_colors.dart';
import 'game_over_screen.dart';

/// Shown when the base falls after too many raids lost in a row.
class DefeatScreen extends StatelessWidget {
  final GameStatistics statistics;

  /// Turn at the end of which the base fell.
  final int fallTurn;
  final VoidCallback onReturnToMenu;

  /// Shares the lost game as a replay; hidden when `null`.
  final VoidCallback? onExport;

  const DefeatScreen({
    super.key,
    required this.statistics,
    required this.fallTurn,
    required this.onReturnToMenu,
    this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return GameOverScreen(
      emblemAsset: 'assets/icons/buildings/headquarters.svg',
      title: 'DÉFAITE',
      titleColor: AbyssColors.error,
      subtitle: 'Votre base est tombée à la fin du tour $fallTurn, après '
          '${DefeatChecker.lostRaidsLimit} raids perdus d\'affilée.',
      statistics: statistics,
      actions: [
        GameOverAction(
          label: 'Retour au menu',
          onPressed: onReturnToMenu,
          primary: true,
        ),
        if (onExport != null)
          GameOverAction(label: 'Exporter la partie', onPressed: onExport!),
      ],
    );
  }
}

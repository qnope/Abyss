import 'package:flutter/material.dart';

import '../../../domain/game/defeat_checker.dart';
import '../../../domain/game/game_statistics.dart';
import '../../l10n/l10n_extension.dart';
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
    final l10n = context.l10n;
    return GameOverScreen(
      emblemAsset: 'assets/icons/buildings/headquarters.svg',
      title: l10n.gameOverDefeatTitle,
      titleColor: AbyssColors.error,
      subtitle: l10n.gameOverDefeatSubtitle(
        fallTurn,
        DefeatChecker.lostRaidsLimit,
      ),
      statistics: statistics,
      actions: [
        GameOverAction(
          label: l10n.gameOverBackToMenu,
          onPressed: onReturnToMenu,
          primary: true,
        ),
        if (onExport != null)
          GameOverAction(label: l10n.screenExportGame, onPressed: onExport!),
      ],
    );
  }
}

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

  /// Name of the faction that tamed the volcano first; `null` when the
  /// base fell to raids.
  final String? winnerName;
  final VoidCallback onReturnToMenu;

  /// Shares the lost game as a replay; hidden when `null`.
  final VoidCallback? onExport;

  const DefeatScreen({
    super.key,
    required this.statistics,
    required this.fallTurn,
    this.winnerName,
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
      subtitle: winnerName == null
          ? l10n.gameOverDefeatSubtitle(fallTurn, DefeatChecker.lostRaidsLimit)
          : l10n.gameOverFactionWonSubtitle(winnerName!, fallTurn),
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

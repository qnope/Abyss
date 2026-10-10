import 'package:flutter/material.dart';

import '../../../domain/game/game_statistics.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import 'game_over_screen.dart';

class VictoryScreen extends StatelessWidget {
  final GameStatistics statistics;
  final VoidCallback onContinue;
  final VoidCallback onReturnToMenu;

  const VictoryScreen({
    super.key,
    required this.statistics,
    required this.onContinue,
    required this.onReturnToMenu,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return GameOverScreen(
      emblemAsset: 'assets/icons/terrain/volcanic_kernel.svg',
      title: l10n.gameOverVictoryTitle,
      titleColor: AbyssColors.warning,
      subtitle: l10n.gameOverVictorySubtitle,
      statistics: statistics,
      actions: [
        GameOverAction(
          label: l10n.gameOverContinueFreePlay,
          onPressed: onContinue,
          primary: true,
        ),
        GameOverAction(
          label: l10n.gameOverBackToMenu,
          onPressed: onReturnToMenu,
        ),
      ],
    );
  }
}

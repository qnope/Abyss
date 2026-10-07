import 'package:flutter/material.dart';

import '../../../domain/game/game_statistics.dart';
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
    return GameOverScreen(
      emblemAsset: 'assets/icons/terrain/volcanic_kernel.svg',
      title: 'VICTOIRE !',
      titleColor: AbyssColors.warning,
      subtitle: 'Vous avez conquis le Noyau Volcanique !',
      statistics: statistics,
      actions: [
        GameOverAction(
          label: 'Continuer en mode libre',
          onPressed: onContinue,
          primary: true,
        ),
        GameOverAction(label: 'Retour au menu', onPressed: onReturnToMenu),
      ],
    );
  }
}

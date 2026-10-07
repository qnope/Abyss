import 'package:flutter/material.dart';

import '../../../domain/game/game_statistics.dart';
import '../../theme/abyss_colors.dart';
import '../../widgets/common/raster_svg.dart';
import '../../widgets/game_over/game_statistics_card.dart';

/// A button at the bottom of the end-of-game screen.
class GameOverAction {
  final String label;
  final VoidCallback onPressed;

  /// The primary action is filled, the others are outlined.
  final bool primary;

  const GameOverAction({
    required this.label,
    required this.onPressed,
    this.primary = false,
  });
}

/// End-of-game layout: an emblem, a title, a subtitle, the statistics and
/// the actions. Victory and defeat are two configurations of it.
class GameOverScreen extends StatelessWidget {
  final String emblemAsset;
  final String title;
  final Color titleColor;
  final String subtitle;
  final GameStatistics statistics;
  final List<GameOverAction> actions;

  const GameOverScreen({
    super.key,
    required this.emblemAsset,
    required this.title,
    required this.titleColor,
    required this.subtitle,
    required this.statistics,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RasterSvg(assetPath: emblemAsset, size: 96),
              const SizedBox(height: 16),
              Text(
                title,
                style: textTheme.displayMedium?.copyWith(
                  color: titleColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: textTheme.bodyLarge
                    ?.copyWith(color: AbyssColors.onSurfaceDim),
                textAlign: TextAlign.center,
              ),
              const Divider(height: 32),
              GameStatisticsCard(statistics: statistics),
              const SizedBox(height: 32),
              for (final action in actions) _button(action),
            ],
          ),
        ),
      ),
    );
  }

  Widget _button(GameOverAction action) {
    final label = Text(action.label);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        child: action.primary
            ? ElevatedButton(onPressed: action.onPressed, child: label)
            : OutlinedButton(onPressed: action.onPressed, child: label),
      ),
    );
  }
}

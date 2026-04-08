import 'package:flutter/material.dart';
import '../../../data/game_repository.dart';
import '../../theme/abyss_colors.dart';
import 'load_game_screen.dart';
import 'new_game_screen.dart';

class MainMenuScreen extends StatelessWidget {
  final GameRepository repository;

  const MainMenuScreen({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ABYSSES',
                style: textTheme.displayLarge?.copyWith(
                  color: AbyssColors.biolumCyan,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Les profondeurs vous attendent',
                style: textTheme.bodyLarge?.copyWith(
                  color: AbyssColors.onSurfaceDim,
                ),
              ),
              const SizedBox(height: 64),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _startNewGame(context),
                  child: const Text('Nouvelle Partie'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _loadGame(context),
                  child: const Text('Charger une partie'),
                ),
              ),
              const SizedBox(height: 32),
              _BetaWarning(textTheme: textTheme),
            ],
          ),
        ),
      ),
    );
  }

  void _startNewGame(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => NewGameScreen(repository: repository),
      ),
    );
  }

  void _loadGame(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LoadGameScreen(repository: repository),
      ),
    );
  }
}

class _BetaWarning extends StatelessWidget {
  final TextTheme textTheme;

  const _BetaWarning({required this.textTheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AbyssColors.warning.withValues(alpha: 0.08),
        border: Border.all(
          color: AbyssColors.warning.withValues(alpha: 0.4),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AbyssColors.warning,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Version bêta',
                  style: textTheme.titleSmall?.copyWith(
                    color: AbyssColors.warning,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Le jeu est en cours de développement. Les sauvegardes '
                  'pourront être supprimées et votre progression perdue '
                  "tant que le jeu est en bêta.",
                  style: textTheme.bodySmall?.copyWith(
                    color: AbyssColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

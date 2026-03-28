import 'package:flutter/material.dart';
import '../../presentation/theme/abyss_colors.dart';
import 'new_game_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

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
            ],
          ),
        ),
      ),
    );
  }

  void _startNewGame(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const NewGameScreen(),
      ),
    );
  }
}

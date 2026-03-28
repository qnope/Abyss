import 'package:flutter/material.dart';
import '../../domain/game.dart';
import '../../presentation/theme/abyss_colors.dart';

class GameScreen extends StatelessWidget {
  final Game game;

  const GameScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Tour ${game.turn}'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.waves,
              size: 64,
              color: AbyssColors.biolumCyan,
            ),
            const SizedBox(height: 16),
            Text(
              'Bienvenue, ${game.player.name}',
              style: textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Votre aventure dans les abysses commence...',
              style: textTheme.bodyLarge?.copyWith(
                color: AbyssColors.onSurfaceDim,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

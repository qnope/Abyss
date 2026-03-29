import 'package:flutter/material.dart';
import '../../data/game_repository.dart';
import '../../domain/game.dart';
import '../../presentation/theme/abyss_colors.dart';
import 'main_menu_screen.dart';

class GameScreen extends StatelessWidget {
  final Game game;
  final GameRepository repository;

  const GameScreen({
    super.key,
    required this.game,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Tour ${game.turn}'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Sauvegarder et quitter',
            onPressed: () => _saveAndQuit(context),
          ),
        ],
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

  Future<void> _saveAndQuit(BuildContext context) async {
    await repository.save(game);

    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => MainMenuScreen(repository: repository),
      ),
      (_) => false,
    );
  }
}

import 'package:flutter/material.dart';
import '../../data/game_repository.dart';
import '../../domain/game.dart';
import '../theme/abyss_colors.dart';
import '../widgets/saved_game_card.dart';
import 'game_screen.dart';

class LoadGameScreen extends StatefulWidget {
  final GameRepository repository;

  const LoadGameScreen({super.key, required this.repository});

  @override
  State<LoadGameScreen> createState() => _LoadGameScreenState();
}

class _LoadGameScreenState extends State<LoadGameScreen> {
  late List<Game> _games;

  @override
  void initState() {
    super.initState();
    _games = widget.repository.loadAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Charger une partie')),
      body: _games.isEmpty ? _buildEmpty() : _buildList(),
    );
  }

  Widget _buildEmpty() {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.folder_open,
            size: 64,
            color: AbyssColors.onSurfaceDim,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune partie sauvegardée',
            style: textTheme.bodyLarge?.copyWith(
              color: AbyssColors.onSurfaceDim,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _games.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, index) {
        final game = _games[index];
        return SavedGameCard(
          game: game,
          onLoad: () => _loadGame(game),
          onDelete: () => _confirmDelete(index),
        );
      },
    );
  }

  void _loadGame(Game game) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => GameScreen(game: game),
      ),
      (_) => false,
    );
  }

  Future<void> _confirmDelete(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la partie ?'),
        content: Text(
          'La partie de ${_games[index].player.name} '
          'sera définitivement supprimée.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Supprimer',
              style: TextStyle(color: AbyssColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.repository.delete(index);
      setState(() => _games = widget.repository.loadAll());
    }
  }
}

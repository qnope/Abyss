import 'package:flutter/material.dart';
import '../../../data/game_repository.dart';
import '../../../domain/game/game.dart';
import '../../../domain/game/game_status.dart';
import '../../../domain/game/save_sections.dart';
import '../../theme/abyss_colors.dart';
import '../../widgets/backdrop/abyss_backdrop.dart';
import '../../widgets/save/confirm_save_deletion.dart';
import '../../widgets/save/save_list.dart';
import '../game/game_screen.dart';
import '../game/game_screen_defeat_actions.dart';

/// The saved games, over the dimmed deep sea, ready to be resumed or
/// deleted.
class LoadGameScreen extends StatefulWidget {
  final GameRepository repository;

  /// Tells the time the last played dates are told against.
  final DateTime Function() now;

  const LoadGameScreen({
    super.key,
    required this.repository,
    this.now = DateTime.now,
  });

  @override
  State<LoadGameScreen> createState() => _LoadGameScreenState();
}

class _LoadGameScreenState extends State<LoadGameScreen> {
  late SaveSections _sections = _load();

  SaveSections _load() => SaveSections.of(widget.repository.loadAll());

  @override
  Widget build(BuildContext context) {
    return AbyssBackdrop(
      dimmed: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Charger une partie'),
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
        ),
        body:
            _sections.isEmpty
                ? _buildEmpty()
                : SaveList(
                  sections: _sections,
                  now: widget.now(),
                  onOpen: _loadGame,
                  onDelete: _confirmDelete,
                ),
      ),
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

  void _loadGame(Game game) {
    if (game.status == GameStatus.defeat) {
      showDefeatScreen(context, game, widget.repository);
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => GameScreen(game: game, repository: widget.repository),
      ),
      (_) => false,
    );
  }

  Future<void> _confirmDelete(Game game) async {
    final name = game.humanPlayer.name;
    if (!await confirmSaveDeletion(context, name)) return;
    await widget.repository.deleteGame(game);
    if (mounted) setState(() => _sections = _load());
  }
}

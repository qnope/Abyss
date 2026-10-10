import 'package:flutter/material.dart';
import '../../../data/game_repository.dart';
import '../../../domain/game/game.dart';
import '../../../domain/game/save_sections.dart';
import '../../l10n/l10n_extension.dart';
import '../../widgets/backdrop/abyss_backdrop.dart';
import '../../widgets/save/confirm_save_deletion.dart';
import '../../widgets/save/empty_saves.dart';
import '../../widgets/save/save_list.dart';
import '../game/resume_game.dart';
import 'new_game_screen.dart';

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
    // The snow barely shows under the veil: moving it would repaint the
    // screen every frame for nothing.
    return AbyssBackdrop(
      dimmed: true,
      animate: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(context.l10n.saveLoadTitle),
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
        ),
        body:
            _sections.isEmpty
                ? EmptySaves(onNewGame: _startNewGame)
                : SaveList(
                  sections: _sections,
                  now: widget.now(),
                  onOpen: _loadGame,
                  onDelete: _confirmDelete,
                ),
      ),
    );
  }

  void _startNewGame() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => NewGameScreen(repository: widget.repository),
      ),
    );
  }

  void _loadGame(Game game) => resumeGame(context, game, widget.repository);

  Future<void> _confirmDelete(Game game) async {
    final name = game.humanPlayer.name;
    if (!await confirmSaveDeletion(context, name)) return;
    await widget.repository.deleteGame(game);
    if (mounted) setState(() => _sections = _load());
  }
}

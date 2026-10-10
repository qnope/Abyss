import 'package:flutter/material.dart';
import '../../../data/game_repository.dart';
import '../../../domain/game/game.dart';
import '../../widgets/common/replay_export_dialog.dart';
import '../../widgets/common/settings_dialog.dart';
import '../../widgets/history/history_sheet.dart';
import '../menu/main_menu_screen.dart';

/// Opens the settings of [game], then follows the way out the player
/// picked. [onClosed] redraws the screen as soon as they close: the
/// guide may have been switched on or off.
Future<void> openGameSettings(
  BuildContext context,
  Game game,
  GameRepository repository, {
  required VoidCallback onClosed,
}) async {
  final result = await showSettingsDialog(
    context,
    game: game,
    repository: repository,
  );
  if (!context.mounted) return;
  onClosed();
  switch (result) {
    case SettingsDialogResult.cancel:
      return;
    case SettingsDialogResult.openHistory:
      await showHistorySheet(context, player: game.humanPlayer);
    case SettingsDialogResult.exportReplay:
      await showReplayExportDialog(context, game);
    case SettingsDialogResult.saveAndQuit:
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

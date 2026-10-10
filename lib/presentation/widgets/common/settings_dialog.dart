import 'package:flutter/material.dart';
import '../../../data/game_repository.dart';
import '../../../domain/game/game.dart';
import '../../theme/abyss_colors.dart';
import 'guide_settings.dart';

enum SettingsDialogResult { cancel, saveAndQuit, openHistory, exportReplay }

/// The settings of [game]: its guide switches, saved through [repository]
/// as they change, and the ways out of the game.
Future<SettingsDialogResult> showSettingsDialog(
  BuildContext context, {
  required Game game,
  required GameRepository repository,
}) async {
  final result = await showDialog<SettingsDialogResult>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Paramètres'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Partie en cours',
              style: Theme.of(ctx).textTheme.labelLarge?.copyWith(
                color: AbyssColors.onSurfaceDim,
              ),
            ),
            GuideSettings(game: game, repository: repository),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.pop(ctx, SettingsDialogResult.cancel),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () =>
              Navigator.pop(ctx, SettingsDialogResult.openHistory),
          child: const Text('Voir l\'historique'),
        ),
        TextButton(
          onPressed: () =>
              Navigator.pop(ctx, SettingsDialogResult.exportReplay),
          child: const Text('Exporter la partie'),
        ),
        ElevatedButton(
          onPressed: () =>
              Navigator.pop(ctx, SettingsDialogResult.saveAndQuit),
          child: const Text('Sauvegarder et quitter'),
        ),
      ],
    ),
  );
  return result ?? SettingsDialogResult.cancel;
}

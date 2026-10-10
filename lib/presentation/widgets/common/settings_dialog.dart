import 'package:flutter/material.dart';
import '../../../data/game_repository.dart';
import '../../../domain/game/game.dart';
import '../../l10n/l10n_extension.dart';
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
      title: Text(ctx.l10n.screenSettings),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ctx.l10n.screenGameInProgress,
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
          child: Text(ctx.l10n.commonCancel),
        ),
        TextButton(
          onPressed: () =>
              Navigator.pop(ctx, SettingsDialogResult.openHistory),
          child: Text(ctx.l10n.screenViewHistory),
        ),
        TextButton(
          onPressed: () =>
              Navigator.pop(ctx, SettingsDialogResult.exportReplay),
          child: Text(ctx.l10n.screenExportGame),
        ),
        ElevatedButton(
          onPressed: () =>
              Navigator.pop(ctx, SettingsDialogResult.saveAndQuit),
          child: Text(ctx.l10n.screenSaveAndQuit),
        ),
      ],
    ),
  );
  return result ?? SettingsDialogResult.cancel;
}

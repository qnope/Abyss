import 'package:flutter/material.dart';
import '../../../data/game_repository.dart';
import '../../../domain/game/game.dart';
import '../../l10n/l10n_extension.dart';
import '../../l10n/language_scope.dart';
import '../../theme/abyss_colors.dart';
import 'guide_settings.dart';
import 'language_picker.dart';

enum SettingsDialogResult { cancel, saveAndQuit, openHistory, exportReplay }

/// The settings of [game]: the game language when the app has a
/// [LanguageScope], the guide switches saved through [repository] as they
/// change, and the ways out of the game.
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
            ..._language(ctx),
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

/// The [LanguagePicker] of the app settings above [context], if any.
List<Widget> _language(BuildContext context) {
  final settings = LanguageScope.maybeOf(context);
  if (settings == null) return const [];
  return [LanguagePicker(settings: settings), const Divider(height: 24)];
}

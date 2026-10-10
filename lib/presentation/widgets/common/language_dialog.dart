import 'package:flutter/material.dart';
import '../../../data/language_settings.dart';
import '../../l10n/l10n_extension.dart';
import 'language_picker.dart';

/// The settings reachable outside a game: the [LanguagePicker] of
/// [settings] and a way to close it. The dialog follows a language change
/// at once, like the screen below it.
Future<void> showLanguageDialog(
  BuildContext context,
  LanguageSettings settings,
) {
  return showDialog<void>(
    context: context,
    builder:
        (ctx) => AlertDialog(
          title: Text(ctx.l10n.screenSettings),
          content: SingleChildScrollView(
            child: LanguagePicker(settings: settings),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(ctx.l10n.commonClose),
            ),
          ],
        ),
  );
}

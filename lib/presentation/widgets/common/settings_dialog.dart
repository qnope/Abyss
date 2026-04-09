import 'package:flutter/material.dart';

enum SettingsDialogResult { cancel, saveAndQuit, openHistory }

Future<SettingsDialogResult> showSettingsDialog(BuildContext context) async {
  final result = await showDialog<SettingsDialogResult>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Parametres'),
      content: const Text('Que souhaitez-vous faire ?'),
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

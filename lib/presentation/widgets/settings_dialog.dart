import 'package:flutter/material.dart';

Future<bool> showSettingsDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Parametres'),
      content: const Text('Que souhaitez-vous faire ?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Sauvegarder et quitter'),
        ),
      ],
    ),
  );
  return result ?? false;
}

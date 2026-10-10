import 'package:flutter/material.dart';

import '../../theme/abyss_colors.dart';

/// Asks whether the game of [playerName] is to be deleted for good.
/// Completes with `true` only when the player confirms.
Future<bool> confirmSaveDeletion(BuildContext context, String playerName) {
  return showDialog<bool>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text('Supprimer la partie ?'),
          content: Text(
            'La partie de $playerName sera définitivement supprimée.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Supprimer',
                style: TextStyle(color: AbyssColors.error),
              ),
            ),
          ],
        ),
  ).then((confirmed) => confirmed ?? false);
}

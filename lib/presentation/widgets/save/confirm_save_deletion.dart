import 'package:flutter/material.dart';

import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';

/// Asks whether the game of [playerName] is to be deleted for good.
/// Completes with `true` only when the player confirms.
Future<bool> confirmSaveDeletion(BuildContext context, String playerName) {
  return showDialog<bool>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text(context.l10n.saveDeleteTitle),
          content: Text(context.l10n.saveDeleteMessage(playerName)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.l10n.commonCancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                context.l10n.saveDelete,
                style: const TextStyle(color: AbyssColors.error),
              ),
            ),
          ],
        ),
  ).then((confirmed) => confirmed ?? false);
}

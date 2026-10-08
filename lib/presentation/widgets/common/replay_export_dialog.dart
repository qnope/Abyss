import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../../domain/game/game.dart';
import '../../../domain/replay/replay_export.dart';
import '../../theme/abyss_colors.dart';

/// Offers to share the game as a replay file (a JSON scenario that
/// `bin/simulate.dart` plays again), or to copy it as text.
Future<void> showReplayExportDialog(BuildContext context, Game game) {
  return showDialog<void>(
    context: context,
    builder: (_) => ReplayExportDialog(game: game),
  );
}

class ReplayExportDialog extends StatelessWidget {
  final Game game;

  const ReplayExportDialog({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final bool available = ReplayExport.canExport(game);
    return AlertDialog(
      title: const Text('Exporter la partie'),
      content: Text(available ? _summary() : _unavailable),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fermer'),
        ),
        if (available)
          TextButton(
            onPressed: () => _copy(context),
            child: const Text('Copier'),
          ),
        if (available)
          ElevatedButton(
            onPressed: () => _share(context),
            child: const Text('Partager le fichier'),
          ),
      ],
    );
  }

  static const String _unavailable =
      'Cette partie a commencé avant l\'enregistrement des replays : '
      'elle ne peut pas être exportée. Les nouvelles parties le peuvent.';

  String _summary() {
    final int actions = game.replay!.actions.values.fold(
      0,
      (int sum, List<String> turn) => sum + turn.length,
    );
    final String exactness =
        game.replay!.exact
            ? 'Les combats et les raids seront rejoués à l\'identique.'
            : 'Certains dés n\'ont pas été enregistrés : le rejeu pourra '
                'différer sur quelques combats.';
    return 'Le fichier ${ReplayExport.fileName(game)} contient les '
        '$actions actions des ${game.turn} tours joués.\n\n$exactness';
  }

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: ReplayExport.toText(game)));
    if (!context.mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Replay copié dans le presse-papiers'),
        backgroundColor: AbyssColors.surfaceBright,
      ),
    );
  }

  Future<void> _share(BuildContext context) async {
    final String name = ReplayExport.fileName(game);
    final Uint8List bytes = utf8.encode(ReplayExport.toText(game));
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(bytes, name: name, mimeType: 'application/json'),
        ],
        fileNameOverrides: [name],
        title: 'Replay Abysses',
        sharePositionOrigin:
            box == null ? null : box.localToGlobal(Offset.zero) & box.size,
      ),
    );
    if (context.mounted) Navigator.pop(context);
  }
}

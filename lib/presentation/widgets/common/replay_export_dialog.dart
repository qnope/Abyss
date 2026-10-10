import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../../domain/game/game.dart';
import '../../../domain/replay/replay_export.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/l10n_extension.dart';
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
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.screenExportGame),
      content: Text(
        available ? _summary(l10n) : l10n.screenReplayUnavailable,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.commonClose),
        ),
        if (available)
          TextButton(
            onPressed: () => _copy(context),
            child: Text(l10n.screenCopy),
          ),
        if (available)
          ElevatedButton(
            onPressed: () => _share(context),
            child: Text(l10n.screenShareFile),
          ),
      ],
    );
  }

  String _summary(AppLocalizations l10n) {
    final int actions = game.replay!.actions.values.fold(
      0,
      (int sum, List<String> turn) => sum + turn.length,
    );
    final String exactness =
        game.replay!.exact ? l10n.screenReplayExact : l10n.screenReplayInexact;
    final String content = l10n.screenReplaySummary(
      ReplayExport.fileName(game),
      l10n.screenReplayActions(actions),
      l10n.screenReplayTurns(game.turn),
    );
    return '$content\n\n$exactness';
  }

  Future<void> _copy(BuildContext context) async {
    final String copied = context.l10n.screenReplayCopied;
    await Clipboard.setData(ClipboardData(text: ReplayExport.toText(game)));
    if (!context.mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(copied),
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
        title: context.l10n.screenReplayShareTitle,
        sharePositionOrigin:
            box == null ? null : box.localToGlobal(Offset.zero) & box.size,
      ),
    );
    if (context.mounted) Navigator.pop(context);
  }
}

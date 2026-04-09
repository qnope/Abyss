import 'package:flutter/material.dart';

import '../../../domain/game/player.dart';
import 'history_sheet_body.dart';

/// Opens the history modal bottom sheet showing the player's action log.
///
/// The sheet takes a snapshot of [Player.historyEntries] at open time.
/// Because the sheet body owns its own filter state, dismissing and
/// reopening the sheet naturally resets the filter to `HistoryFilter.all`.
Future<void> showHistorySheet(
  BuildContext context, {
  required Player player,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => HistorySheetBody(entries: player.historyEntries),
  );
}

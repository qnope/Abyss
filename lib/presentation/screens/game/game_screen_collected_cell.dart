import 'package:flutter/material.dart';

import '../../../domain/game/game.dart';
import '../../../domain/map/map_cell.dart';
import '../../../domain/map/rival_taker.dart';
import '../../l10n/l10n_extension.dart';
import '../../widgets/faction/faction_emblem.dart';
import '../../widgets/map/cell_info_sheet.dart';

/// Tells what is left of a collected [cell]: nothing, and who took it
/// when a faction came first.
void showCollectedCellSheet(BuildContext context, Game game, MapCell cell) {
  final l10n = context.l10n;
  final rival = RivalTaker.of(game, cell);
  if (rival == null) {
    showCellInfoSheet(
      context,
      title: l10n.screenAlreadyVisitedTitle,
      message: l10n.screenAlreadyVisitedMessage,
      icon: Icons.check_circle_outline,
    );
    return;
  }
  showCellInfoSheet(
    context,
    title: l10n.screenTakenByRivalTitle(game.players[rival.id]!.name),
    message: l10n.screenTakenByRivalMessage,
    illustration: FactionEmblem.assetOf(rival.personality),
  );
}

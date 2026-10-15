import 'package:flutter/material.dart';

import '../../../domain/game/game.dart';
import '../../../domain/game/player.dart';
import '../event/event_status_bar.dart';
import '../leviathan/leviathan_status_bar.dart';
import '../objective/objective_banner.dart';
import '../objective/objectives_sheet.dart';
import '../raid/raid_status_bar.dart';
import '../volcano/volcano_status_bar.dart';

/// The strips stacked under the resource bar: the noise gauge or the raid
/// alert, the guardians coming back to the Faille, the kraken wave, the random events, then the current
/// objective, which opens the sheet of the objectives when tapped.
class GameStatusBars extends StatelessWidget {
  final Game game;
  final Player player;

  /// Reopens the card of the event waiting for a choice.
  final VoidCallback? onOpenEvent;

  /// Opens the map on a level, the one of the Faille under attack.
  final ValueChanged<int>? onOpenMap;

  const GameStatusBars({
    super.key,
    required this.game,
    required this.player,
    this.onOpenEvent,
    this.onOpenMap,
  });

  @override
  Widget build(BuildContext context) {
    final currentTurn = game.turn;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RaidStatusBar(state: player.raidState, currentTurn: currentTurn),
        LeviathanStatusBar(
          game: game,
          onOpen: onOpenMap == null ? null : (a) => onOpenMap!(a.level),
        ),
        VolcanoStatusBar(player: player),
        EventStatusBar(
          state: player.eventState,
          currentTurn: currentTurn,
          onOpen: onOpenEvent,
        ),
        ObjectiveBanner(
          game: game,
          player: player,
          onTap: () => showObjectivesSheet(context, game: game, player: player),
        ),
      ],
    );
  }
}

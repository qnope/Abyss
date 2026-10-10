import 'package:flutter/material.dart';

import '../../../domain/game/player.dart';
import '../event/event_status_bar.dart';
import '../raid/raid_status_bar.dart';
import '../volcano/volcano_status_bar.dart';

/// The strips stacked under the resource bar: the noise gauge or the raid
/// alert, the kraken wave, then the random events.
class GameStatusBars extends StatelessWidget {
  final Player player;
  final int currentTurn;

  /// Reopens the card of the event waiting for a choice.
  final VoidCallback? onOpenEvent;

  const GameStatusBars({
    super.key,
    required this.player,
    required this.currentTurn,
    this.onOpenEvent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RaidStatusBar(state: player.raidState, currentTurn: currentTurn),
        VolcanoStatusBar(player: player),
        EventStatusBar(
          state: player.eventState,
          currentTurn: currentTurn,
          onOpen: onOpenEvent,
        ),
      ],
    );
  }
}

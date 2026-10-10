import 'package:flutter/material.dart';

import '../../../data/game_repository.dart';
import '../../../domain/action/action_executor.dart';
import '../../../domain/action/choose_event_action.dart';
import '../../../domain/event/random_event_type.dart';
import '../../../domain/game/game.dart';
import '../../extensions/random_event_type_extensions.dart';
import '../../widgets/event/event_card.dart';
import '../../widgets/event/event_card_data.dart';

/// Opens the card of [type]. When the player picks an option of the event
/// waiting for a choice, runs a [ChooseEventAction], saves the game and
/// says what was chosen.
Future<void> openEventCard(
  BuildContext context,
  Game game,
  GameRepository repository,
  RandomEventType type,
  VoidCallback onChanged,
) async {
  final data = EventCardData.of(game, type);
  final accept = await showEventCard(context, data);
  if (accept == null) return;
  final player = game.humanPlayer;
  final result = ActionExecutor().execute(
    ChooseEventAction(accept: accept),
    game,
    player,
  );
  if (result.isSuccess) await repository.save(game);
  onChanged();
  if (!context.mounted) return;
  final chosen = data.choices.firstWhere((c) => c.accept == accept).label;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(result.isSuccess
        ? '${type.label} : $chosen'
        : result.reason ?? 'Action impossible'),
  ));
}

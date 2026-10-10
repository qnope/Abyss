import '../event/event_effects.dart';
import '../game/game.dart';
import '../game/player.dart';
import '../history/history_entry.dart';
import 'action.dart';
import 'action_result.dart';
import 'action_type.dart';
import 'choose_event_result.dart';

/// Settles the random event waiting for the player's choice: [accept]
/// takes the first option, otherwise the prudent one.
class ChooseEventAction extends Action {
  final bool accept;

  ChooseEventAction({required this.accept});

  @override
  ActionType get type => ActionType.chooseEvent;

  @override
  String get description =>
      accept ? "Accepter l'événement" : "Refuser l'événement";

  @override
  ActionResult validate(Game game, Player player) {
    final state = player.eventState;
    if (!state.hasPending) {
      return const ActionResult.failure('Aucun événement en attente');
    }
    if (state.pendingTurn != game.turn) {
      return const ActionResult.failure("Ce n'est pas le tour de ce choix");
    }
    return const ActionResult.success();
  }

  @override
  ActionResult execute(Game game, Player player) {
    final ActionResult validation = validate(game, player);
    if (!validation.isSuccess) return validation;
    final event = player.eventState.pending!;
    EventEffects.apply(game, player, event, accept: accept, turn: game.turn);
    player.eventState.clearPending();
    return ChooseEventResult.success(event);
  }

  @override
  HistoryEntry? makeHistoryEntry(
    Game game,
    Player player,
    ActionResult result,
    int turn,
  ) => EventEntry(
    turn: turn,
    type: (result as ChooseEventResult).event,
    accepted: accept,
    defaulted: false,
  );
}

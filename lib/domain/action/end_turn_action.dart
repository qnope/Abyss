import '../game/game.dart';
import '../game/player.dart';
import '../history/entries/turn_end_entry_factory.dart';
import '../history/history_entry.dart';
import '../turn/turn_resolver.dart';
import 'action.dart';
import 'action_result.dart';
import 'action_type.dart';
import 'end_turn_action_result.dart';

/// Wraps [TurnResolver] so that ending a turn flows through the uniform
/// [Action] + [ActionExecutor] pipeline, which then auto-appends the
/// resulting [TurnEndEntry] via [makeHistoryEntry].
class EndTurnAction extends Action {
  @override
  ActionType get type => ActionType.endTurn;

  @override
  String get description => 'Terminer le tour';

  @override
  ActionResult validate(Game game, Player player) =>
      const ActionResult.success();

  @override
  ActionResult execute(Game game, Player player) {
    final result = TurnResolver().resolve(game);
    return EndTurnActionResult.success(turnResult: result);
  }

  @override
  HistoryEntry? makeHistoryEntry(
    Game game,
    Player player,
    ActionResult result,
    int turn,
  ) {
    if (result is! EndTurnActionResult) return null;
    final tr = result.turnResult;
    if (tr == null) return null;
    // TurnResolver has already advanced game.turn at this point, so the
    // turn that just ended is (turn - 1). We use TurnResult.previousTurn
    // as the source of truth because it is recorded before the increment.
    return const TurnEndEntryFactory().fromTurnResult(tr.previousTurn, tr);
  }
}

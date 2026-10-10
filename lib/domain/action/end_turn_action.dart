import 'dart:math';

import '../faction/faction_attack_report.dart';
import '../faction/faction_turns.dart';
import '../game/game.dart';
import '../game/player.dart';
import '../history/entries/turn_end_entry_factory.dart';
import '../history/history_entry.dart';
import '../turn/turn_resolver.dart';
import 'action.dart';
import 'action_result.dart';
import 'action_type.dart';
import 'announced_attack_resolver.dart';
import 'end_turn_action_result.dart';

/// Wraps [TurnResolver] so that ending a turn flows through the uniform
/// [Action] + [ActionExecutor] pipeline, which then auto-appends the
/// resulting [TurnEndEntry] via [makeHistoryEntry].
///
/// The attacks of factions announced for this turn are fought first,
/// after the factions played, with or without the brains (a replay).
class EndTurnAction extends Action {
  /// Drives the raid fights; `null` keeps them unseeded.
  final Random? random;

  /// Whether the factions play their turn first; a replay turns it off,
  /// as the journal already holds what the brains did.
  final bool playFactions;

  EndTurnAction({this.random, this.playFactions = true});

  @override
  ActionType get type => ActionType.endTurn;

  @override
  String get description => 'Terminer le tour';

  @override
  ActionResult validate(Game game, Player player) =>
      const ActionResult.success();

  @override
  ActionResult execute(Game game, Player player) {
    if (playFactions) FactionTurns.playAll(game);
    final attacks = <FactionAttackReport>[
      for (final fought in AnnouncedAttackResolver.fight(game)) fought.report,
    ];
    final result = TurnResolver().resolve(
      game,
      random: random,
      attacks: attacks,
    );
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

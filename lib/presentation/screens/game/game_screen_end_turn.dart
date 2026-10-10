import 'package:flutter/material.dart';
import '../../../data/game_repository.dart';
import '../../../domain/action/action_executor.dart';
import '../../../domain/action/end_turn_action.dart';
import '../../../domain/action/end_turn_action_result.dart';
import '../../../domain/game/game.dart';
import '../../../domain/replay/seeded_random.dart';
import '../../../domain/turn/turn_result.dart';
import '../../widgets/turn/turn_confirmation_dialog.dart';
import 'game_screen_turn_helpers.dart';

/// Asks the player to confirm the end of the turn of [game], with what it
/// will make, spend and cost; once confirmed, ends it and saves the game
/// through [repository]. Returns what the turn did, `null` when the
/// player stayed on the turn.
Future<TurnResult?> confirmAndEndTurn(
  BuildContext context,
  Game game,
  GameRepository repository,
) async {
  final human = game.humanPlayer;
  final production = computeProduction(game, human);
  final consumption = computeConsumption(game, human);
  final deactivated = computeBuildingsToDeactivate(game, human, production);
  final confirmed = await showTurnConfirmationDialog(
    context,
    currentTurn: game.turn,
    production: production,
    consumption: consumption,
    buildingsToDeactivate: deactivated,
    unitsToLose: computeUnitsToLose(game, human, deactivated),
    pendingExplorationCount: human.pendingExplorations.length,
    raidWarning: dueWarnings(game, human),
  );
  if (!confirmed || !context.mounted) return null;
  final action = EndTurnAction(random: SeededRandom.fresh());
  final executed = ActionExecutor().execute(action, game, human);
  final result = (executed as EndTurnActionResult).turnResult!;
  await repository.save(game);
  return result;
}

import '../turn/turn_result.dart';
import 'action_result.dart';

/// Result produced by [EndTurnAction.execute].
///
/// Carries the human player's [TurnResult] so callers (the game screen)
/// can still display the turn summary dialog after routing end-of-turn
/// through the uniform [ActionExecutor] pipeline.
class EndTurnActionResult extends ActionResult {
  final TurnResult? turnResult;

  EndTurnActionResult.success({required this.turnResult}) : super.success();

  const EndTurnActionResult.failure(super.reason)
      : turnResult = null,
        super.failure();
}

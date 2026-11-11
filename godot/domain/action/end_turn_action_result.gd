class_name EndTurnActionResult
extends ActionResult
## lib/domain/action/end_turn_action_result.dart: the result of
## EndTurnAction.execute. It carries the human's TurnResult so that the
## game screen can show the summary of the turn once the end of the turn
## went through ActionExecutor.

## The human's result, or null (always null on a failure).
var turn_result: TurnResult


## `reason_` null is a success (ActionResult).
func _init(reason_: Variant, turn_result_: TurnResult = null) -> void:
	super(reason_)
	turn_result = turn_result_


## `EndTurnActionResult.success(turnResult: ...)`; its parameter takes a
## default (domain/README.md, "Abstract classes").
static func success(turn_result_: TurnResult = null) -> EndTurnActionResult:
	return EndTurnActionResult.new(null, turn_result_)


## `EndTurnActionResult.failure`: no turn result.
static func failure(reason_: ActionFailure.Value) -> EndTurnActionResult:
	return EndTurnActionResult.new(reason_)

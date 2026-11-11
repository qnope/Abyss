extends TestCase
## test/domain/action/end_turn_action_result_test.dart: the result of the
## end of a turn.


func test_success_carries_the_turn_result_and_no_reason() -> void:
	var turn := TurnResult.new([], 3, 4, false)
	var result := EndTurnActionResult.success(turn)

	assert_true(result is ActionResult)
	assert_true(result.is_success)
	assert_null(result.reason)
	assert_eq(result.turn_result, turn)


func test_success_may_carry_no_turn_result() -> void:
	var result := EndTurnActionResult.success(null)
	assert_true(result.is_success)
	assert_null(result.turn_result)


func test_failure_keeps_the_reason_and_drops_the_turn_result() -> void:
	var reason: ActionFailure.Value = DartEnum.by_name(ActionFailure.Value, "gameOver")
	var result := EndTurnActionResult.failure(reason)

	assert_false(result.is_success)
	assert_eq(result.reason, ActionFailure.Value.GAME_OVER)
	assert_null(result.turn_result)

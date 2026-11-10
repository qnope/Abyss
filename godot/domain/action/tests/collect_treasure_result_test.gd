extends TestCase
## test/domain/action/collect_treasure_result_test.dart: what a search
## gave.


func test_success_exposes_is_success_true_and_the_provided_deltas_map() -> void:
	var deltas: Dictionary[ResourceType.Value, int] = {ResourceType.Value.ALGAE: 5, ResourceType.Value.ORE: 2}
	var result := CollectTreasureResult.success(deltas)
	assert_true(result.is_success)
	assert_null(result.reason)
	assert_eq(result.deltas, deltas)


func test_failure_exposes_is_success_false_the_reason_and_empty_deltas() -> void:
	var result := CollectTreasureResult.failure(ActionFailure.Value.NOTHING_TO_COLLECT)
	assert_false(result.is_success)
	assert_eq(result.reason, ActionFailure.Value.NOTHING_TO_COLLECT)
	assert_true(result.deltas.is_empty())


func test_is_assignable_to_an_action_result_variable() -> void:
	var collect := CollectTreasureResult.success({})
	var result: ActionResult = collect
	assert_true(result.is_success)

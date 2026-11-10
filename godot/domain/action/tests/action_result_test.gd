extends TestCase
## test/domain/action/action_result_test.dart: what an action answers.


func test_success_has_is_success_true_and_reason_null() -> void:
	var result := ActionResult.success()
	assert_true(result.is_success)
	assert_null(result.reason)


func test_failure_has_is_success_false_and_the_given_reason() -> void:
	var result := ActionResult.failure(ActionFailure.Value.NOT_ENOUGH_RESOURCES)
	assert_false(result.is_success)
	assert_eq(result.reason, ActionFailure.Value.NOT_ENOUGH_RESOURCES)


## Not in the Dart files: lib/domain/action/action_type.dart has no test of
## its own.
func test_action_type_has_the_values_of_dart_in_its_order() -> void:
	assert_eq(
		DartEnum.names(ActionType.Value),
		PackedStringArray([
			"upgradeBuilding", "unlockBranch", "researchTech", "recruitUnit", "explore",
			"collectTreasure", "fightMonster", "descend", "sendReinforcements",
			"attackTransitionBase", "attackBase", "attackPost", "announceAttack", "spyBase",
			"attackVolcanicKernel", "attackHeldKernel", "garrisonKernel", "chooseEvent",
			"endTurn",
		]),
	)

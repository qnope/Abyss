extends TextsTestCase
## test/presentation/extensions/action_failure_extensions_test.dart.

const Failure := ActionFailure.Value


func test_tells_why_an_action_was_refused() -> void:
	assert_eq(ActionFailureTexts.message(Failure.GAME_OVER), "Partie terminée")
	assert_eq(ActionFailureTexts.message(Failure.MAP_NOT_GENERATED), "Carte non générée")
	TranslationServer.set_locale("en")
	assert_eq(ActionFailureTexts.message(Failure.GAME_OVER), "Game over")


func test_a_failed_result_tells_its_reason() -> void:
	assert_eq(ActionFailureTexts.failure_message(ActionResult.failure(Failure.GAME_OVER)), "Partie terminée")


func test_a_result_without_reason_tells_a_generic_refusal() -> void:
	assert_eq(ActionFailureTexts.failure_message(ActionResult.success()), "Action impossible")
	assert_translated(&"actionFailureUnknown")


func test_every_failure_has_a_message_in_every_language() -> void:
	assert_every_value_translated(Failure, func(failure: int) -> String:
		return TextKeys.of("actionFailure", Failure, failure))

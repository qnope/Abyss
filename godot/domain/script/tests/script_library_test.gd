extends TestCase
## Not in the Dart files: ScriptLibrary gives each built-in strategy and each
## human plan by its name (`strategies_test.dart` and `calibration_test.dart`
## play them), and refuses an unknown one.


func before_each() -> void:
	PlanLibrary.use_reader(ReferenceFiles.text_of)


func test_gives_each_strategy_by_its_name() -> void:
	var names: Array[String] = []
	for name: String in ScriptLibrary.names():
		names.append(ScriptLibrary.by_name(name).name())
	assert_eq(names, ScriptLibrary.names())
	assert_eq(names.slice(0, 7), ["economy", "balanced", "idle", "conquest", "rush", "tutorial", "plan85"])


func test_rush_is_the_conquest_that_does_not_defend() -> void:
	var rush: ConquestStrategy = ScriptLibrary.by_name("rush")
	assert_false(rush.defends)
	var conquest: ConquestStrategy = ScriptLibrary.by_name("conquest")
	assert_true(conquest.defends)


func test_refuses_an_unknown_name() -> void:
	expect_error("Stratégie inconnue : magic (connues : economy, balanced, idle, conquest, rush, tutorial, plan85, plan85-newmap")
	assert_null(ScriptLibrary.by_name("magic"))

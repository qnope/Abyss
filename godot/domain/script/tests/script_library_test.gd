extends TestCase
## Not in the Dart files: ScriptLibrary gives each built-in strategy by its
## name (`strategies_test.dart` plays them), and refuses an unknown one.


func test_gives_each_strategy_by_its_name() -> void:
	var names: Array[String] = []
	for name: String in ScriptLibrary.names():
		names.append(ScriptLibrary.by_name(name).name())
	assert_eq(names, ["economy", "balanced", "idle", "conquest", "rush", "tutorial"] as Array[String])


func test_rush_is_the_conquest_that_does_not_defend() -> void:
	var rush: ConquestStrategy = ScriptLibrary.by_name("rush")
	assert_false(rush.defends)
	var conquest: ConquestStrategy = ScriptLibrary.by_name("conquest")
	assert_true(conquest.defends)


func test_refuses_an_unknown_name() -> void:
	expect_error("Stratégie inconnue : magic (connues : economy, balanced, idle, conquest, rush, tutorial)")
	assert_null(ScriptLibrary.by_name("magic"))

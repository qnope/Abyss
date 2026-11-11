extends TestCase
## test/domain/script/strategies_test.dart: the raid calibration targets of
## step 6, on a few seeds each; the simulator replays them on hundreds
## (tool/simulate/README.md). 'the careful script loses most games', a game
## of 100 turns that takes 9 s here, is the long case `careful-script` of
## tool/replay/.

var _batch := BatchRunner.new(ScriptRunner.new(100))


func before_each() -> void:
	PlanLibrary.use_reader(ReferenceFiles.text_of)


func test_an_all_economy_base_falls_to_the_raids() -> void:
	var report := _batch.run(func(_s: int) -> GameScript: return EconomyStrategy.new(), 3)

	assert_eq(report.defeats(), report.games())
	var earliest: int = report.earliest_defeat()
	assert_true(earliest < 40, str(earliest))


func test_a_base_that_does_nothing_falls_too_only_later() -> void:
	var report := _batch.run(func(_s: int) -> GameScript: return IdleScript.new(), 2)

	assert_eq(report.defeats(), report.games())
	var earliest: int = report.earliest_defeat()
	assert_true(earliest >= 40 and earliest <= 50, str(earliest))


func test_a_balanced_base_holds_at_least_50_turns_twice_the_all_economy_one() -> void:
	var report := _batch.run(func(_s: int) -> GameScript: return BalancedStrategy.new(), 3)

	var earliest: int = report.earliest_defeat() if report.earliest_defeat() != null else 100
	assert_true(earliest >= 50, str(earliest))
	assert_true(report.average_raids_repelled() > 10, str(report.average_raids_repelled()))


func test_rushing_the_volcano_without_defending_loses_the_base() -> void:
	var report := _batch.run(func(_s: int) -> GameScript: return ScriptLibrary.by_name("rush"), 2)

	assert_eq(report.defeats(), report.games())
	assert_eq(report.victories(), 0)


func test_the_library_knows_every_built_in_strategy_by_name() -> void:
	for name: String in ScriptLibrary.names():
		assert_eq(ScriptLibrary.by_name(name).name(), name)
	expect_error("Stratégie inconnue : nope")
	assert_null(ScriptLibrary.by_name("nope"))

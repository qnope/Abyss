class_name ScriptCases
extends RefCounted
## Whole scripted games too long for the unit tests: the three games of
## test/domain/script/calibration_test.dart, 'the careful script loses most
## games' of strategies_test.dart and script_runner_performance_test.dart.

## Ten times what the conquest of the performance case takes here (12 s),
## as the Dart file's budget is ten times its own measure: it absorbs a
## slow runner and the games played beside it, and still catches the
## simulation getting several times slower.
const PERFORMANCE_BUDGET_MS := 120000


## The human plan `plan85` wins in normal with seed 2, falls before turn 70
## with seed 1, and with seed 4 wins in easy and falls in normal.
static func calibration() -> PackedStringArray:
	PlanLibrary.use_reader(ReferenceFiles.text_of)
	var checks := CaseChecks.new()
	var win := _plan85(Difficulty.Value.NORMAL, 2)
	checks.expect(win.is_victory(), "seed 2 in normal: %s, not a victory" % _end_of(win))
	var fall := _plan85(Difficulty.Value.NORMAL, 1)
	checks.expect(fall.is_defeat() and fall.turns_played < 70, "seed 1 in normal: %s, not a defeat before 70" % _end_of(fall))
	var easy := _plan85(Difficulty.Value.EASY, 4)
	checks.expect(easy.is_victory(), "seed 4 in easy: %s, not a victory" % _end_of(easy))
	var normal := _plan85(Difficulty.Value.NORMAL, 4)
	checks.expect(normal.is_defeat(), "seed 4 in normal: %s, not a defeat" % _end_of(normal))
	return checks.failures


## The careful script wins about 1 game in 6 in normal; seed 2 is a loss.
static func careful_script() -> PackedStringArray:
	var checks := CaseChecks.new()
	var run := ScriptRunner.new(100).run(ConquestStrategy.new(), 2)
	checks.expect(not run.is_victory(), "seed 2: a victory")
	return checks.failures


## A scripted conquest of 100 turns stays within the time budget.
static func performance() -> PackedStringArray:
	var checks := CaseChecks.new()
	var start := Time.get_ticks_msec()
	var report := ScriptRunner.new(100).run(ScriptLibrary.by_name("conquest"), 1)
	var elapsed := Time.get_ticks_msec() - start
	# The bot may win before turn 100, but a short game would not measure
	# the simulation.
	checks.expect(report.turns_played >= 80, "the game ended on turn %d" % report.turns_played)
	checks.expect(elapsed < PERFORMANCE_BUDGET_MS, "the game took %d ms" % elapsed)
	return checks.failures


static func _plan85(difficulty: Difficulty.Value, seed_: int) -> ScriptRunReport:
	return ScriptRunner.new(120, difficulty).run(ScriptLibrary.by_name("plan85"), seed_)


static func _end_of(run: ScriptRunReport) -> String:
	return "%s on turn %d" % [DartEnum.name_of(GameStatus.Value, run.status), run.turns_played]

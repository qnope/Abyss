extends TestCase
## test/domain/script/calibration_test.dart: the calibration targets of the
## difficulties, measured on the human plan `plan85` (a win, played again
## with other dice and a careful defence) and the careful script (see the
## Dart file): in normal, seed 2 is one of the plan's wins and seed 1 falls
## the earliest of the first 80; seed 4 wins in easy and falls in normal.


func before_each() -> void:
	PlanLibrary.use_reader(ReferenceFiles.text_of)


func test_the_human_plan_still_wins_some_games() -> void:
	assert_true(_run(Difficulty.Value.NORMAL, 2).is_victory())


func test_the_human_plan_can_also_fall_to_the_raids() -> void:
	var run := _run(Difficulty.Value.NORMAL, 1)

	assert_true(run.is_defeat())
	assert_true(run.turns_played < 70, str(run.turns_played))


func test_the_same_plan_and_dice_win_in_easy_and_fall_in_normal() -> void:
	assert_true(_run(Difficulty.Value.EASY, 4).is_victory())
	assert_true(_run(Difficulty.Value.NORMAL, 4).is_defeat())


func test_every_nearby_plan_is_a_strategy_of_its_own() -> void:
	for name: String in [
		"plan85-newmap", "plan85-nodefence", "plan85-army120", "plan85-army90", "plan85-late", "plan85-slow",
	]:
		assert_eq(ScriptLibrary.by_name(name).name(), name)


static func _run(difficulty: Difficulty.Value, seed_: int) -> ScriptRunReport:
	return ScriptRunner.new(120, difficulty).run(ScriptLibrary.by_name("plan85"), seed_)

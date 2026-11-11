extends TestCase
## test/domain/script/calibration_test.dart: the calibration targets of the
## difficulties, measured on the human plan `plan85` (a win, played again
## with other dice and a careful defence) and the careful script (see the
## Dart file): in normal, seed 2 is one of the plan's wins and seed 1 falls
## the earliest of the first 80; seed 4 wins in easy and falls in normal.
## Those three games of up to 120 turns take 15 s here: they are the long
## case `calibration` of tool/replay/ (ScriptCases).


func before_each() -> void:
	PlanLibrary.use_reader(ReferenceFiles.text_of)


func test_every_nearby_plan_is_a_strategy_of_its_own() -> void:
	for name: String in [
		"plan85-newmap", "plan85-nodefence", "plan85-army120", "plan85-army90", "plan85-late", "plan85-slow",
	]:
		assert_eq(ScriptLibrary.by_name(name).name(), name)


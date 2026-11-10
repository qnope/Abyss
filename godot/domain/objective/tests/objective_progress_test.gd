extends TestCase
## Not in the Dart tests: lib/domain/objective/objective_progress.dart and
## goals/all_of_goal.dart, which the Dart tests only read through the
## objectives of the catalog.


func test_the_steps_are_capped_between_zero_and_the_target() -> void:
	assert_eq(str(ObjectiveProgress.new(5, 3)), "3/3")
	assert_eq(str(ObjectiveProgress.new(-2, 3)), "0/3")
	assert_false(ObjectiveProgress.new(2, 3).is_done())
	assert_true(ObjectiveProgress.new(3, 3).is_done())


func test_a_flag_is_one_step_done_when_met() -> void:
	assert_eq(str(ObjectiveProgress.flag(true)), "1/1")
	assert_eq(str(ObjectiveProgress.flag(false)), "0/1")


func test_two_progresses_add_up_capped_again() -> void:
	var sum := ObjectiveProgress.new(2, 3).plus(ObjectiveProgress.new(1, 1))
	assert_eq([sum.current, sum.target], [3, 4])


func test_all_of_nothing_logs_an_error_where_dart_throws() -> void:
	var game := ObjectiveSamples.objective_game()
	expect_error("no goal")
	var progress := AllOfGoal.new([]).progress_of(game, game.human_player())
	assert_eq(str(progress), "0/0")

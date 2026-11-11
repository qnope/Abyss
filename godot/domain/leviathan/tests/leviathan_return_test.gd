extends TestCase
## Not in the Dart tests, which read a LeviathanReturn through the capture
## of a Faille and the ends of turn (test/domain/leviathan/
## leviathan_schedule_test.dart, _once_, _postponed_, ported beside this
## file): the bookkeeping itself, as lib/domain/leviathan/
## leviathan_return.dart answers.


func test_a_new_one_can_still_be_scheduled() -> void:
	var state := LeviathanReturn.new()
	assert_eq(LeviathanReturn.DELAY, 3)
	assert_true(state.is_available())
	assert_false(state.is_scheduled())
	assert_false(state.over)
	assert_null(state.due_turn())
	assert_eq([state.post_name, state.level, state.at], [null, null, null])
	assert_eq([state.strike_turn, state.ready_turn], [null, null])


func test_takes_its_fields_in_the_dart_order() -> void:
	var at := GridPosition.new(1, 2)
	var state := LeviathanReturn.new("Faille", 1, at, 12, true, 10)
	assert_eq([state.post_name, state.level, state.at], ["Faille", 1, at])
	assert_eq([state.strike_turn, state.over, state.ready_turn], [12, true, 10])


func test_a_faille_taken_schedules_the_strike_three_turns_later() -> void:
	var state := LeviathanReturn.new()
	var at := GridPosition.new(1, 1)
	state.schedule("Faille", 1, at, 9)
	assert_true(state.is_scheduled())
	assert_false(state.is_available())
	assert_eq(state.strike_turn, 12)
	assert_eq([state.post_name, state.level, state.at], ["Faille", 1, at])


func test_the_strike_waits_for_the_module_to_work() -> void:
	var state := LeviathanReturn.new()
	state.schedule("Faille", 1, GridPosition.new(1, 1), 9)
	assert_null(state.due_turn())
	state.mark_ready(9)
	assert_eq(state.due_turn(), 12)


func test_a_module_that_works_late_postpones_the_strike() -> void:
	var state := LeviathanReturn.new()
	state.schedule("Faille", 1, GridPosition.new(1, 1), 9)
	state.mark_ready(15)
	assert_eq(state.due_turn(), 18)


func test_only_the_first_turn_the_module_works_counts() -> void:
	var state := LeviathanReturn.new()
	state.mark_ready(4)
	state.mark_ready(8)
	assert_eq(state.ready_turn, 4)
	assert_null(state.due_turn())


func test_once_ended_it_is_neither_scheduled_nor_available() -> void:
	var state := LeviathanReturn.new()
	state.schedule("Faille", 1, GridPosition.new(1, 1), 9)
	state.end()
	assert_true(state.over)
	assert_false(state.is_scheduled())
	assert_false(state.is_available())

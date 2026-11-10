extends TestCase
## test/domain/action/descend_action_history_test.dart: the entry a descent
## keeps. The `subtitle` of an entry, always null, is not ported.

const SCOUT := UnitType.Value.SCOUT


func _entry(game: Game, scouts: int, result: ActionResult = null, turn := 1) -> HistoryEntry:
	var action := DescendAction.new(5, 5, 1, {SCOUT: scouts})
	var outcome := result if result != null else action.execute(game, game.human_player())
	return action.make_history_entry(game, game.human_player(), outcome, turn)


func test_descend_action_make_history_entry_returns_descent_entry_on_successful_execute() -> void:
	var descent: DescentEntry = _entry(MoveSamples.descend_game(), 4, null, 3)
	assert_eq([descent.turn, descent.category], [3, HistoryEntryCategory.Value.DESCENT])
	assert_eq([descent.target_level, descent.unit_count], [2, 4])


func test_descend_action_make_history_entry_returns_null_on_failure_result() -> void:
	var fail_result := ActionResult.failure(ActionFailure.Value.NOT_ENOUGH_UNITS)
	assert_null(_entry(MoveSamples.descend_game(), 1, fail_result))


func test_descend_action_make_history_entry_returns_null_when_result_is_not_descend_result() -> void:
	assert_null(_entry(MoveSamples.descend_game(), 1, ActionResult.success()))


func test_descend_action_make_history_entry_unit_count_sums_all_unit_types_sent() -> void:
	var descent: DescentEntry = _entry(MoveSamples.descend_game("test", 1, 20), 5, null, 7)
	assert_eq(descent.unit_count, 5)

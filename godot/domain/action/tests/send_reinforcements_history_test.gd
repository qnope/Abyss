extends TestCase
## test/domain/action/send_reinforcements_history_test.dart: the entry
## reinforcements keep. The `subtitle` of an entry, always null, is not
## ported.


func _action() -> SendReinforcementsAction:
	return SendReinforcementsAction.new(2, 2, 1, {UnitType.Value.SCOUT: 3})


func test_send_reinforcements_action_make_history_entry_returns_reinforcement_entry_on_success() -> void:
	var game := MoveSamples.reinforcement_game()
	var action := _action()
	var result := action.execute(game, game.human_player())
	var reinf: ReinforcementEntry = action.make_history_entry(game, game.human_player(), result, 5)
	assert_eq([reinf.turn, reinf.category], [5, HistoryEntryCategory.Value.REINFORCEMENT])
	assert_eq([reinf.target_level, reinf.unit_count], [2, 3])


func test_send_reinforcements_action_make_history_entry_returns_null_on_failure() -> void:
	var game := MoveSamples.reinforcement_game(0)
	var action := _action()
	var result := action.execute(game, game.human_player())
	assert_false(result.is_success)
	assert_null(action.make_history_entry(game, game.human_player(), result, 1))


func test_send_reinforcements_action_make_history_entry_returns_null_when_result_is_generic_failure() -> void:
	var game := MoveSamples.reinforcement_game()
	var fail_result := ActionResult.failure(ActionFailure.Value.NOT_ENOUGH_UNITS)
	assert_null(_action().make_history_entry(game, game.human_player(), fail_result, 1))


## Not in the Dart file: a success never executed keeps no entry.
func test_a_success_never_executed_keeps_no_entry() -> void:
	var game := MoveSamples.reinforcement_game()
	assert_null(_action().make_history_entry(game, game.human_player(), ActionResult.success(), 1))

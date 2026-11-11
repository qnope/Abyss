extends UiTestCase
## The queue of pages shown once a turn has ended
## (test/presentation/screens/game/game_screen_turn_flow_test.dart): one page
## after the other, each opened when the one before it is closed, ending with
## the defeat or the end of the queue.

var _told: Array[String] = []
var _game: Game
var _result := TurnResult.new([], 1, 2, false)
## The outcome under test: whoever runs one keeps it, as the flow does.
var _outcome: TurnOutcome


func before_each() -> void:
	_game = GameSamples.game([GameSamples.player("Nemo")])


func _run(steps: Array[Callable]) -> void:
	_outcome = TurnOutcome.new(_game, _result, modals(), steps)
	_outcome.finished.connect(_told.append.bind("finished"))
	_outcome.defeated.connect(_told.append.bind("defeated"))
	_outcome.run()


func test_the_default_queue_is_the_summary_of_the_turn() -> void:
	_run(TurnOutcome.default_steps())
	var summary := current_modal() as TurnSummary
	assert_not_null(summary)
	assert_eq(summary.result, _result)
	assert_eq(_told, [] as Array[String], "not over before the page is closed")
	press("OK")
	assert_eq(_told, ["finished"] as Array[String])
	assert_null(current_modal())


func test_each_page_opens_when_the_one_before_it_is_closed() -> void:
	var first := ModalPanel.new()
	var second := ModalPanel.new()
	var steps: Array[Callable] = [
		func(_g: Game, _r: TurnResult) -> ModalPanel: return first,
		func(_g: Game, _r: TurnResult) -> ModalPanel: return second,
	]
	_run(steps)
	assert_eq(current_modal(), first)
	assert_eq(modals().depth(), 1)
	first.close()
	assert_eq(current_modal(), second)
	assert_eq(_told, [] as Array[String])
	second.close()
	assert_eq(_told, ["finished"] as Array[String])


func test_a_step_with_nothing_to_show_is_skipped() -> void:
	var page := ModalPanel.new()
	var steps: Array[Callable] = [
		func(_g: Game, _r: TurnResult) -> ModalPanel: return null,
		func(_g: Game, _r: TurnResult) -> ModalPanel: return page,
		func(_g: Game, _r: TurnResult) -> ModalPanel: return null,
	]
	_run(steps)
	assert_eq(current_modal(), page)
	page.close()
	assert_eq(_told, ["finished"] as Array[String])


func test_a_queue_with_no_page_ends_at_once() -> void:
	_run([] as Array[Callable])
	assert_eq(_told, ["finished"] as Array[String])
	assert_eq(modals().depth(), 0)


func test_a_lost_game_ends_with_the_defeat_after_the_last_page() -> void:
	_game.status = GameStatus.Value.DEFEAT
	var page := ModalPanel.new()
	var steps: Array[Callable] = [func(_g: Game, _r: TurnResult) -> ModalPanel: return page]
	_run(steps)
	assert_eq(_told, [] as Array[String])
	page.close("anything")
	assert_eq(_told, ["defeated"] as Array[String])


func test_a_step_sees_the_game_and_the_result() -> void:
	var seen: Array[Variant] = []
	var steps: Array[Callable] = [func(game: Game, result: TurnResult) -> ModalPanel:
		seen.append_array([game, result])
		return null]
	_run(steps)
	assert_eq(seen, [_game, _result] as Array[Variant])

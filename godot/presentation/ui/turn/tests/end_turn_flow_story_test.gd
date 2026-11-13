extends UiTestCase
## The story of a turn told between the turn and its summary
## (lib/presentation/screens/game/game_screen_end_turn.dart: `TurnObserver`).

var _game: Game
var _flow: EndTurnFlow
var _log: Array[String] = []
var _then := Callable()


func before_each() -> void:
	_game = GameFactory.new_single_player("Nemo", 1)
	_flow = EndTurnFlow.new(GameActions.new(_game), modals())


## An observer that tells the turn: it notes when it is asked and when it tells,
## and keeps the "next" to call by hand.
func _observer() -> Callable:
	return func() -> Callable:
		_log.append("asked at turn %d" % _game.turn)
		return func(result: TurnResult, then: Callable) -> void:
			_log.append("told turn %d" % result.previous_turn)
			_then = then


func _end_turn() -> void:
	_flow.request()
	press("Confirmer")


func test_the_observer_is_asked_before_the_turn_ends_and_tells_it_after() -> void:
	_flow.observe = _observer()
	_end_turn()
	assert_eq(_log, ["asked at turn 1", "told turn 1"] as Array[String])
	assert_eq(_game.turn, 2)


func test_the_summary_waits_for_the_story_and_opens_once_it_is_told() -> void:
	_flow.observe = _observer()
	_end_turn()
	assert_null(current_modal(), "the story is being told")
	assert_null(_flow.outcome)
	assert_true(_flow.is_telling())
	_then.call()
	assert_false(_flow.is_telling())
	assert_true(current_modal() is TurnSummary)


func test_a_story_that_ends_twice_opens_the_summary_once() -> void:
	_flow.observe = _observer()
	_end_turn()
	_then.call()
	var summary := current_modal()
	_then.call()
	assert_eq(current_modal(), summary)
	assert_eq(modals().depth(), 1)


func test_no_second_turn_is_asked_while_the_story_is_told() -> void:
	_flow.observe = _observer()
	_end_turn()
	_flow.request()
	assert_null(current_modal())
	_then.call()
	press("OK")
	_flow.request()
	assert_true(current_modal() is TurnConfirmation, "the next turn can be asked again")


func test_a_story_with_nothing_to_tell_opens_the_summary_at_once() -> void:
	_flow.observe = func() -> Callable: return Callable()
	_end_turn()
	assert_true(current_modal() is TurnSummary)


func test_without_an_observer_the_turn_goes_as_before() -> void:
	_end_turn()
	assert_true(current_modal() is TurnSummary)

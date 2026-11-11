extends UiTestCase
## Where the events meet the turn: the lines of the summary
## (event_turn_section_test.dart), the warning of the question
## (game_screen_event_test.dart) and the card in the queue of pages
## (showTurnOutcome).

const Type := RandomEventType.Value

var _game: Game
var _answers: Array = []


func before_each() -> void:
	_answers = []
	_game = Game.single_player(Player.new("Nemo", "p1"))
	_game.turn = 3


func _result() -> TurnResult:
	return TurnResult.new([], 2, 3, false)


func _summary_texts(result: TurnResult) -> PackedStringArray:
	return texts(mount(TurnSummary.new(result)))


func test_the_summary_tells_nothing_of_a_turn_without_event() -> void:
	assert_false(EventTurnSection.has_content(_result()))
	assert_true(EventTurnSection.of(_result()).is_empty())


func test_the_summary_tells_the_event_drawn() -> void:
	var result := _result()
	result.event = Type.CARAVAN
	var lines := EventTurnSection.of(result)
	assert_eq(lines.size(), 2, "a divider and a line")
	for line in lines:
		line.free()
	assert_has(_summary_texts(result), "Événement : Caravane de tortues")


func test_the_summary_tells_the_event_settled_by_default() -> void:
	var result := _result()
	result.defaulted_event = Type.SURVIVORS
	assert_has(_summary_texts(result), "Survivants : option prudente appliquée")


func test_the_summary_tells_how_the_predators_ended() -> void:
	var won := _result()
	won.predators = RaidReport.new(3, true, EventSamples.predator_test_wave(), HistorySamples.fight(true),
		0, {}, {}, {}, {}, {}, {}, true)
	assert_has(_summary_texts(won), "Banc de prédateurs repoussé")
	var lost := _result()
	lost.predators = RaidReport.new(3, false, EventSamples.predator_test_wave(), HistorySamples.fight(false),
		0, {}, {}, {}, {}, {}, {}, true)
	assert_has(_summary_texts(lost), "Le banc de prédateurs a pillé la base")


func test_the_summary_tells_the_lines_in_the_order_of_the_turn() -> void:
	var result := _result()
	result.defaulted_event = Type.STORM
	result.event = Type.WRECK
	var shown := _summary_texts(result)
	var first := shown.find("Tempête : option prudente appliquée")
	assert_true(first >= 0 and first < shown.find("Événement : Épave"), "the event settled, then the one drawn")


func test_the_question_warns_of_the_event_still_waiting() -> void:
	var human := _game.human_player()
	assert_true(TurnWarnings.of(_game, human).is_empty())
	human.event_state.set_pending(Type.SURVIVORS, 3)
	var warnings := TurnWarnings.of(_game, human)
	assert_eq(warnings.size(), 1)
	var dialog := TurnConfirmation.new(TurnForecast.of(_game), warnings)
	mount(dialog)
	assert_has(texts(dialog), "Survivants : sans choix, l'option prudente s'appliquera")
	use_language("en")
	assert_has(texts(dialog), "Survivors: without a choice, the prudent option will apply")


func test_the_queue_shows_the_card_of_the_event_drawn_after_the_summary() -> void:
	_game.human_player().event_state.set_pending(Type.SURVIVORS, 3)
	_game.human_player().event_state.survivors = 4
	var result := _result()
	result.event = Type.SURVIVORS
	var outcome := TurnOutcome.new(_game, result, modals(), TurnOutcome.default_steps(GameActions.new(_game)))
	outcome.finished.connect(func() -> void: _answers.append("finished"))
	outcome.run()
	assert_true(current_modal() is TurnSummary)
	press("OK")
	var card := current_modal() as EventCard
	assert_not_null(card)
	assert_eq(_answers, [] as Array, "not over before the card is closed")
	press("Plus tard")
	assert_eq(_answers, ["finished"])
	assert_true(_game.human_player().event_state.has_pending(), "later leaves it pending")


func test_the_queue_has_no_card_when_the_turn_drew_nothing() -> void:
	var step := EventStep.of(GameActions.new(_game))
	assert_null(step.call(_game, _result()))


func test_the_queue_has_no_card_for_a_game_the_turn_lost() -> void:
	var result := _result()
	result.event = Type.STORM
	_game.status = GameStatus.Value.DEFEAT
	assert_null(EventStep.page(GameActions.new(_game), _game, result))
	_game.status = GameStatus.Value.PLAYING
	var card := EventStep.page(GameActions.new(_game), _game, result)
	assert_true(card is EventCard)
	card.free()

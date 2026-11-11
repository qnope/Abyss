extends UiTestCase
## The "next turn" from the press to the next playable state
## (test/presentation/screens/game/game_screen_end_turn_test.dart,
## game_screen_defeat_test.dart): the question, the turn, the summary, then
## the game goes on or is lost.

const Type := BuildingType.Value

var _game: Game
var _actions: GameActions
var _flow: EndTurnFlow
var _told: Array[String] = []
var _acted: Array = []
var _summary_open: Array[bool] = []
var _results: Array[TurnResult] = []


func before_each() -> void:
	_game = GameFactory.new_single_player("Nemo", 1)
	for type: BuildingType.Value in [Type.HEADQUARTERS, Type.ALGAE_FARM, Type.CORAL_MINE, Type.SOLAR_PANEL]:
		_game.human_player().buildings[type].level = 2
	_start()


func _on_turn_ended(_result: TurnResult) -> void:
	_summary_open.append(current_modal() is TurnSummary)


func _start() -> void:
	_actions = GameActions.new(_game)
	_actions.acted.connect(_acted.append)
	_flow = EndTurnFlow.new(_actions, modals())
	_flow.turn_ended.connect(_results.append)
	_flow.turn_ended.connect(_on_turn_ended)
	_flow.finished.connect(_told.append.bind("finished"))
	_flow.defeated.connect(_told.append.bind("defeated"))


## A raid due this turn on a base that lost two in a row: the third ends the game.
func _last_chance() -> void:
	_game.turn = 12
	_game.human_player().raid_state.lost_in_a_row = 2
	_game.human_player().raid_state.announce(MonsterLair.new(MonsterDifficulty.Value.EASY, 5), 12)
	_start()


func test_asks_first_and_changes_nothing_until_confirmed() -> void:
	_flow.request()
	assert_true(current_modal() is TurnConfirmation)
	assert_eq(_game.turn, 1)
	assert_eq(_acted.size(), 0)


func test_cancelling_leaves_the_turn_where_it_is() -> void:
	_flow.request()
	press("Annuler")
	assert_eq(_game.turn, 1)
	assert_eq(_acted.size(), 0)
	assert_null(current_modal())
	assert_eq(_told, [] as Array[String])
	assert_eq(_game.human_player().history_entries.size(), 0)


func test_dismissing_the_question_leaves_the_turn_where_it_is() -> void:
	_flow.request()
	modals().close_top()
	assert_eq(_game.turn, 1)
	assert_eq(_acted.size(), 0)


func test_confirming_ends_the_turn_and_tells_it_changed_once() -> void:
	var before := _game.human_player().resources[ResourceType.Value.ALGAE].amount
	_flow.request()
	press("Confirmer")
	assert_eq(_game.turn, 2)
	assert_eq(_acted.size(), 1)
	assert_eq(_results.size(), 1)
	assert_eq(_results[0].previous_turn, 1)
	assert_eq(_results[0].new_turn, 2)
	assert_true(_game.human_player().resources[ResourceType.Value.ALGAE].amount > before)
	assert_true(_game.human_player().history_entries[0] is TurnEndEntry)


func test_the_summary_follows_the_turn_with_what_the_domain_reports() -> void:
	_flow.request()
	press("Confirmer")
	var summary := current_modal() as TurnSummary
	assert_not_null(summary)
	assert_eq(summary.result, _results[0])
	assert_eq(summary.title(), "Tour 1 → Tour 2")
	assert_false(_results[0].changes.is_empty())
	var human := _game.human_player()
	for change in _results[0].changes:
		assert_not_null(find_text(ResourceTexts.display_name(change.type)), "a line per resource")
		assert_true(human.resources[change.type].amount >= change.after_amount, "what the turn made is in the stock")
		assert_eq(change.after_amount, mini(change.before_amount + change.produced - change.consumed, human.resources[change.type].max_storage))
		assert_not_null(find_text("+%d" % change.produced if change.consumed == 0 else "+%d/-%d" % [change.produced, change.consumed]))
	assert_eq(_told, [] as Array[String], "the game goes on once the summary is closed")


func test_the_game_goes_on_once_the_summary_is_closed() -> void:
	_flow.request()
	press("Confirmer")
	press("OK")
	assert_eq(_told, ["finished"] as Array[String])
	assert_null(current_modal())
	assert_eq(_game.status, GameStatus.Value.PLAYING)


func test_the_turn_ended_is_told_before_the_first_page_opens() -> void:
	_flow.request()
	press("Confirmer")
	assert_eq(_summary_open, [false] as Array[bool])
	assert_true(current_modal() is TurnSummary)


func test_a_raid_that_can_end_the_game_does_not_stop_the_question() -> void:
	_last_chance()
	_flow.request()
	assert_true(current_modal() is TurnConfirmation)
	press("Confirmer")
	assert_eq(_game.status, GameStatus.Value.DEFEAT)


func test_a_lost_game_is_told_once_the_raid_report_is_closed() -> void:
	_last_chance()
	_flow.request()
	press("Confirmer")
	assert_eq(_told, [] as Array[String])
	press("OK")
	assert_true(current_modal() is RaidReportPage, "the raid that lost the game is told first")
	assert_eq(_told, [] as Array[String])
	press("Retour à la base")
	assert_eq(_told, ["defeated"] as Array[String])


func test_ten_turns_in_a_row_each_ask_each_summary() -> void:
	for turn in range(1, 11):
		_flow.request()
		press("Confirmer")
		assert_eq((current_modal() as TurnSummary).title(), "Tour %d → Tour %d" % [turn, turn + 1])
		press("OK")
		# An event drawn this turn has its card after the summary: put off.
		if current_modal() is EventCard:
			current_modal().close()
	assert_eq(_game.turn, 11)
	assert_eq(_results.size(), 10)
	assert_eq(_told.size(), 10)

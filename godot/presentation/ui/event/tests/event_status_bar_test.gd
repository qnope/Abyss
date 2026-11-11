extends UiTestCase
## test/presentation/widgets/event/event_status_bar_test.dart and the banner
## of game_screen_event_test.dart: the strip of the events, its countdowns
## and the touch that reopens the pending card.

const Type := RandomEventType.Value

var _game: Game
var _actions: GameActions


## The bar of a game at turn 10 whose player's events are [param state].
func _bar(state: EventState) -> EventStatusBar:
	var player := Player.new("Nemo", "p1")
	player.event_state = state
	_game = Game.single_player(player)
	_game.turn = 10
	_actions = GameActions.new(_game)
	return mount(EventStatusBar.new(_actions, modals())) as EventStatusBar


func _pending(type: Type, survivors: Variant = 4) -> EventState:
	var state := EventState.new()
	state.set_pending(type, 10)
	state.survivors = survivors
	return state


func test_is_hidden_when_nothing_happens() -> void:
	var bar := _bar(EventState.new())
	assert_false(bar.visible)
	assert_true(texts(bar).is_empty())


func test_a_pending_choice_is_told_and_reopens_the_card_when_touched() -> void:
	var bar := _bar(_pending(Type.SURVIVORS))
	assert_true(bar.visible)
	assert_not_null(find_text("Événement : Survivants — choisir", bar))
	assert_false(bar.effect_line.visible)
	assert_false(bar.wreck_line.visible)
	press(bar.tap_button)
	var card := current_modal() as EventCard
	assert_not_null(card)
	assert_eq(card.data.type, Type.SURVIVORS)


func test_touching_it_without_a_pending_event_opens_nothing() -> void:
	var bar := _bar(EventState.new())
	bar.tap_button.pressed.emit()
	assert_null(current_modal())


func test_counts_down_a_warm_current() -> void:
	var state := EventState.new()
	state.activate(Type.WARM_CURRENT, 11)
	var bar := _bar(state)
	assert_not_null(find_text("Courant chaud : encore 2 tours", bar))
	assert_false(bar.pending_line.visible)


func test_tells_a_heated_cold_current_apart() -> void:
	var state := EventState.new()
	state.activate(Type.COLD_CURRENT, 12)
	state.heating = true
	assert_not_null(find_text("Courant froid (serres chauffées) : encore 3 tours", _bar(state)))


func test_counts_down_a_storm_on_its_last_turn() -> void:
	var state := EventState.new()
	state.activate(Type.STORM, 10)
	assert_not_null(find_text("Tempête : encore 1 tour", _bar(state)))


func test_forgets_an_effect_that_is_over() -> void:
	var state := EventState.new()
	state.activate(Type.STORM, 9)
	assert_false(_bar(state).visible)


func test_counts_down_the_wreck_left_on_the_map() -> void:
	var state := EventState.new()
	state.wreck_position = GridPosition.new(1, 1)
	state.wreck_until_turn = 13
	var bar := _bar(state)
	assert_not_null(find_text("Épave : encore 4 tours", bar))
	assert_true(bar.wreck_line.visible)


func test_shows_every_line_at_once() -> void:
	var state := _pending(Type.CARAVAN, null)
	state.activate(Type.WARM_CURRENT, 11)
	state.wreck_position = GridPosition.new(1, 1)
	state.wreck_until_turn = 13
	var bar := _bar(state)
	assert_eq(texts(bar).size(), 3)


func test_is_read_again_from_the_game_on_refresh() -> void:
	var bar := _bar(_pending(Type.SURVIVORS))
	_game.human_player().event_state.clear_pending()
	assert_true(bar.visible)
	bar.refresh()
	assert_false(bar.visible)
	_game.human_player().event_state.set_pending(Type.CARAVAN, 10)
	bar.refresh()
	assert_not_null(find_text("Événement : Caravane de tortues — choisir", bar))


func test_choosing_from_the_card_clears_the_bar_once_refreshed() -> void:
	var bar := _bar(_pending(Type.SURVIVORS))
	press(bar.tap_button)
	press("Refuser")
	assert_null(current_modal())
	assert_false(_game.human_player().event_state.has_pending())
	bar.refresh()
	assert_false(bar.visible)


func test_follows_the_language_in_every_part() -> void:
	var state := _pending(Type.SURVIVORS)
	state.activate(Type.STORM, 11)
	var bar := _bar(state)
	use_language("en")
	assert_not_null(find_text("Event: Survivors — choose", bar))
	assert_not_null(find_text("Storm: 2 turns left", bar))
	use_language("es")
	assert_no_raw_keys(bar)

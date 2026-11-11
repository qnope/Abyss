extends TipCase
## test/presentation/widgets/tip/tip_presenter_test.dart: the tips waiting are
## stacked in one dialog, saved as seen, and not shown twice.

var _folder: TempFolder
var _session: GameSession


func before_each() -> void:
	super()
	_folder = TempFolder.new()
	add_cleanup(_folder.remove)
	_session = GameSession.new(game, GameRepository.new(_folder.path.path_join("saves")))


func _presenter() -> TipPresenter:
	return TipPresenter.new(_session.actions)


func _ids(stack: TipStack) -> Array:
	var ids: Array = []
	for each in stack.tips:
		ids.append(each.id)
	return ids


func _seen_in_the_save() -> ObjectiveState:
	return _session.repository.load_all().games[0].human_player().saved_objective_state


func test_nothing_is_shown_while_no_tip_waits() -> void:
	assert_null(_presenter().next_stack())


func test_stacks_every_tip_waiting_in_catalog_order() -> void:
	lay_noise_and_storm()
	var stack := _presenter().next_stack()
	assert_eq(_ids(stack), [Id.NOISE_GAUGE, Id.EVENTS, TipCatalog.by_id(EventTips.id_of(RandomEventType.Value.STORM)).id])
	stack.free()


func test_marks_them_seen_and_saves_before_showing() -> void:
	lay_noise_and_storm()
	_presenter().next_stack().free()
	assert_true(state().has_seen(Id.NOISE_GAUGE))
	assert_true(_seen_in_the_save().has_seen(Id.NOISE_GAUGE), "reloading the save keeps them seen")
	assert_true(_seen_in_the_save().has_seen(Id.EVENTS))


func test_shows_a_tip_once() -> void:
	lay_noise_and_storm()
	_presenter().next_stack().free()
	assert_null(_presenter().next_stack())


func test_shows_nothing_when_the_tips_are_off() -> void:
	lay_noise_and_storm()
	state().tips_enabled = false
	assert_null(_presenter().next_stack())


func test_shows_nothing_once_the_game_is_over_but_plays_on_in_free_play() -> void:
	lay_noise_and_storm()
	for over: GameStatus.Value in [GameStatus.Value.VICTORY, GameStatus.Value.DEFEAT]:
		game.status = over
		assert_null(_presenter().next_stack())
	game.status = GameStatus.Value.FREE_PLAY
	var stack := _presenter().next_stack()
	assert_not_null(stack)
	stack.free()


func test_the_turn_flow_ends_with_the_tips() -> void:
	lay_noise_and_storm()
	var step: Callable = TurnOutcome.default_steps(_session.actions).back()
	var turn := TurnResult.new([], 2, 3, false)
	var page: ModalPanel = step.call(game, turn)
	assert_true(page is TipStack)
	page.free()
	assert_null(step.call(game, turn))

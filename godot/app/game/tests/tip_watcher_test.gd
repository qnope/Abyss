extends UiTestCase
## The tips that follow a player's action: opened when the screen is free,
## held back under a modal, and once only.

var _folder: TempFolder
var _session: GameSession
var _watcher: TipWatcher
var _game: Game
var _second: TipWatcher


func before_each() -> void:
	_folder = TempFolder.new()
	add_cleanup(_folder.remove)
	_game = ObjectiveSamples.objective_game()
	_game.human_player().saved_objective_state = ObjectiveState.new([], false, true)
	_session = GameSession.new(_game, GameRepository.new(_folder.path.path_join("saves")))
	_watcher = TipWatcher.new(_session, modals())
	add_cleanup(_watcher.close)
	_game.human_player().raid_state.add_noise(DartMath.trunc_div(NoiseRules.THRESHOLD, 4))


func test_opens_the_tips_waiting_when_the_screen_is_free() -> void:
	_watcher._show()
	assert_true(current_modal() is TipStack)
	assert_true(_game.human_player().saved_objective_state.has_seen(TipId.Value.NOISE_GAUGE))


func test_waits_while_a_modal_covers_the_screen() -> void:
	var cover := AbyssDialog.new("Rapport")
	modals().open(cover)
	_watcher._show()
	assert_eq(current_modal(), cover)
	assert_false(_game.human_player().saved_objective_state.has_seen(TipId.Value.NOISE_GAUGE))
	cover.close()
	_watcher._show()
	assert_true(current_modal() is TipStack)


func test_waits_while_the_screen_is_busy_with_a_story() -> void:
	var busy := [true]
	_second = TipWatcher.new(_session, modals(), func() -> bool: return busy[0])
	add_cleanup(_second.close)
	_second._show()
	assert_null(current_modal())
	busy[0] = false
	_second._show()
	assert_true(current_modal() is TipStack)


func test_opens_nothing_once_they_are_seen() -> void:
	_watcher._show()
	current_modal().close()
	_watcher._show()
	assert_null(current_modal())

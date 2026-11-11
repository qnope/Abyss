extends TestCase
## Every change the player makes to the game goes through GameActions,
## which tells `acted` so that whoever keeps the game can save it
## (game_screen_tech_actions.dart: unlockBranch; game_screen_victory_actions.dart;
## guide_settings.dart).

var _game: Game
var _actions: GameActions
var _acted: Array = []


func before_each() -> void:
	_game = GameFactory.new_single_player("Nemo", 1)
	_actions = GameActions.new(_game)
	_actions.acted.connect(_acted.append)


func test_runs_an_action_for_the_human_and_tells_it_acted() -> void:
	_rich()
	var level := _hq().level
	var result := _actions.execute(UpgradeBuildingAction.new(BuildingType.Value.HEADQUARTERS))
	assert_true(result.is_success)
	assert_eq(_hq().level, level + 1)
	assert_eq(_acted, [result])
	assert_eq(_game.human_player().history_entries.size(), 1, "the executor notes it")


func test_a_refused_action_changes_nothing_and_tells_nothing() -> void:
	_game.human_player().resources[ResourceType.Value.CORAL].amount = 0
	var result := _actions.execute(UpgradeBuildingAction.new(BuildingType.Value.HEADQUARTERS))
	assert_false(result.is_success)
	assert_eq(result.reason, ActionFailure.Value.NOT_ENOUGH_RESOURCES)
	assert_eq(_acted, [])


func test_switches_the_guide_and_the_tips() -> void:
	var state := ObjectiveMigration.state_of(_game, _game.human_player())
	_actions.set_guide_enabled(true)
	assert_true(state.tutorial_enabled)
	assert_false(state.tips_enabled)
	_actions.set_tips_enabled(true)
	assert_true(state.tips_enabled)
	_actions.set_guide_enabled(false)
	assert_false(state.tutorial_enabled)
	assert_true(state.tips_enabled)
	assert_eq(_acted, [null, null, null])


func test_marks_a_tip_as_seen_once() -> void:
	var state := ObjectiveMigration.state_of(_game, _game.human_player())
	_actions.mark_tip_seen(TipId.Value.WORKSITES)
	_actions.mark_tip_seen(TipId.Value.WORKSITES)
	assert_eq(state.seen_tips, [TipId.Value.WORKSITES] as Array[TipId.Value])
	assert_eq(_acted.size(), 2, "each mark is a change to save")


func test_goes_on_in_free_play() -> void:
	_game.status = GameStatus.Value.VICTORY
	_actions.continue_in_free_play()
	assert_eq(_game.status, GameStatus.Value.FREE_PLAY)
	assert_eq(_acted, [null])


func test_a_mark_runs_any_change_of_the_game() -> void:
	_actions.mark(func(game: Game) -> void: game.turn = 9)
	assert_eq(_game.turn, 9)
	assert_eq(_acted, [null])


func _hq() -> Building:
	return _game.human_player().buildings[BuildingType.Value.HEADQUARTERS]


func _rich() -> void:
	for resource: GameResource in _game.human_player().resources.values():
		resource.amount = resource.max_storage

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


func test_ends_the_turn_and_returns_what_it_did() -> void:
	_game.human_player().buildings[BuildingType.Value.ALGAE_FARM].level = 2
	var turn := _game.turn
	var made := _game.human_player().resources[ResourceType.Value.ALGAE].amount
	var result := _actions.end_turn()
	assert_eq(_game.turn, turn + 1)
	assert_eq(result.previous_turn, turn)
	assert_eq(result.new_turn, turn + 1)
	assert_true(_game.human_player().resources[ResourceType.Value.ALGAE].amount > made)
	assert_eq(_acted.size(), 1, "the end of the turn is a change to save")
	var told: EndTurnActionResult = _acted[0]
	assert_eq(told.turn_result, result)
	assert_true(_game.human_player().history_entries[0] is TurnEndEntry)


func test_tells_the_victory_once_a_kernel_stands_at_the_last_level() -> void:
	var told: Array[String] = []
	_actions.acted.connect(func(_result: Variant) -> void: told.append("acted"))
	_actions.victory_reached.connect(func() -> void: told.append("victory"))
	var player := _game.human_player()
	player.buildings[BuildingType.Value.HEADQUARTERS].level = 10
	player.buildings[BuildingType.Value.VOLCANIC_KERNEL].level = 9
	_rich()
	_actions.execute(UpgradeBuildingAction.new(BuildingType.Value.ALGAE_FARM))
	assert_eq(_game.status, GameStatus.Value.PLAYING)
	assert_eq(told, ["acted"] as Array[String])
	player.buildings[BuildingType.Value.VOLCANIC_KERNEL].level = 10
	player.worksite.upgrades = 0
	_rich()
	_actions.execute(UpgradeBuildingAction.new(BuildingType.Value.ALGAE_FARM))
	assert_eq(_game.status, GameStatus.Value.VICTORY)
	assert_eq(told, ["acted", "acted", "victory"] as Array[String], "told once the change is told, to be saved with it")


func test_a_game_already_won_is_not_won_again() -> void:
	_game.status = GameStatus.Value.FREE_PLAY
	_game.human_player().buildings[BuildingType.Value.HEADQUARTERS].level = 10
	_game.human_player().buildings[BuildingType.Value.VOLCANIC_KERNEL].level = 10
	var told: Array[String] = []
	_actions.victory_reached.connect(func() -> void: told.append("victory"))
	_rich()
	assert_true(_actions.execute(UpgradeBuildingAction.new(BuildingType.Value.ALGAE_FARM)).is_success)
	assert_eq(_game.status, GameStatus.Value.FREE_PLAY)
	assert_eq(told, [] as Array[String])


func _hq() -> Building:
	return _game.human_player().buildings[BuildingType.Value.HEADQUARTERS]


func _rich() -> void:
	for resource: GameResource in _game.human_player().resources.values():
		resource.amount = resource.max_storage
